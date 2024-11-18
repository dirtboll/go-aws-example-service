-- +goose Up
-- +goose StatementBegin
CREATE TABLE "public"."news" (
        "created_at" timestamp without time zone NOT NULL,
        "updated_at" timestamp without time zone,
        "deleted_at" timestamp without time zone,
        "id" text COLLATE "pg_catalog"."default" NOT NULL,
        "title" text COLLATE "pg_catalog"."default" NOT NULL,
        "content" text COLLATE "pg_catalog"."default" NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS "news";
-- +goose StatementEnd
