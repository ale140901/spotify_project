# Spotify Dashboard Project

A comprehensive analytics dashboard for Spotify data using **R**, **PostgreSQL**, and **Looker** to analyze music streaming patterns, track characteristics, and user behavior.

## 📊 Project Overview

This project creates a complete data analytics pipeline for Spotify streaming data, providing insights into:
- Artist and track popularity metrics
- Audio feature analysis (danceability, energy, valence, etc.)
- User listening patterns and behavior
- Streaming trends and engagement metrics
- Genre distribution and preferences

## 🎯 Problems Solved

### 1. **Data Storage and Management**
**Problem:** Need a scalable database solution to store and manage large volumes of Spotify streaming data including artists, tracks, albums, audio features, and user listening history.

**Solution:** Implemented a PostgreSQL database with:
- Normalized schema design for efficient data storage
- Foreign key relationships to maintain data integrity
- Indexes on frequently queried columns for optimal performance
- Proper data types and constraints for data validation

### 2. **Audio Feature Analysis**
**Problem:** Understanding what makes tracks popular by analyzing their audio characteristics (danceability, energy, valence, tempo, etc.).

**Solution:** Created analytical queries and R visualizations to:
- Analyze distribution of audio features across tracks
- Identify correlations between features (e.g., energy vs. danceability)
- Classify tracks by mood and energy levels
- Compare audio characteristics of popular vs. less popular tracks

### 3. **User Listening Behavior**
**Problem:** Need to understand when and how users consume music to optimize content recommendations and platform performance.

**Solution:** Developed queries and analytics to track:
- Hourly and daily listening patterns
- Peak usage times for resource optimization
- User engagement metrics (total plays, unique tracks, listening duration)
- Device usage distribution (mobile, desktop, speaker, web)

### 4. **Trend Identification**
**Problem:** Identifying trending tracks, artists, and genres to inform playlist curation and content promotion.

**Solution:** Built analytical views to:
- Rank tracks by stream count and unique listeners
- Track daily and monthly streaming trends
- Analyze genre popularity over time
- Identify top artists by popularity and follower count

### 5. **Dashboard Visualization**
**Problem:** Making complex data accessible and actionable for stakeholders through visual dashboards.

**Solution:** Created:
- R visualization scripts for detailed statistical analysis
- PostgreSQL views optimized for Looker integration
- Comprehensive dashboard metrics and KPIs
- Export capabilities for reports and presentations

### 6. **Data Integration**
**Problem:** Connecting different tools (PostgreSQL, R, Looker) in a cohesive data pipeline.

**Solution:** Implemented:
- R database connection layer with error handling
- Reusable data extraction functions
- Materialized views for Looker performance
- Consistent data models across all platforms

## 🗂️ Project Structure

```
spotify_project/
├── sql/                          # PostgreSQL scripts
│   ├── 01_create_database.sql    # Database creation
│   ├── 02_create_tables.sql      # Table schemas
│   ├── 03_analytical_queries.sql # Analysis queries
│   ├── 04_looker_views.sql       # Looker-optimized views
│   └── 05_sample_data.sql        # Sample data for testing
├── R/                            # R analysis scripts
│   ├── 01_database_connection.R  # Database connectivity
│   ├── 02_data_extraction.R      # Data extraction functions
│   ├── 03_analysis_visualization.R # Visualization functions
│   └── main.R                    # Main execution script
├── docs/                         # Documentation
│   └── looker_integration.md     # Looker setup guide
└── README.md                     # This file
```

## 🚀 Getting Started

### Prerequisites

- **PostgreSQL** (version 12 or higher)
- **R** (version 4.0 or higher)
- **Looker** account (for dashboard visualization)

### Required R Packages

```r
install.packages(c(
  "RPostgreSQL",
  "DBI",
  "dplyr",
  "tidyr",
  "ggplot2",
  "lubridate",
  "scales",
  "viridis",
  "gridExtra",
  "reshape2"
))
```

## 📥 Installation

### 1. Database Setup

```bash
# Connect to PostgreSQL
psql -U postgres

# Run the setup scripts in order
\i sql/01_create_database.sql
\i sql/02_create_tables.sql
\i sql/04_looker_views.sql

# Optional: Load sample data for testing
\i sql/05_sample_data.sql
```

### 2. R Configuration

Create a `.Renviron` file in the project root:

```
DB_USER=your_database_username
DB_PASSWORD=your_database_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=spotify_db
```

### 3. Run Analysis

```r
# Open R and set working directory
setwd("/path/to/spotify_project")

# Source the main script
source("R/main.R")

# Run the complete analysis
summary <- run_spotify_dashboard(
  db_user = "your_username",
  db_password = "your_password",
  output_dir = "output"
)
```

## 📊 Database Schema

### Core Tables

1. **artists** - Artist information and metadata
2. **albums** - Album details and release information
3. **tracks** - Track metadata and popularity metrics
4. **audio_features** - Audio analysis data (danceability, energy, etc.)
5. **user_listening_history** - User streaming events

### Key Views

1. **vw_artist_performance** - Aggregated artist metrics
2. **vw_track_analytics** - Track data with audio features
3. **vw_user_activity_summary** - User engagement metrics
4. **vw_daily_streaming_trends** - Daily streaming patterns
5. **vw_hourly_activity_patterns** - Hourly usage patterns

## 📈 Key Metrics & KPIs

- **Artist Popularity**: Ranking based on popularity score and followers
- **Track Performance**: Stream count, unique listeners, completion rate
- **Audio Features**: Distribution and correlation analysis
- **User Engagement**: Total plays, listening duration, active days
- **Temporal Patterns**: Peak hours, daily/weekly trends
- **Device Distribution**: Platform usage statistics
- **Genre Analysis**: Genre popularity and artist distribution

## 🎨 Visualizations

The R scripts generate the following visualizations:

1. **Top Artists Bar Chart** - Most popular artists
2. **Audio Features Distribution** - Density plots for each feature
3. **Energy vs Danceability Scatter** - Correlation analysis
4. **Hourly Listening Pattern** - Line chart of daily activity
5. **Weekly Listening Pattern** - Bar chart by day of week
6. **Top Tracks Leaderboard** - Most streamed tracks
7. **Feature Correlation Heatmap** - Audio feature relationships

## 🔗 Looker Integration

See [docs/looker_integration.md](docs/looker_integration.md) for detailed instructions on:
- Connecting Looker to PostgreSQL
- Creating Looker views and explores
- Building dashboards and visualizations
- Setting up scheduled reports

## 📝 Key SQL Queries

### Top 10 Most Popular Artists
```sql
SELECT artist_name, popularity, followers
FROM artists
ORDER BY popularity DESC, followers DESC
LIMIT 10;
```

### Track Audio Features Analysis
```sql
SELECT t.track_name, a.artist_name, af.danceability, af.energy, af.valence
FROM tracks t
JOIN artists a ON t.artist_id = a.artist_id
JOIN audio_features af ON t.track_id = af.track_id
WHERE t.popularity > 70;
```

### User Listening Patterns by Hour
```sql
SELECT 
  EXTRACT(HOUR FROM played_at) as hour,
  COUNT(*) as play_count,
  COUNT(DISTINCT user_id) as unique_users
FROM user_listening_history
GROUP BY hour
ORDER BY hour;
```

## 🔧 Customization

### Adding New Metrics

1. Add queries to `sql/03_analytical_queries.sql`
2. Create extraction functions in `R/02_data_extraction.R`
3. Build visualizations in `R/03_analysis_visualization.R`
4. Update Looker views in `sql/04_looker_views.sql`

### Modifying Visualizations

Edit the plot functions in `R/03_analysis_visualization.R` to customize:
- Color schemes (using viridis palettes)
- Plot types (bar, line, scatter, density)
- Themes and styling
- Export dimensions and formats

## 🎓 Use Cases

1. **Music Recommendation** - Analyze audio features to recommend similar tracks
2. **Playlist Curation** - Identify trending tracks for playlist creation
3. **Marketing Analytics** - Understand user preferences and behavior
4. **Content Strategy** - Optimize release timing based on listening patterns
5. **Platform Optimization** - Improve UX based on device usage data
6. **Artist Insights** - Provide artists with performance metrics

## 🤝 Contributing

Feel free to:
- Add new analytical queries
- Create additional visualizations
- Improve documentation
- Report issues or suggest enhancements

## 📄 License

This project is open source and available for educational and commercial use.

## 👤 Author

Created for analyzing Spotify streaming data using modern data analytics tools.

## 🔍 Additional Resources

- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [R for Data Science](https://r4ds.had.co.nz/)
- [Looker Documentation](https://docs.looker.com/)

## 📞 Support

For questions or issues:
1. Check the documentation in the `docs/` folder
2. Review the commented code in R and SQL scripts
3. Open an issue on the project repository

---

**Built with:** PostgreSQL 🐘 | R 📊 | Looker 📈