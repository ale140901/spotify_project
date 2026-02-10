-- Spotify Dashboard Database Creation Script
-- This script creates the database for the Spotify analytics dashboard

-- Create database
CREATE DATABASE IF NOT EXISTS spotify_db;

-- Connect to the database
\c spotify_db;

-- Create schema for organizing tables
CREATE SCHEMA IF NOT EXISTS spotify;

-- Set search path
SET search_path TO spotify, public;
