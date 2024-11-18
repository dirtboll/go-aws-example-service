-- name: GetLatestNews :one
SELECT * FROM news
ORDER BY created_at DESC LIMIT 1;