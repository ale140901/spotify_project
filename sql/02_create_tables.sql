-- Spotify Dashboard Table Creation Script
-- This script creates all necessary tables for the Spotify dashboard

SET search_path TO spotify, public;

-- Table: artists
-- Stores information about music artists
CREATE TABLE IF NOT EXISTS artists (
    artist_id VARCHAR(50) PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL,
    genres TEXT[],
    popularity INTEGER CHECK (popularity >= 0 AND popularity <= 100),
    followers INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: albums
-- Stores album information
CREATE TABLE IF NOT EXISTS albums (
    album_id VARCHAR(50) PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    artist_id VARCHAR(50) REFERENCES artists(artist_id),
    release_date DATE,
    total_tracks INTEGER,
    album_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: tracks
-- Stores detailed track information
CREATE TABLE IF NOT EXISTS tracks (
    track_id VARCHAR(50) PRIMARY KEY,
    track_name VARCHAR(255) NOT NULL,
    album_id VARCHAR(50) REFERENCES albums(album_id),
    artist_id VARCHAR(50) REFERENCES artists(artist_id),
    duration_ms INTEGER,
    explicit BOOLEAN,
    popularity INTEGER CHECK (popularity >= 0 AND popularity <= 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: audio_features
-- Stores audio analysis features for tracks
CREATE TABLE IF NOT EXISTS audio_features (
    track_id VARCHAR(50) PRIMARY KEY REFERENCES tracks(track_id),
    danceability DECIMAL(4,3) CHECK (danceability >= 0 AND danceability <= 1),
    energy DECIMAL(4,3) CHECK (energy >= 0 AND energy <= 1),
    key INTEGER,
    loudness DECIMAL(6,3),
    mode INTEGER,
    speechiness DECIMAL(4,3) CHECK (speechiness >= 0 AND speechiness <= 1),
    acousticness DECIMAL(4,3) CHECK (acousticness >= 0 AND acousticness <= 1),
    instrumentalness DECIMAL(4,3) CHECK (instrumentalness >= 0 AND instrumentalness <= 1),
    liveness DECIMAL(4,3) CHECK (liveness >= 0 AND liveness <= 1),
    valence DECIMAL(4,3) CHECK (valence >= 0 AND valence <= 1),
    tempo DECIMAL(6,3),
    time_signature INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: user_listening_history
-- Stores user listening events
CREATE TABLE IF NOT EXISTS user_listening_history (
    listening_id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    track_id VARCHAR(50) REFERENCES tracks(track_id),
    played_at TIMESTAMP NOT NULL,
    play_duration_ms INTEGER,
    context_type VARCHAR(50),
    device_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_artists_popularity ON artists(popularity);
CREATE INDEX IF NOT EXISTS idx_tracks_popularity ON tracks(popularity);
CREATE INDEX IF NOT EXISTS idx_listening_history_user ON user_listening_history(user_id);
CREATE INDEX IF NOT EXISTS idx_listening_history_played_at ON user_listening_history(played_at);
CREATE INDEX IF NOT EXISTS idx_albums_release_date ON albums(release_date);
