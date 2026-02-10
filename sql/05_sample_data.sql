-- Spotify Dashboard - Sample Data Insertion
-- This script provides sample data for testing and demonstration

SET search_path TO spotify, public;

-- Insert sample artists
INSERT INTO artists (artist_id, artist_name, genres, popularity, followers) VALUES
('artist_001', 'The Weeknd', ARRAY['pop', 'r&b', 'canadian pop'], 95, 85000000),
('artist_002', 'Taylor Swift', ARRAY['pop', 'country', 'singer-songwriter'], 98, 92000000),
('artist_003', 'Drake', ARRAY['hip hop', 'rap', 'canadian hip hop'], 96, 78000000),
('artist_004', 'Bad Bunny', ARRAY['reggaeton', 'latin', 'trap latino'], 94, 65000000),
('artist_005', 'Ed Sheeran', ARRAY['pop', 'singer-songwriter', 'acoustic pop'], 93, 88000000),
('artist_006', 'Ariana Grande', ARRAY['pop', 'r&b'], 92, 81000000),
('artist_007', 'Billie Eilish', ARRAY['pop', 'alternative', 'electropop'], 91, 76000000),
('artist_008', 'Post Malone', ARRAY['pop', 'hip hop', 'rap'], 90, 59000000),
('artist_009', 'Dua Lipa', ARRAY['pop', 'dance pop'], 89, 72000000),
('artist_010', 'Harry Styles', ARRAY['pop', 'rock', 'pop rock'], 88, 58000000)
ON CONFLICT (artist_id) DO NOTHING;

-- Insert sample albums
INSERT INTO albums (album_id, album_name, artist_id, release_date, total_tracks, album_type) VALUES
('album_001', 'After Hours', 'artist_001', '2020-03-20', 14, 'album'),
('album_002', 'Midnights', 'artist_002', '2022-10-21', 13, 'album'),
('album_003', 'Certified Lover Boy', 'artist_003', '2021-09-03', 21, 'album'),
('album_004', 'Un Verano Sin Ti', 'artist_004', '2022-05-06', 23, 'album'),
('album_005', 'Equals', 'artist_005', '2021-10-29', 14, 'album'),
('album_006', 'Positions', 'artist_006', '2020-10-30', 14, 'album'),
('album_007', 'Happier Than Ever', 'artist_007', '2021-07-30', 16, 'album'),
('album_008', 'Hollywood\'s Bleeding', 'artist_008', '2019-09-06', 17, 'album'),
('album_009', 'Future Nostalgia', 'artist_009', '2020-03-27', 11, 'album'),
('album_010', 'Harry\'s House', 'artist_010', '2022-05-20', 13, 'album')
ON CONFLICT (album_id) DO NOTHING;

-- Insert sample tracks
INSERT INTO tracks (track_id, track_name, album_id, artist_id, duration_ms, explicit, popularity) VALUES
('track_001', 'Blinding Lights', 'album_001', 'artist_001', 200040, false, 95),
('track_002', 'Anti-Hero', 'album_002', 'artist_002', 200690, false, 93),
('track_003', 'Way 2 Sexy', 'album_003', 'artist_003', 257960, true, 91),
('track_004', 'Tití Me Preguntó', 'album_004', 'artist_004', 225047, false, 88),
('track_005', 'Shivers', 'album_005', 'artist_005', 207160, false, 90),
('track_006', 'positions', 'album_006', 'artist_006', 172163, true, 87),
('track_007', 'Happier Than Ever', 'album_007', 'artist_007', 298650, false, 85),
('track_008', 'Circles', 'album_008', 'artist_008', 215280, false, 92),
('track_009', 'Levitating', 'album_009', 'artist_009', 203064, false, 94),
('track_010', 'As It Was', 'album_010', 'artist_010', 167303, false, 96)
ON CONFLICT (track_id) DO NOTHING;

-- Insert sample audio features
INSERT INTO audio_features (track_id, danceability, energy, key, loudness, mode, speechiness, 
                            acousticness, instrumentalness, liveness, valence, tempo, time_signature) VALUES
('track_001', 0.514, 0.730, 1, -5.934, 1, 0.0598, 0.00146, 0.0000914, 0.0897, 0.334, 171.005, 4),
('track_002', 0.650, 0.580, 5, -6.760, 1, 0.0450, 0.120, 0.00000, 0.110, 0.420, 97.008, 4),
('track_003', 0.680, 0.610, 7, -4.560, 0, 0.0890, 0.021, 0.00000, 0.140, 0.510, 90.000, 4),
('track_004', 0.720, 0.690, 9, -5.120, 1, 0.0670, 0.089, 0.00000, 0.095, 0.610, 112.004, 4),
('track_005', 0.655, 0.825, 9, -5.230, 1, 0.0450, 0.022, 0.00000, 0.078, 0.438, 141.016, 4),
('track_006', 0.735, 0.677, 0, -6.230, 1, 0.0550, 0.159, 0.00000, 0.123, 0.621, 90.063, 4),
('track_007', 0.540, 0.430, 6, -11.480, 1, 0.0370, 0.320, 0.00000, 0.110, 0.220, 120.043, 4),
('track_008', 0.695, 0.762, 0, -4.771, 1, 0.0395, 0.178, 0.00000, 0.144, 0.553, 120.042, 4),
('track_009', 0.702, 0.825, 6, -3.787, 0, 0.0601, 0.008, 0.00000, 0.092, 0.915, 103.007, 4),
('track_010', 0.518, 0.732, 1, -5.396, 1, 0.0465, 0.129, 0.00000, 0.113, 0.396, 173.994, 4)
ON CONFLICT (track_id) DO NOTHING;

-- Insert sample user listening history
INSERT INTO user_listening_history (user_id, track_id, played_at, play_duration_ms, context_type, device_type) VALUES
('user_001', 'track_001', CURRENT_TIMESTAMP - INTERVAL '1 hour', 200040, 'playlist', 'mobile'),
('user_001', 'track_002', CURRENT_TIMESTAMP - INTERVAL '2 hours', 200690, 'playlist', 'mobile'),
('user_002', 'track_009', CURRENT_TIMESTAMP - INTERVAL '30 minutes', 203064, 'album', 'desktop'),
('user_002', 'track_010', CURRENT_TIMESTAMP - INTERVAL '1 day', 167303, 'search', 'mobile'),
('user_003', 'track_003', CURRENT_TIMESTAMP - INTERVAL '3 hours', 257960, 'playlist', 'speaker'),
('user_003', 'track_005', CURRENT_TIMESTAMP - INTERVAL '5 hours', 207160, 'radio', 'mobile'),
('user_004', 'track_007', CURRENT_TIMESTAMP - INTERVAL '2 days', 298650, 'album', 'desktop'),
('user_004', 'track_008', CURRENT_TIMESTAMP - INTERVAL '4 hours', 215280, 'playlist', 'web'),
('user_005', 'track_001', CURRENT_TIMESTAMP - INTERVAL '6 hours', 200040, 'search', 'mobile'),
('user_005', 'track_004', CURRENT_TIMESTAMP - INTERVAL '1 day', 225047, 'playlist', 'mobile'),
('user_001', 'track_006', CURRENT_TIMESTAMP - INTERVAL '8 hours', 172163, 'radio', 'speaker'),
('user_002', 'track_001', CURRENT_TIMESTAMP - INTERVAL '12 hours', 200040, 'playlist', 'desktop'),
('user_003', 'track_009', CURRENT_TIMESTAMP - INTERVAL '15 hours', 203064, 'album', 'mobile'),
('user_004', 'track_002', CURRENT_TIMESTAMP - INTERVAL '20 hours', 200690, 'search', 'web'),
('user_005', 'track_010', CURRENT_TIMESTAMP - INTERVAL '1 day', 167303, 'playlist', 'mobile');

-- Verify data insertion
SELECT 'Artists' as table_name, COUNT(*) as record_count FROM artists
UNION ALL
SELECT 'Albums', COUNT(*) FROM albums
UNION ALL
SELECT 'Tracks', COUNT(*) FROM tracks
UNION ALL
SELECT 'Audio Features', COUNT(*) FROM audio_features
UNION ALL
SELECT 'Listening History', COUNT(*) FROM user_listening_history;
