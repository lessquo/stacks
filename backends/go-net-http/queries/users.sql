-- name: CreateUser :one
insert into users (email) values ($1) returning *;

-- name: GetUser :one
select * from users where id = $1;
