FROM golang:1.23.3-alpine3.20 AS buildbase

FROM buildbase AS buildgoose

WORKDIR /build
RUN apk add --no-cache git upx \
 && git clone https://github.com/pressly/goose . \
 && git checkout tags/v3.22.1 \
 && go build -ldflags="-s -w" -tags='no_clickhouse no_mssql no_mysql no_sqlite3 no_turso no_vertica no_ydb' -o goose ./cmd/goose \
 && upx --brute goose

FROM buildbase as buildapp

WORKDIR /build
RUN apk add --no-cache make upx
COPY . .
RUN touch .env \
 && make buildProd

FROM alpine:3.20 as runtime

WORKDIR /app
COPY --from=buildApp /build/bin/news .
COPY --from=buildGoose /build/goose .
COPY build/entrypoint.sh .
COPY db/migrations /app/migrations
RUN chmod +x entrypoint.sh \
 && chmod +x news \
 && chmod +x goose \
 && chown -R nobody:nogroup /app

USER nobody
ENTRYPOINT [ "./entrypoint.sh" ]