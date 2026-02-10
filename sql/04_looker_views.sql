-- Spotify Dashboard - Data Views for Looker
-- This script creates views optimized for Looker dashboard integration

SET search_path TO spotify, public;

-- View: Artist Performance Metrics
-- Problem: Provide aggregated artist metrics for Looker visualizations
CREATE OR REPLACE VIEW vw_artist_performance AS
SELECT 
    a.artist_id,
    a.artist_name,
    a.genres,
    a.popularity as artist_popularity,
    a.followers,
    COUNT(DISTINCT t.track_id) as total_tracks,
    COUNT(DISTINCT al.album_id) as total_albums,
    AVG(t.popularity) as avg_track_popularity,
    MAX(t.popularity) as max_track_popularity
FROM artists a
LEFT JOIN tracks t ON a.artist_id = t.artist_id
LEFT JOIN albums al ON a.artist_id = al.artist_id
GROUP BY a.artist_id, a.artist_name, a.genres, a.popularity, a.followers;

-- View: Track Analytics
-- Problem: Combine track info with audio features for comprehensive analysis
CREATE OR REPLACE VIEW vw_track_analytics AS
SELECT 
    t.track_id,
    t.track_name,
    a.artist_name,
    a.artist_id,
    al.album_name,
    al.album_id,
    al.release_date,
    t.duration_ms,
    t.explicit,
    t.popularity as track_popularity,
    af.danceability,
    af.energy,
    af.key,
    af.loudness,
    af.mode,
    af.speechiness,
    af.acousticness,
    af.instrumentalness,
    af.liveness,
    af.valence,
    af.tempo,
    af.time_signature,
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
    CASE 
        WHEN af.valence >= 0.7 THEN 'Happy'
        WHEN af.valence >= 0.4 THEN 'Neutral'
        ELSE 'Sad'
    END as mood
FROM tracks t
JOIN artists a ON t.artist_id = a.artist_id
LEFT JOIN albums al ON t.album_id = al.album_id
LEFT JOIN audio_features af ON t.track_id = af.track_id;

-- View: User Activity Summary
-- Problem: Provide user engagement metrics for dashboard KPIs
CREATE OR REPLACE VIEW vw_user_activity_summary AS
SELECT 
    user_id,
    COUNT(listening_id) as total_plays,
    COUNT(DISTINCT track_id) as unique_tracks,
    COUNT(DISTINCT DATE(played_at)) as active_days,
    SUM(play_duration_ms) / 1000.0 / 60.0 as total_minutes_listened,
    AVG(play_duration_ms) / 1000.0 as avg_play_duration_seconds,
    MIN(played_at) as first_play_date,
    MAX(played_at) as last_play_date,
    COUNT(DISTINCT device_type) as device_types_used
FROM user_listening_history
GROUP BY user_id;

-- View: Daily Streaming Trends
-- Problem: Track daily streaming patterns for trend analysis
CREATE OR REPLACE VIEW vw_daily_streaming_trends AS
SELECT 
    DATE(played_at) as play_date,
    COUNT(listening_id) as total_plays,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT track_id) as unique_tracks,
    SUM(play_duration_ms) / 1000.0 / 60.0 / 60.0 as total_hours,
    AVG(play_duration_ms) / 1000.0 as avg_play_duration_seconds
FROM user_listening_history
GROUP BY DATE(played_at)
ORDER BY play_date DESC;

-- View: Hourly Activity Patterns
-- Problem: Understand peak usage times for optimization
CREATE OR REPLACE VIEW vw_hourly_activity_patterns AS
SELECT 
    EXTRACT(HOUR FROM played_at) as hour_of_day,
    EXTRACT(DOW FROM played_at) as day_of_week,
    COUNT(listening_id) as play_count,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(play_duration_ms) / 1000.0 as avg_duration_seconds
FROM user_listening_history
GROUP BY EXTRACT(HOUR FROM played_at), EXTRACT(DOW FROM played_at)
ORDER BY day_of_week, hour_of_day;

-- View: Top Tracks by Period
-- Problem: Identify trending content for various time periods
CREATE OR REPLACE VIEW vw_top_tracks_current_month AS
SELECT 
    t.track_id,
    t.track_name,
    a.artist_name,
    COUNT(ulh.listening_id) as stream_count,
    COUNT(DISTINCT ulh.user_id) as unique_listeners,
    t.popularity
FROM user_listening_history ulh
JOIN tracks t ON ulh.track_id = t.track_id
JOIN artists a ON t.artist_id = a.artist_id
WHERE played_at >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY t.track_id, t.track_name, a.artist_name, t.popularity
ORDER BY stream_count DESC;

-- View: Genre Analysis
-- Problem: Analyze genre distribution and popularity
CREATE OR REPLACE VIEW vw_genre_analysis AS
SELECT 
    unnest(a.genres) as genre,
    COUNT(DISTINCT a.artist_id) as artist_count,
    AVG(a.popularity) as avg_artist_popularity,
    SUM(a.followers) as total_followers,
    COUNT(DISTINCT t.track_id) as total_tracks
FROM artists a
LEFT JOIN tracks t ON a.artist_id = t.artist_id
WHERE a.genres IS NOT NULL
GROUP BY genre;

-- View: Device Usage Analytics
-- Problem: Understand platform distribution for UX optimization
CREATE OR REPLACE VIEW vw_device_usage AS
SELECT 
    device_type,
    COUNT(listening_id) as play_count,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(play_duration_ms) / 1000.0 as avg_duration_seconds,
    SUM(play_duration_ms) / 1000.0 / 60.0 / 60.0 as total_hours
FROM user_listening_history
WHERE device_type IS NOT NULL
GROUP BY device_type
ORDER BY play_count DESC;

-- Grant permissions for Looker access (modify as needed)
-- GRANT SELECT ON ALL TABLES IN SCHEMA spotify TO looker_user;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA spotify TO looker_user;
