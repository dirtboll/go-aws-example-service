include .env
export $(shell sed 's/=.*//' .env)

build:
	@go build -o ./bin/news ./
.PHONY: build

buildProd:
	@CGO_ENABLED=0 go build -ldflags="-s -w" -o ./bin/news ./
	@upx --brute ./bin/news
.PHONY: build

run:
	@go run main.go
.PHONY: build

_checkDb:
	@if [ -z "${DATABASE_URL}" ]; then \
		echo "Error: Environment variable \"DATABASE_URL\" must be set!"; \
		exit 1; \
	fi
.PHONY: _checkDb

migrationCreate:
	@if [ -z "${MIGRATION_NAME}" ]; then \
		echo "Error: Environment variable \"MIGRATION_NAME\" must be set!"; \
		exit 1; \
	fi
	@goose create ${MIGRATION_NAME} sql -dir db/migrations
.PHONY: migrationCreate

migrationUp: _checkDb
	@GOOSE_DRIVER=postgres GOOSE_DBSTRING=${DATABASE_URL} goose up -dir db/migrations
.PHONY: migrationUp

migrationDown: _checkDb
	@GOOSE_DRIVER=postgres GOOSE_DBSTRING=${DATABASE_URL} goose down -dir db/migrations
.PHONY: migrationDown

migrationStatus: _checkDb
	@GOOSE_DRIVER=postgres GOOSE_DBSTRING=${DATABASE_URL} goose status -dir db/migrations
.PHONY: migrationStatus

schemaDiff: _checkDb
	@pg-schema-diff plan --dsn ${DATABASE_URL} --schema-dir ./db/schema  --exclude-schema _goose.sql
.PHONY: schemaDiff

schemaApply: _checkDb
	@pg-schema-diff apply --dsn ${DATABASE_URL} --schema-dir ./db/schema --exclude-schema _goose.sql --allow-hazards="${ALLOW_HAZARDS}"
.PHONY: schemaApply

schemaGen:
	@sqlc generate
.PHONY: schemaGen

insertDummy: _checkDb
	@psql "${DATABASE_URL}" < db/dummy/news.sql
.PHONY: insertDummy
