#!/bin/sh
set eux

GOOSE_DRIVER=postgres GOOSE_DBSTRING=${GOOSE_DBSTRING:?Environment variable GOOSE_DBSTRING must be set} ./goose up -dir ./migrations
exec ./news