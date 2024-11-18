package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"os"
	"time"

	models "github.com/dirtboll/news/db/sqlc"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ctxKey int
const (
	ctxDBPool ctxKey = iota
)

var dbPool *pgxpool.Pool
var logErr *log.Logger

func main() {
	var err error
	logErr = log.New(os.Stderr, "", 1)

	r := chi.NewRouter()
	ctx := context.Background()

	dbPool, err = initDatabase(ctx)
	if err != nil {
		log.Fatalf("FATAL: Failed to initialize database: %s", err)
	}

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(60 * time.Second))
	r.Use(DatabaseCtx)

	r.Get("/news", getLatestNews)
	r.Get("/_healthz", healthCheck)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	hostPort := os.Getenv("HOST") + ":" + port
	log.Print("INFO: Listening on " + hostPort)
	http.ListenAndServe(hostPort, r)
}

func initDatabase(ctx context.Context) (*pgxpool.Pool, error) {
	log.Print("INFO: Initializing database")

	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		return nil, errors.New("database URL must be set with environment variable DATABASE_URL")
	}
	
	pool, err := pgxpool.New(ctx, dbUrl)
	if err != nil {
		return nil, err
	}

	return pool, nil
}

func DatabaseCtx(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := context.WithValue(r.Context(), ctxDBPool, dbPool)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func getLatestNews(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	dbPool, ok := ctx.Value(ctxDBPool).(*pgxpool.Pool)
	if !ok {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		logErr.Printf("ERROR: Unable to get database connection pool using request context.")
		return
	}

	q := models.New(dbPool)
	news, err := q.GetLatestNews(ctx)

	if err == sql.ErrNoRows {
		http.NotFound(w, r)
		return
	}

	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		logErr.Printf("ERROR: Failed to get latest news: %s", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(news)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}
