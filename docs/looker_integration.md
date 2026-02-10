# Looker Integration Guide

This guide explains how to integrate the Spotify Dashboard PostgreSQL database with Looker for creating interactive dashboards and visualizations.

## Prerequisites

- Looker account with admin access
- PostgreSQL database with Spotify Dashboard data
- Network access from Looker to your PostgreSQL server

## Step 1: Database Connection

### 1.1 Configure PostgreSQL for Remote Access

Edit your `postgresql.conf` file:
```
listen_addresses = '*'  # or specify Looker's IP
max_connections = 100
```

Edit your `pg_hba.conf` file to allow Looker connection:
```
host    spotify_db    looker_user    <looker_ip>/32    md5
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### 1.2 Create Looker Database User

```sql
-- Create dedicated user for Looker
CREATE USER looker_user WITH PASSWORD 'secure_password';

-- Grant necessary permissions
GRANT CONNECT ON DATABASE spotify_db TO looker_user;
GRANT USAGE ON SCHEMA spotify TO looker_user;
GRANT SELECT ON ALL TABLES IN SCHEMA spotify TO looker_user;
GRANT SELECT ON ALL VIEWS IN SCHEMA spotify TO looker_user;

-- Grant permissions for future tables/views
ALTER DEFAULT PRIVILEGES IN SCHEMA spotify 
GRANT SELECT ON TABLES TO looker_user;
```

### 1.3 Add Connection in Looker

1. Navigate to **Admin > Database > Connections**
2. Click **Add Connection**
3. Configure the connection:
   - **Name**: Spotify Dashboard
   - **Dialect**: PostgreSQL 9.5+
   - **Host**: Your PostgreSQL server IP/hostname
   - **Port**: 5432
   - **Database**: spotify_db
   - **Schema**: spotify
   - **Username**: looker_user
   - **Password**: [your secure password]
4. Click **Test** to verify connection
5. Click **Connect**

## Step 2: Create LookML Project

### 2.1 Create New Project

1. Navigate to **Develop > Projects**
2. Click **New LookML Project**
3. Name it "spotify_dashboard"
4. Select "Blank Project"

### 2.2 Define Connection

Edit `spotify_dashboard.model` file:

```lookml
connection: "spotify_dashboard"

include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard.lookml"

explore: tracks {
  label: "Track Analytics"
  
  join: artists {
    sql_on: ${tracks.artist_id} = ${artists.artist_id} ;;
    relationship: many_to_one
  }
  
  join: albums {
    sql_on: ${tracks.album_id} = ${albums.album_id} ;;
    relationship: many_to_one
  }
  
  join: audio_features {
    sql_on: ${tracks.track_id} = ${audio_features.track_id} ;;
    relationship: one_to_one
  }
}

explore: user_listening_history {
  label: "Listening History"
  
  join: tracks {
    sql_on: ${user_listening_history.track_id} = ${tracks.track_id} ;;
    relationship: many_to_one
  }
  
  join: artists {
    sql_on: ${tracks.artist_id} = ${artists.artist_id} ;;
    relationship: many_to_one
  }
}
```

## Step 3: Create Views

### 3.1 Artists View

Create `views/artists.view.lkml`:

```lookml
view: artists {
  sql_table_name: spotify.artists ;;
  
  dimension: artist_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.artist_id ;;
  }
  
  dimension: artist_name {
    type: string
    sql: ${TABLE}.artist_name ;;
  }
  
  dimension: genres {
    type: string
    sql: array_to_string(${TABLE}.genres, ', ') ;;
  }
  
  dimension: popularity {
    type: number
    sql: ${TABLE}.popularity ;;
  }
  
  dimension: popularity_tier {
    type: tier
    tiers: [50, 70, 90]
    style: integer
    sql: ${popularity} ;;
  }
  
  dimension: followers {
    type: number
    sql: ${TABLE}.followers ;;
  }
  
  measure: count {
    type: count
    drill_fields: [artist_name, popularity, followers]
  }
  
  measure: avg_popularity {
    type: average
    sql: ${popularity} ;;
    value_format_name: decimal_1
  }
  
  measure: total_followers {
    type: sum
    sql: ${followers} ;;
    value_format_name: decimal_0
  }
}
```

### 3.2 Tracks View

Create `views/tracks.view.lkml`:

```lookml
view: tracks {
  sql_table_name: spotify.tracks ;;
  
  dimension: track_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.track_id ;;
  }
  
  dimension: track_name {
    type: string
    sql: ${TABLE}.track_name ;;
  }
  
  dimension: artist_id {
    type: string
    hidden: yes
    sql: ${TABLE}.artist_id ;;
  }
  
  dimension: album_id {
    type: string
    hidden: yes
    sql: ${TABLE}.album_id ;;
  }
  
  dimension: duration_ms {
    type: number
    sql: ${TABLE}.duration_ms ;;
  }
  
  dimension: duration_minutes {
    type: number
    sql: ${duration_ms} / 60000.0 ;;
    value_format_name: decimal_2
  }
  
  dimension: explicit {
    type: yesno
    sql: ${TABLE}.explicit ;;
  }
  
  dimension: popularity {
    type: number
    sql: ${TABLE}.popularity ;;
  }
  
  measure: count {
    type: count
    drill_fields: [track_name, popularity]
  }
  
  measure: avg_popularity {
    type: average
    sql: ${popularity} ;;
    value_format_name: decimal_1
  }
  
  measure: avg_duration_minutes {
    type: average
    sql: ${duration_minutes} ;;
    value_format_name: decimal_2
  }
}
```

### 3.3 Audio Features View

Create `views/audio_features.view.lkml`:

```lookml
view: audio_features {
  sql_table_name: spotify.audio_features ;;
  
  dimension: track_id {
    primary_key: yes
    type: string
    hidden: yes
    sql: ${TABLE}.track_id ;;
  }
  
  dimension: danceability {
    type: number
    sql: ${TABLE}.danceability ;;
    value_format_name: decimal_3
  }
  
  dimension: energy {
    type: number
    sql: ${TABLE}.energy ;;
    value_format_name: decimal_3
  }
  
  dimension: valence {
    type: number
    sql: ${TABLE}.valence ;;
    value_format_name: decimal_3
  }
  
  dimension: tempo {
    type: number
    sql: ${TABLE}.tempo ;;
    value_format_name: decimal_1
  }
  
  dimension: acousticness {
    type: number
    sql: ${TABLE}.acousticness ;;
    value_format_name: decimal_3
  }
  
  dimension: energy_level {
    type: string
    sql: CASE 
           WHEN ${energy} >= 0.7 THEN 'High Energy'
           WHEN ${energy} >= 0.4 THEN 'Medium Energy'
           ELSE 'Low Energy'
         END ;;
  }
  
  dimension: mood {
    type: string
    sql: CASE 
           WHEN ${valence} >= 0.7 THEN 'Happy'
           WHEN ${valence} >= 0.4 THEN 'Neutral'
           ELSE 'Sad'
         END ;;
  }
  
  measure: avg_danceability {
    type: average
    sql: ${danceability} ;;
    value_format_name: decimal_3
  }
  
  measure: avg_energy {
    type: average
    sql: ${energy} ;;
    value_format_name: decimal_3
  }
  
  measure: avg_valence {
    type: average
    sql: ${valence} ;;
    value_format_name: decimal_3
  }
}
```

### 3.4 User Listening History View

Create `views/user_listening_history.view.lkml`:

```lookml
view: user_listening_history {
  sql_table_name: spotify.user_listening_history ;;
  
  dimension: listening_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.listening_id ;;
  }
  
  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }
  
  dimension: track_id {
    type: string
    hidden: yes
    sql: ${TABLE}.track_id ;;
  }
  
  dimension_group: played {
    type: time
    timeframes: [time, date, week, month, quarter, year, hour_of_day, day_of_week]
    sql: ${TABLE}.played_at ;;
  }
  
  dimension: play_duration_ms {
    type: number
    sql: ${TABLE}.play_duration_ms ;;
  }
  
  dimension: play_duration_seconds {
    type: number
    sql: ${play_duration_ms} / 1000.0 ;;
    value_format_name: decimal_1
  }
  
  dimension: context_type {
    type: string
    sql: ${TABLE}.context_type ;;
  }
  
  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
  }
  
  measure: count {
    type: count
    label: "Total Plays"
    drill_fields: [user_id, played_date, count]
  }
  
  measure: unique_users {
    type: count_distinct
    sql: ${user_id} ;;
  }
  
  measure: unique_tracks {
    type: count_distinct
    sql: ${track_id} ;;
  }
  
  measure: total_listening_hours {
    type: sum
    sql: ${play_duration_ms} / 1000.0 / 60.0 / 60.0 ;;
    value_format_name: decimal_1
  }
  
  measure: avg_play_duration_seconds {
    type: average
    sql: ${play_duration_seconds} ;;
    value_format_name: decimal_1
  }
}
```

## Step 4: Create Dashboards

### 4.1 Executive Dashboard

1. Navigate to **Dashboards > New Dashboard**
2. Name it "Spotify Executive Dashboard"
3. Add the following tiles:

**KPI Tiles:**
- Total Plays (last 30 days)
- Unique Users
- Total Listening Hours
- Average Track Popularity

**Visualization Tiles:**
- Top 10 Artists (bar chart)
- Listening by Hour of Day (line chart)
- Listening by Day of Week (column chart)
- Top 10 Tracks (table)
- Device Distribution (pie chart)

### 4.2 Audio Analytics Dashboard

Create visualizations for:
- Energy vs Danceability (scatter plot)
- Audio Features Distribution (box plot)
- Mood Distribution (pie chart)
- Feature Correlation Matrix (heatmap)

### 4.3 User Engagement Dashboard

Create visualizations for:
- Daily Active Users (line chart)
- User Retention (cohort analysis)
- Average Session Duration (metric)
- Platform Usage (stacked bar chart)

## Step 5: Scheduling and Alerts

### 5.1 Schedule Dashboard Delivery

1. Open dashboard
2. Click **gear icon > Schedule**
3. Configure:
   - Recipients
   - Frequency (daily/weekly/monthly)
   - Format (PDF/PNG)
   - Filters

### 5.2 Create Alerts

1. Create a Look for the metric
2. Click **gear icon > Alerts**
3. Set conditions:
   - Metric threshold
   - Comparison operator
   - Alert frequency
4. Add recipients

## Best Practices

1. **Performance Optimization**
   - Use aggregate tables for frequently queried data
   - Create persistent derived tables (PDTs) for complex calculations
   - Add indexes on join keys and filter columns

2. **Security**
   - Use row-level security for user-specific data
   - Implement access controls on dashboards
   - Regularly rotate database passwords

3. **Maintenance**
   - Schedule regular data refreshes
   - Monitor query performance
   - Archive old listening history data

4. **User Experience**
   - Create multiple dashboards for different audiences
   - Use filters and drill-downs for exploration
   - Document metrics and dimensions

## Troubleshooting

### Connection Issues
- Verify network connectivity
- Check firewall rules
- Confirm database credentials

### Performance Issues
- Review SQL queries in Looker's SQL Runner
- Add database indexes
- Use aggregate tables

### Data Inconsistencies
- Verify data types match between database and LookML
- Check for NULL values
- Validate date/time formatting

## Additional Resources

- [Looker Documentation](https://docs.looker.com/)
- [LookML Reference](https://docs.looker.com/reference)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Performance_Optimization)
