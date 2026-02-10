# Spotify Dashboard - Database Connection Configuration
# This script sets up the PostgreSQL database connection for R

# Install required packages if not already installed
required_packages <- c("RPostgreSQL", "DBI", "dotenv")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org/")

# Load libraries
library(RPostgreSQL)
library(DBI)

# Database connection function
#' Connect to Spotify PostgreSQL Database
#' 
#' This function establishes a connection to the PostgreSQL database
#' 
#' @param host Database host (default: localhost)
#' @param port Database port (default: 5432)
#' @param dbname Database name (default: spotify_db)
#' @param user Database username
#' @param password Database password
#' @return Database connection object
#' @export
connect_to_spotify_db <- function(host = "localhost", 
                                  port = 5432, 
                                  dbname = "spotify_db",
                                  user = Sys.getenv("DB_USER", "postgres"),
                                  password = Sys.getenv("DB_PASSWORD", "")) {
  
  tryCatch({
    # Create connection
    con <- dbConnect(
      PostgreSQL(),
      host = host,
      port = port,
      dbname = dbname,
      user = user,
      password = password
    )
    
    # Set search path
    dbExecute(con, "SET search_path TO spotify, public;")
    
    message("Successfully connected to Spotify database!")
    return(con)
    
  }, error = function(e) {
    stop(paste("Failed to connect to database:", e$message))
  })
}

# Function to safely close database connection
#' Close Database Connection
#' 
#' @param con Database connection object
#' @export
close_db_connection <- function(con) {
  if (!is.null(con) && dbIsValid(con)) {
    dbDisconnect(con)
    message("Database connection closed successfully.")
  }
}

# Function to execute query and return data frame
#' Execute SQL Query
#' 
#' @param con Database connection object
#' @param query SQL query string
#' @return Data frame with query results
#' @export
execute_query <- function(con, query) {
  tryCatch({
    result <- dbGetQuery(con, query)
    return(result)
  }, error = function(e) {
    stop(paste("Query execution failed:", e$message))
  })
}

# Example usage (commented out):
# con <- connect_to_spotify_db(
#   user = "your_username",
#   password = "your_password"
# )
# 
# data <- execute_query(con, "SELECT * FROM artists LIMIT 10;")
# print(data)
# 
# close_db_connection(con)
