# Quick Start Guide

This guide will help you get started with the Spotify Dashboard project quickly.

## 📋 Prerequisites Checklist

- [ ] PostgreSQL installed (version 12+)
- [ ] R installed (version 4.0+)
- [ ] Looker account (optional, for dashboards)

## 🚀 Quick Setup (5 minutes)

### Step 1: Set Up Database (2 minutes)

```bash
# 1. Open PostgreSQL terminal
psql -U postgres

# 2. Run setup scripts in this order:
\i sql/01_create_database.sql
\i sql/02_create_tables.sql
\i sql/04_looker_views.sql
\i sql/05_sample_data.sql

# 3. Verify installation
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'spotify' 
ORDER BY table_name;
```

### Step 2: Configure R (1 minute)

```bash
# Create .Renviron file in project root
echo "DB_USER=postgres" > .Renviron
echo "DB_PASSWORD=your_password" >> .Renviron
echo "DB_HOST=localhost" >> .Renviron
```

### Step 3: Test R Connection (2 minutes)

```r
# Open R/RStudio
setwd("/path/to/spotify_project")

# Install required packages (one-time)
install.packages(c("RPostgreSQL", "DBI", "dplyr", "ggplot2", 
                   "tidyr", "lubridate", "scales", "viridis"))

# Test connection
source("R/01_database_connection.R")
con <- connect_to_spotify_db(
  user = "postgres",
  password = "your_password"
)

# Should see: "Successfully connected to Spotify database!"
```

## 📊 Running Your First Analysis

### Option A: Full Dashboard Report

```r
source("R/main.R")

summary <- run_spotify_dashboard(
  db_user = "postgres",
  db_password = "your_password",
  output_dir = "output"
)
```

This will:
- Extract all data from database
- Generate 7 visualizations
- Save to `output/` folder
- Print summary statistics

### Option B: Custom Analysis

```r
# Load scripts
source("R/01_database_connection.R")
source("R/02_data_extraction.R")
source("R/03_analysis_visualization.R")

# Connect to database
con <- connect_to_spotify_db(user = "postgres", password = "your_password")

# Get specific data
top_artists <- get_top_artists(con, limit = 10)
audio_features <- get_audio_features(con, min_popularity = 50)

# Create specific visualizations
plot_top_artists(top_artists)
plot_audio_features_distribution(audio_features)

# Close connection
close_db_connection(con)
```

## 📈 Sample Outputs

After running the analysis, you'll find these visualizations in the `output/` folder:

1. `top_artists.png` - Bar chart of most popular artists
2. `audio_features_distribution.png` - Distribution of audio characteristics
3. `energy_vs_danceability.png` - Correlation scatter plot
4. `listening_by_hour.png` - Hourly listening patterns
5. `listening_by_weekday.png` - Weekly listening patterns
6. `top_tracks.png` - Most streamed tracks
7. `feature_correlation.png` - Audio feature correlation matrix

## 🔍 Exploring the Data

### Quick SQL Queries

```sql
-- See all artists
SELECT * FROM spotify.artists LIMIT 10;

-- Find popular tracks
SELECT track_name, artist_name, popularity 
FROM spotify.vw_track_analytics 
WHERE popularity > 80 
ORDER BY popularity DESC;

-- Check listening activity
SELECT COUNT(*) as total_plays 
FROM spotify.user_listening_history;
```

### Quick R Analysis

```r
# Get dashboard summary
summary <- get_dashboard_summary(con)
print(summary)

# Get streaming stats
stats <- get_streaming_stats(con, days = 30)
head(stats, 10)
```

## 🎨 Customizing Visualizations

Edit `R/03_analysis_visualization.R` to customize:

```r
# Change colors
scale_fill_viridis(option = "plasma")  # Try: viridis, magma, inferno, plasma

# Change plot size when saving
ggsave("plot.png", width = 12, height = 8, dpi = 300)

# Change number of items shown
plot_top_artists(data, top_n = 20)  # Show 20 instead of 15
```

## 🔧 Common Tasks

### Add Your Own Data

```sql
-- Add new artist
INSERT INTO spotify.artists (artist_id, artist_name, genres, popularity, followers)
VALUES ('my_artist', 'My Favorite Artist', ARRAY['pop', 'rock'], 85, 1000000);

-- Add new track
INSERT INTO spotify.tracks (track_id, track_name, artist_id, duration_ms, popularity)
VALUES ('my_track', 'My Favorite Song', 'my_artist', 210000, 90);
```

### Create Custom Query

```sql
-- Save as sql/my_custom_query.sql
SELECT 
  a.artist_name,
  COUNT(t.track_id) as total_tracks,
  AVG(t.popularity) as avg_popularity
FROM spotify.artists a
JOIN spotify.tracks t ON a.artist_id = t.artist_id
GROUP BY a.artist_name
HAVING COUNT(t.track_id) > 5
ORDER BY avg_popularity DESC;
```

### Create Custom R Function

```r
# Add to R/02_data_extraction.R
get_my_custom_data <- function(con) {
  query <- "SELECT * FROM my_custom_view;"
  data <- execute_query(con, query)
  return(data)
}
```

## 🐛 Troubleshooting

### Database Connection Issues

```r
# Test PostgreSQL is running
system("pg_isready")

# Check if you can connect with psql
system("psql -U postgres -c 'SELECT version();'")

# Verify connection details
con <- connect_to_spotify_db(
  host = "localhost",  # Try "127.0.0.1"
  port = 5432,
  user = "postgres",
  password = "your_password"
)
```

### R Package Issues

```r
# Update all packages
update.packages(ask = FALSE)

# Reinstall specific package
remove.packages("RPostgreSQL")
install.packages("RPostgreSQL")
```

### Data Issues

```sql
-- Check if tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'spotify';

-- Check if data exists
SELECT 'artists' as table_name, COUNT(*) FROM spotify.artists
UNION ALL
SELECT 'tracks', COUNT(*) FROM spotify.tracks;
```

## 📚 Next Steps

1. **Explore the Data**
   - Run the sample queries in `sql/03_analytical_queries.sql`
   - Modify queries to answer your own questions

2. **Create Visualizations**
   - Experiment with different plot types
   - Try different color schemes
   - Create custom visualizations

3. **Set Up Looker** (optional)
   - Follow `docs/looker_integration.md`
   - Create interactive dashboards
   - Schedule automated reports

4. **Customize for Your Needs**
   - Add your own data sources
   - Create custom metrics
   - Build specific reports

## 💡 Tips

- **Start Small**: Begin with sample data before loading large datasets
- **Save Often**: Use the output directory to save your work
- **Document Changes**: Add comments to your custom queries and functions
- **Version Control**: Use git to track your modifications
- **Ask Questions**: Check the main README.md for detailed documentation

## 🎯 Goals to Achieve

- [ ] Successfully connect to database
- [ ] Run first SQL query
- [ ] Generate first R visualization
- [ ] Create custom analysis
- [ ] Set up Looker dashboard (optional)
- [ ] Share insights with team

## 📞 Need Help?

1. Check the main `README.md` for detailed documentation
2. Review code comments in R and SQL files
3. See `docs/looker_integration.md` for Looker setup
4. See `docs/data_pipeline.md` for architecture details

---

**Ready to start?** Open PostgreSQL, run the setup scripts, and you'll be analyzing Spotify data in minutes! 🚀
