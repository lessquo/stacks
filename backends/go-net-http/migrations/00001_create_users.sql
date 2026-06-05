-- +goose Up
create table users (
  id         uuid        primary key default uuidv7(),
  email      text        not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- +goose Down
drop table users;
