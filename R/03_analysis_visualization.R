# Spotify Dashboard - Data Analysis and Visualization
# This script performs analysis and creates visualizations for the dashboard

# Load required libraries
required_packages <- c("ggplot2", "dplyr", "tidyr", "scales", "viridis", 
                       "gridExtra", "reshape2")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org/")

library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(viridis)
library(gridExtra)
library(reshape2)

# Source required scripts
source("R/01_database_connection.R")
source("R/02_data_extraction.R")

#' Create Top Artists Visualization
#' 
#' Problem: Visualize the most popular artists for quick insights
#' 
#' @param data Data frame with artist information
#' @param top_n Number of top artists to display (default: 15)
#' @return ggplot object
#' @export
plot_top_artists <- function(data, top_n = 15) {
  plot_data <- data %>%
    head(top_n) %>%
    arrange(popularity)
  
  plot_data$artist_name <- factor(plot_data$artist_name, 
                                   levels = plot_data$artist_name)
  
  ggplot(plot_data, aes(x = artist_name, y = popularity, fill = popularity)) +
    geom_col() +
    coord_flip() +
    scale_fill_viridis(option = "plasma") +
    labs(
      title = paste("Top", top_n, "Most Popular Artists"),
      x = "Artist",
      y = "Popularity Score",
      fill = "Popularity"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      legend.position = "none"
    )
}

#' Analyze Audio Features Distribution
#' 
#' Problem: Understand the distribution of audio characteristics
#' 
#' @param data Data frame with audio features
#' @return ggplot object
#' @export
plot_audio_features_distribution <- function(data) {
  
  # Select features to analyze
  features <- c("danceability", "energy", "valence", "acousticness", 
                "instrumentalness", "liveness", "speechiness")
  
  plot_data <- data %>%
    select(all_of(features)) %>%
    pivot_longer(cols = everything(), names_to = "feature", values_to = "value")
  
  ggplot(plot_data, aes(x = value, fill = feature)) +
    geom_density(alpha = 0.7) +
    facet_wrap(~ feature, scales = "free_y") +
    scale_fill_viridis(discrete = TRUE, option = "viridis") +
    labs(
      title = "Distribution of Audio Features",
      x = "Feature Value",
      y = "Density"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      legend.position = "none",
      strip.text = element_text(face = "bold")
    )
}

#' Analyze Energy vs Danceability
#' 
#' Problem: Explore relationship between energy and danceability
#' 
#' @param data Data frame with audio features
#' @return ggplot object
#' @export
plot_energy_vs_danceability <- function(data) {
  
  ggplot(data, aes(x = danceability, y = energy, color = track_popularity)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", color = "red", linetype = "dashed") +
    scale_color_viridis(option = "inferno") +
    labs(
      title = "Energy vs Danceability Analysis",
      x = "Danceability",
      y = "Energy",
      color = "Track\nPopularity"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
    )
}

#' Analyze Listening Patterns by Hour
#' 
#' Problem: Identify peak listening times for optimization
#' 
#' @param data Data frame with listening history
#' @return ggplot object
#' @export
plot_listening_by_hour <- function(data) {
  
  hourly_data <- data %>%
    group_by(hour_of_day) %>%
    summarise(
      play_count = n(),
      unique_users = n_distinct(user_id),
      .groups = "drop"
    )
  
  ggplot(hourly_data, aes(x = hour_of_day, y = play_count)) +
    geom_line(color = "#1DB954", size = 1.2) +
    geom_point(color = "#1DB954", size = 3) +
    geom_area(fill = "#1DB954", alpha = 0.3) +
    scale_x_continuous(breaks = seq(0, 23, 2)) +
    labs(
      title = "Listening Activity by Hour of Day",
      x = "Hour of Day",
      y = "Number of Plays"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
    )
}

#' Analyze Listening Patterns by Day of Week
#' 
#' Problem: Understand weekly listening patterns
#' 
#' @param data Data frame with listening history
#' @return ggplot object
#' @export
plot_listening_by_weekday <- function(data) {
  
  daily_data <- data %>%
    group_by(day_of_week) %>%
    summarise(
      play_count = n(),
      avg_duration = mean(play_duration_seconds, na.rm = TRUE),
      .groups = "drop"
    )
  
  ggplot(daily_data, aes(x = day_of_week, y = play_count, fill = day_of_week)) +
    geom_col() +
    scale_fill_viridis(discrete = TRUE, option = "plasma") +
    labs(
      title = "Listening Activity by Day of Week",
      x = "Day of Week",
      y = "Number of Plays"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      legend.position = "none"
    )
}

#' Create Streaming Leaderboard
#' 
#' Problem: Identify top trending tracks
#' 
#' @param data Data frame with streaming statistics
#' @param top_n Number of top tracks to display (default: 10)
#' @return ggplot object
#' @export
plot_top_tracks <- function(data, top_n = 10) {
  
  plot_data <- data %>%
    head(top_n) %>%
    mutate(track_label = paste0(track_name, " - ", artist_name)) %>%
    arrange(stream_count)
  
  plot_data$track_label <- factor(plot_data$track_label, 
                                   levels = plot_data$track_label)
  
  ggplot(plot_data, aes(x = track_label, y = stream_count, fill = unique_listeners)) +
    geom_col() +
    coord_flip() +
    scale_fill_viridis(option = "mako") +
    scale_y_continuous(labels = comma) +
    labs(
      title = paste("Top", top_n, "Most Streamed Tracks"),
      x = "Track",
      y = "Stream Count",
      fill = "Unique\nListeners"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
    )
}

#' Create Audio Features Correlation Heatmap
#' 
#' Problem: Understand correlations between audio features
#' 
#' @param data Data frame with audio features
#' @return ggplot object
#' @export
plot_feature_correlation <- function(data) {
  
  # Select numeric features
  features <- c("danceability", "energy", "valence", "acousticness", 
                "instrumentalness", "speechiness", "tempo", "loudness")
  
  cor_data <- data %>%
    select(all_of(features)) %>%
    cor(use = "complete.obs")
  
  # Melt correlation matrix
  melted_cor <- melt(cor_data)
  
  ggplot(melted_cor, aes(x = Var1, y = Var2, fill = value)) +
    geom_tile() +
    geom_text(aes(label = round(value, 2)), size = 3) +
    scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                         midpoint = 0, limits = c(-1, 1)) +
    labs(
      title = "Audio Features Correlation Matrix",
      x = "",
      y = "",
      fill = "Correlation"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
}

#' Generate Complete Dashboard Report
#' 
#' Problem: Create comprehensive analysis report for stakeholders
#' 
#' @param con Database connection object
#' @param output_dir Directory to save plots (default: "output")
#' @export
generate_dashboard_report <- function(con, output_dir = "output") {
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  message("Extracting data from database...")
  
  # Extract data
  top_artists <- get_top_artists(con, limit = 20)
  audio_features <- get_audio_features(con, min_popularity = 30)
  listening_patterns <- get_listening_patterns(con, days = 30)
  streaming_stats <- get_streaming_stats(con, days = 30)
  summary <- get_dashboard_summary(con)
  
  message("Creating visualizations...")
  
  # Generate plots
  p1 <- plot_top_artists(top_artists, top_n = 15)
  ggsave(file.path(output_dir, "top_artists.png"), p1, width = 10, height = 8)
  
  p2 <- plot_audio_features_distribution(audio_features)
  ggsave(file.path(output_dir, "audio_features_distribution.png"), p2, width = 12, height = 8)
  
  p3 <- plot_energy_vs_danceability(audio_features)
  ggsave(file.path(output_dir, "energy_vs_danceability.png"), p3, width = 10, height = 8)
  
  p4 <- plot_listening_by_hour(listening_patterns)
  ggsave(file.path(output_dir, "listening_by_hour.png"), p4, width = 10, height = 6)
  
  p5 <- plot_listening_by_weekday(listening_patterns)
  ggsave(file.path(output_dir, "listening_by_weekday.png"), p5, width = 10, height = 6)
  
  p6 <- plot_top_tracks(streaming_stats, top_n = 10)
  ggsave(file.path(output_dir, "top_tracks.png"), p6, width = 10, height = 8)
  
  p7 <- plot_feature_correlation(audio_features)
  ggsave(file.path(output_dir, "feature_correlation.png"), p7, width = 10, height = 8)
  
  # Print summary
  message("\n=== Dashboard Summary ===")
  message(sprintf("Total Artists: %s", format(summary$total_artists, big.mark = ",")))
  message(sprintf("Total Tracks: %s", format(summary$total_tracks, big.mark = ",")))
  message(sprintf("Total Albums: %s", format(summary$total_albums, big.mark = ",")))
  message(sprintf("Active Users (30 days): %s", format(summary$active_users_30d, big.mark = ",")))
  message(sprintf("Total Plays (30 days): %s", format(summary$total_plays_30d, big.mark = ",")))
  message(sprintf("Total Hours Listened (30 days): %s", summary$total_hours_30d))
  
  message(sprintf("\nAll visualizations saved to '%s' directory.", output_dir))
  
  return(summary)
}

# Example usage (commented out):
# con <- connect_to_spotify_db(user = "your_user", password = "your_password")
# summary <- generate_dashboard_report(con, output_dir = "output")
# close_db_connection(con)
