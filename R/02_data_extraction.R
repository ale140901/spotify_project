# Spotify Dashboard - Data Extraction and Preparation
# This script extracts data from PostgreSQL and prepares it for analysis

# Load required libraries
required_packages <- c("dplyr", "tidyr", "lubridate", "stringr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org/")

library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# Source database connection script
source("R/01_database_connection.R")

#' Extract Top Artists Data
#' 
#' Problem: Get the most popular artists for dashboard visualization
#' 
#' @param con Database connection object
#' @param limit Number of top artists to retrieve (default: 50)
#' @return Data frame with top artists
#' @export
get_top_artists <- function(con, limit = 50) {
  query <- sprintf("
    SELECT 
      artist_id,
      artist_name,
      array_to_string(genres, ', ') as genres,
      popularity,
      followers
    FROM artists
    ORDER BY popularity DESC, followers DESC
    LIMIT %d;
  ", limit)
  
  data <- execute_query(con, query)
  
  # Data cleaning
  data <- data %>%
    mutate(
      popularity = as.numeric(popularity),
      followers = as.numeric(followers)
    )
  
  return(data)
}

#' Extract Audio Features Data
#' 
#' Problem: Analyze audio characteristics for music trend analysis
#' 
#' @param con Database connection object
#' @param min_popularity Minimum track popularity (default: 0)
#' @return Data frame with audio features
#' @export
get_audio_features <- function(con, min_popularity = 0) {
  query <- sprintf("
    SELECT 
      t.track_id,
      t.track_name,
      a.artist_name,
      t.popularity as track_popularity,
      af.danceability,
      af.energy,
      af.valence,
      af.tempo,
      af.acousticness,
      af.instrumentalness,
      af.liveness,
      af.speechiness,
      af.loudness
    FROM tracks t
    JOIN artists a ON t.artist_id = a.artist_id
    JOIN audio_features af ON t.track_id = af.track_id
    WHERE t.popularity >= %d
    ORDER BY t.popularity DESC;
  ", min_popularity)
  
  data <- execute_query(con, query)
  
  # Convert to appropriate data types
  numeric_cols <- c("track_popularity", "danceability", "energy", "valence", 
                    "tempo", "acousticness", "instrumentalness", "liveness", 
                    "speechiness", "loudness")
  
  data <- data %>%
    mutate(across(all_of(numeric_cols), as.numeric))
  
  return(data)
}

#' Extract User Listening Patterns
#' 
#' Problem: Understand user behavior patterns by time
#' 
#' @param con Database connection object
#' @param days Number of days to look back (default: 30)
#' @return Data frame with listening patterns
#' @export
get_listening_patterns <- function(con, days = 30) {
  query <- sprintf("
    SELECT 
      user_id,
      track_id,
      played_at,
      play_duration_ms,
      context_type,
      device_type
    FROM user_listening_history
    WHERE played_at >= CURRENT_DATE - INTERVAL '%d days'
    ORDER BY played_at DESC;
  ", days)
  
  data <- execute_query(con, query)
  
  # Data transformation
  data <- data %>%
    mutate(
      played_at = as.POSIXct(played_at),
      play_duration_seconds = play_duration_ms / 1000,
      hour_of_day = hour(played_at),
      day_of_week = wday(played_at, label = TRUE),
      date = as.Date(played_at)
    )
  
  return(data)
}

#' Extract Streaming Statistics
#' 
#' Problem: Calculate streaming metrics for dashboard KPIs
#' 
#' @param con Database connection object
#' @param days Number of days to analyze (default: 30)
#' @return Data frame with streaming statistics
#' @export
get_streaming_stats <- function(con, days = 30) {
  query <- sprintf("
    SELECT 
      t.track_id,
      t.track_name,
      a.artist_name,
      al.album_name,
      COUNT(ulh.listening_id) as stream_count,
      COUNT(DISTINCT ulh.user_id) as unique_listeners,
      AVG(ulh.play_duration_ms / 1000.0) as avg_play_duration_seconds,
      t.popularity
    FROM user_listening_history ulh
    JOIN tracks t ON ulh.track_id = t.track_id
    JOIN artists a ON t.artist_id = a.artist_id
    LEFT JOIN albums al ON t.album_id = al.album_id
    WHERE ulh.played_at >= CURRENT_DATE - INTERVAL '%d days'
    GROUP BY t.track_id, t.track_name, a.artist_name, al.album_name, t.popularity
    ORDER BY stream_count DESC;
  ", days)
  
  data <- execute_query(con, query)
  
  # Data type conversion
  data <- data %>%
    mutate(
      stream_count = as.numeric(stream_count),
      unique_listeners = as.numeric(unique_listeners),
      avg_play_duration_seconds = as.numeric(avg_play_duration_seconds),
      popularity = as.numeric(popularity)
    )
  
  return(data)
}

#' Prepare Dashboard Summary Data
#' 
#' Problem: Create aggregated summary for dashboard overview
#' 
#' @param con Database connection object
#' @return List with summary statistics
#' @export
get_dashboard_summary <- function(con) {
  
  # Total counts
  total_artists <- execute_query(con, "SELECT COUNT(*) as count FROM artists;")$count
  total_tracks <- execute_query(con, "SELECT COUNT(*) as count FROM tracks;")$count
  total_albums <- execute_query(con, "SELECT COUNT(*) as count FROM albums;")$count
  
  # Recent activity (last 30 days)
  activity_query <- "
    SELECT 
      COUNT(DISTINCT user_id) as active_users,
      COUNT(listening_id) as total_plays,
      SUM(play_duration_ms) / 1000.0 / 60.0 / 60.0 as total_hours
    FROM user_listening_history
    WHERE played_at >= CURRENT_DATE - INTERVAL '30 days';
  "
  activity_data <- execute_query(con, activity_query)
  
  summary <- list(
    total_artists = total_artists,
    total_tracks = total_tracks,
    total_albums = total_albums,
    active_users_30d = activity_data$active_users,
    total_plays_30d = activity_data$total_plays,
    total_hours_30d = round(activity_data$total_hours, 2)
  )
  
  return(summary)
}

# Example usage (commented out):
# con <- connect_to_spotify_db(user = "your_user", password = "your_password")
# 
# top_artists <- get_top_artists(con, limit = 20)
# audio_features <- get_audio_features(con, min_popularity = 50)
# listening_patterns <- get_listening_patterns(con, days = 30)
# streaming_stats <- get_streaming_stats(con, days = 30)
# summary <- get_dashboard_summary(con)
# 
# close_db_connection(con)
