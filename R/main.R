# Spotify Dashboard - Main Script
# This is the main entry point for running the Spotify dashboard analysis

# Clear environment
rm(list = ls())

# Set working directory to script location (works in RStudio and command line)
# For RStudio users: automatically sets to script location
# For command line users: manually set working directory before running
tryCatch({
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  }
}, error = function(e) {
  # If not in RStudio, assume working directory is already set
  message("Working directory not automatically set. Please ensure you're in the project root.")
})

# Source all required scripts
source("R/01_database_connection.R")
source("R/02_data_extraction.R")
source("R/03_analysis_visualization.R")

# Main function to run the complete analysis
#' Run Spotify Dashboard Analysis
#' 
#' This function executes the complete dashboard analysis pipeline
#' 
#' @param db_user Database username
#' @param db_password Database password
#' @param db_host Database host (default: localhost)
#' @param db_port Database port (default: 5432)
#' @param db_name Database name (default: spotify_db)
#' @param output_dir Output directory for visualizations (default: output)
#' @export
run_spotify_dashboard <- function(db_user, 
                                  db_password, 
                                  db_host = "localhost",
                                  db_port = 5432,
                                  db_name = "spotify_db",
                                  output_dir = "output") {
  
  message("=== Spotify Dashboard Analysis ===\n")
  
  # Step 1: Connect to database
  message("Step 1: Connecting to database...")
  con <- connect_to_spotify_db(
    host = db_host,
    port = db_port,
    dbname = db_name,
    user = db_user,
    password = db_password
  )
  
  # Step 2: Generate complete dashboard report
  message("\nStep 2: Generating dashboard report...")
  summary <- generate_dashboard_report(con, output_dir = output_dir)
  
  # Step 3: Close database connection
  message("\nStep 3: Closing database connection...")
  close_db_connection(con)
  
  message("\n=== Analysis Complete! ===")
  message(sprintf("All results saved to '%s' directory.", output_dir))
  
  return(summary)
}

# Example usage:
# Uncomment and modify the following lines to run the analysis
# 
# summary <- run_spotify_dashboard(
#   db_user = "your_username",
#   db_password = "your_password",
#   db_host = "localhost",
#   db_port = 5432,
#   db_name = "spotify_db",
#   output_dir = "output"
# )

# Alternative: Interactive mode
# If you prefer to run step by step:
# 
# con <- connect_to_spotify_db(user = "your_user", password = "your_password")
# 
# # Get data
# top_artists <- get_top_artists(con, limit = 20)
# audio_features <- get_audio_features(con, min_popularity = 50)
# listening_patterns <- get_listening_patterns(con, days = 30)
# streaming_stats <- get_streaming_stats(con, days = 30)
# 
# # Create individual plots
# plot_top_artists(top_artists)
# plot_audio_features_distribution(audio_features)
# plot_energy_vs_danceability(audio_features)
# plot_listening_by_hour(listening_patterns)
# plot_listening_by_weekday(listening_patterns)
# plot_top_tracks(streaming_stats)
# plot_feature_correlation(audio_features)
# 
# # Close connection
# close_db_connection(con)
