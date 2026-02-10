-- Spotify Dashboard Analytical Queries
-- This script contains queries for dashboard metrics and insights

SET search_path TO spotify, public;

-- Query 1: Top 10 Most Popular Artists
-- Problem: Identify the most popular artists to feature in the dashboard
SELECT 
    artist_name,
    popularity,
    followers,
    array_to_string(genres, ', ') as genre_list
FROM artists
ORDER BY popularity DESC, followers DESC
LIMIT 10;

-- Query 2: Track Audio Features Analysis
-- Problem: Analyze audio characteristics of tracks to understand music trends
SELECT 
    t.track_name,
    a.artist_name,
    af.danceability,
    af.energy,
    af.valence,
    af.tempo,
    t.popularity
FROM tracks t
JOIN artists a ON t.artist_id = a.artist_id
JOIN audio_features af ON t.track_id = af.track_id
WHERE t.popularity > 70
ORDER BY t.popularity DESC;

-- Query 3: User Listening Patterns by Time of Day
-- Problem: Understand when users are most active to optimize content recommendations
SELECT 
    EXTRACT(HOUR FROM played_at) as hour_of_day,
    COUNT(*) as play_count,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(play_duration_ms / 1000.0) as avg_play_duration_seconds
FROM user_listening_history
GROUP BY EXTRACT(HOUR FROM played_at)
ORDER BY hour_of_day;

-- Query 4: Most Streamed Tracks
-- Problem: Identify trending tracks for playlist curation
SELECT 
    t.track_name,
    a.artist_name,
    COUNT(ulh.listening_id) as stream_count,
    t.popularity,
    t.duration_ms / 1000 as duration_seconds
FROM user_listening_history ulh
JOIN tracks t ON ulh.track_id = t.track_id
JOIN artists a ON t.artist_id = a.artist_id
WHERE ulh.played_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY t.track_id, t.track_name, a.artist_name, t.popularity, t.duration_ms
ORDER BY stream_count DESC
LIMIT 20;

-- Query 5: Genre Distribution Analysis
-- Problem: Understand genre preferences to improve content categorization
SELECT 
    unnest(genres) as genre,
    COUNT(*) as artist_count,
    AVG(popularity) as avg_popularity,
    SUM(followers) as total_followers
FROM artists
WHERE genres IS NOT NULL
GROUP BY genre
ORDER BY artist_count DESC
LIMIT 15;

-- Query 6: Album Release Trends
-- Problem: Analyze release patterns to identify optimal release windows
SELECT 
    EXTRACT(YEAR FROM release_date) as release_year,
    EXTRACT(MONTH FROM release_date) as release_month,
    COUNT(*) as album_count,
    album_type
FROM albums
WHERE release_date IS NOT NULL
GROUP BY release_year, release_month, album_type
ORDER BY release_year DESC, release_month DESC;

-- Query 7: Energy vs Danceability Correlation
-- Problem: Understand relationship between track features for recommendation engine
SELECT 
    CASE 
        WHEN af.energy >= 0.7 THEN 'High Energy'
        WHEN af.energy >= 0.4 THEN 'Medium Energy'
        ELSE 'Low Energy'
    END as energy_level,
    CASE 
        WHEN af.danceability >= 0.7 THEN 'High Danceability'
        WHEN af.danceability >= 0.4 THEN 'Medium Danceability'
        ELSE 'Low Danceability'
    END as danceability_level,
    COUNT(*) as track_count,
    AVG(t.popularity) as avg_popularity
FROM audio_features af
JOIN tracks t ON af.track_id = t.track_id
GROUP BY energy_level, danceability_level
ORDER BY avg_popularity DESC;

-- Query 8: User Engagement Metrics
-- Problem: Calculate key engagement metrics for dashboard KPIs
SELECT 
    user_id,
    COUNT(DISTINCT track_id) as unique_tracks_played,
    COUNT(listening_id) as total_plays,
    SUM(play_duration_ms) / 1000.0 / 60.0 as total_minutes_listened,
    AVG(play_duration_ms) / 1000.0 as avg_play_duration_seconds,
    COUNT(DISTINCT DATE(played_at)) as active_days
FROM user_listening_history
WHERE played_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY user_id
ORDER BY total_minutes_listened DESC;

-- Query 9: Explicit Content Analysis
-- Problem: Track explicit content distribution for content moderation
SELECT 
    explicit,
    COUNT(*) as track_count,
    AVG(popularity) as avg_popularity,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2) as percentage
FROM tracks
GROUP BY explicit;

-- Query 10: Device Usage Analysis
-- Problem: Understand platform usage to optimize user experience
SELECT 
    device_type,
    COUNT(*) as play_count,
    COUNT(DISTINCT user_id) as unique_users,
    ROUND(AVG(play_duration_ms / 1000.0), 2) as avg_duration_seconds
FROM user_listening_history
WHERE device_type IS NOT NULL
GROUP BY device_type
ORDER BY play_count DESC;
