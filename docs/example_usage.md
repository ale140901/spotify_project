# Example: Using the Spotify Dashboard Project

This example demonstrates how to use the Spotify Dashboard for a real-world scenario.

## Scenario: Analyzing Music Trends for Playlist Curation

**Goal**: Create a data-driven playlist by identifying high-energy, danceable tracks that are trending.

## Step-by-Step Example

### 1. Connect to Database

```r
# Load required libraries
source("R/01_database_connection.R")
source("R/02_data_extraction.R")
source("R/03_analysis_visualization.R")

# Establish connection
con <- connect_to_spotify_db(
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD")
)
```

### 2. Extract Relevant Data

```r
# Get tracks with high popularity (trending)
trending_tracks <- get_audio_features(con, min_popularity = 70)

# View the data
head(trending_tracks)
```

### 3. Filter for Specific Characteristics

```r
library(dplyr)

# Find high-energy, danceable tracks
workout_playlist <- trending_tracks %>%
  filter(
    energy >= 0.7,          # High energy
    danceability >= 0.6,    # Danceable
    tempo >= 120            # Upbeat tempo
  ) %>%
  arrange(desc(track_popularity)) %>%
  select(track_name, artist_name, energy, danceability, tempo, track_popularity)

# View top 20 candidates
head(workout_playlist, 20)
```

### 4. Visualize the Selection

```r
# Create scatter plot to visualize energy vs danceability
library(ggplot2)

ggplot(workout_playlist, aes(x = danceability, y = energy, 
                              size = track_popularity,
                              color = tempo)) +
  geom_point(alpha = 0.6) +
  scale_color_viridis_c(option = "plasma") +
  labs(
    title = "High-Energy Workout Playlist Candidates",
    subtitle = "Tracks with Energy >= 0.7 and Danceability >= 0.6",
    x = "Danceability",
    y = "Energy",
    size = "Popularity",
    color = "Tempo"
  ) +
  theme_minimal()

# Save the plot
ggsave("workout_playlist_analysis.png", width = 10, height = 6)
```

### 5. Export Results

```r
# Export to CSV for sharing
write.csv(workout_playlist, "workout_playlist_candidates.csv", row.names = FALSE)

# Print summary
cat("Total tracks found:", nrow(workout_playlist), "\n")
cat("Average energy:", round(mean(workout_playlist$energy), 2), "\n")
cat("Average danceability:", round(mean(workout_playlist$danceability), 2), "\n")
cat("Average tempo:", round(mean(workout_playlist$tempo), 1), "BPM\n")
```

### 6. Analyze by Mood

```r
# Categorize tracks by mood (valence)
mood_analysis <- trending_tracks %>%
  mutate(
    mood = case_when(
      valence >= 0.7 ~ "Happy",
      valence >= 0.4 ~ "Neutral",
      TRUE ~ "Melancholic"
    )
  ) %>%
  group_by(mood) %>%
  summarise(
    track_count = n(),
    avg_popularity = mean(track_popularity),
    avg_energy = mean(energy),
    avg_danceability = mean(danceability)
  )

print(mood_analysis)

# Visualize mood distribution
ggplot(mood_analysis, aes(x = mood, y = track_count, fill = mood)) +
  geom_col() +
  geom_text(aes(label = track_count), vjust = -0.5) +
  scale_fill_manual(values = c("Happy" = "#FFC107", 
                               "Neutral" = "#9E9E9E", 
                               "Melancholic" = "#2196F3")) +
  labs(
    title = "Track Distribution by Mood",
    x = "Mood",
    y = "Number of Tracks"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

### 7. User Listening Pattern Analysis

```r
# Get listening patterns
listening_data <- get_listening_patterns(con, days = 30)

# Find peak listening hours
hourly_summary <- listening_data %>%
  group_by(hour_of_day) %>%
  summarise(
    plays = n(),
    unique_users = n_distinct(user_id)
  ) %>%
  arrange(desc(plays))

print("Top 5 peak listening hours:")
print(head(hourly_summary, 5))

# Visualize
plot_listening_by_hour(listening_data)
ggsave("peak_listening_hours.png", width = 10, height = 6)
```

### 8. Create SQL-Based Report

```sql
-- Save as sql/workout_playlist_query.sql
-- This query finds high-energy tracks for workout playlists

WITH track_features AS (
  SELECT 
    t.track_id,
    t.track_name,
    a.artist_name,
    t.popularity,
    af.energy,
    af.danceability,
    af.tempo,
    af.valence,
    -- Calculate "workout score"
    (af.energy * 0.4 + af.danceability * 0.3 + 
     LEAST(af.tempo / 200.0, 1.0) * 0.3) as workout_score
  FROM tracks t
  JOIN artists a ON t.artist_id = a.artist_id
  JOIN audio_features af ON t.track_id = af.track_id
  WHERE 
    t.popularity >= 70
    AND af.energy >= 0.7
    AND af.danceability >= 0.6
    AND af.tempo >= 120
)
SELECT 
  track_name,
  artist_name,
  popularity,
  ROUND(energy::numeric, 2) as energy,
  ROUND(danceability::numeric, 2) as danceability,
  ROUND(tempo::numeric, 0) as tempo_bpm,
  ROUND(workout_score::numeric, 3) as workout_score
FROM track_features
ORDER BY workout_score DESC, popularity DESC
LIMIT 50;
```

Execute in R:
```r
workout_query <- readLines("sql/workout_playlist_query.sql")
workout_results <- execute_query(con, paste(workout_query, collapse = "\n"))
print(workout_results)
```

### 9. Generate Summary Report

```r
# Create comprehensive analysis report
create_playlist_report <- function(con, energy_min = 0.7, dance_min = 0.6) {
  
  # Get data
  tracks <- get_audio_features(con, min_popularity = 60)
  
  # Filter tracks
  filtered <- tracks %>%
    filter(energy >= energy_min, danceability >= dance_min)
  
  # Create report
  cat("=== WORKOUT PLAYLIST ANALYSIS REPORT ===\n\n")
  cat("Criteria:\n")
  cat("  - Minimum Energy:", energy_min, "\n")
  cat("  - Minimum Danceability:", dance_min, "\n\n")
  
  cat("Results:\n")
  cat("  - Total Tracks Found:", nrow(filtered), "\n")
  cat("  - Average Popularity:", round(mean(filtered$track_popularity), 1), "\n")
  cat("  - Average Energy:", round(mean(filtered$energy), 2), "\n")
  cat("  - Average Danceability:", round(mean(filtered$danceability), 2), "\n")
  cat("  - Average Tempo:", round(mean(filtered$tempo), 1), "BPM\n\n")
  
  cat("Top 10 Recommendations:\n")
  top_10 <- filtered %>%
    arrange(desc(track_popularity)) %>%
    head(10) %>%
    select(track_name, artist_name, track_popularity)
  
  print(top_10)
  
  return(filtered)
}

# Run the report
playlist_data <- create_playlist_report(con, energy_min = 0.7, dance_min = 0.6)
```

### 10. Close Connection

```r
# Always close the connection when done
close_db_connection(con)
```

## Expected Output

After running this example, you'll have:

1. **CSV File**: `workout_playlist_candidates.csv` with track recommendations
2. **Visualizations**: 
   - `workout_playlist_analysis.png` - Energy vs Danceability scatter plot
   - `peak_listening_hours.png` - Hourly listening patterns
3. **Console Report**: Summary statistics and top recommendations
4. **Data Frame**: `playlist_data` with all qualifying tracks

## Real-World Applications

### 1. Playlist Curation
Use the analysis to create themed playlists:
- Workout playlists (high energy, high danceability)
- Study playlists (low energy, high acousticness)
- Party playlists (high valence, high danceability)

### 2. Content Strategy
Identify optimal times to release new content based on listening patterns.

### 3. A/B Testing
Compare different audio features to see what drives engagement.

### 4. Artist Insights
Help artists understand what makes tracks successful.

## Customization Ideas

```r
# Chill/Study Playlist
chill_tracks <- trending_tracks %>%
  filter(
    energy <= 0.5,
    acousticness >= 0.4,
    instrumentalness >= 0.1
  )

# Party Playlist
party_tracks <- trending_tracks %>%
  filter(
    valence >= 0.7,
    danceability >= 0.7,
    energy >= 0.6
  )

# Sad Songs Playlist
sad_tracks <- trending_tracks %>%
  filter(
    valence <= 0.3,
    energy <= 0.5,
    acousticness >= 0.3
  )
```

## Next Steps

1. Modify the filters to match your specific use case
2. Create additional visualizations
3. Export data to other tools (Excel, Tableau, etc.)
4. Schedule regular reports
5. Integrate with Spotify API to create actual playlists

---

This example demonstrates the power of combining SQL, R, and data visualization to extract actionable insights from music data!
