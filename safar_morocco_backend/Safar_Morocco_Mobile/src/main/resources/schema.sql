-- Schema initialization script - runs before data.sql
-- Fix photo_url column to store Google OAuth2 profile pictures (which have very long URLs)
ALTER TABLE utilisateurs MODIFY COLUMN photo_url LONGTEXT;
