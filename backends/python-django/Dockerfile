FROM python:3.14-slim
WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY pyproject.toml uv.lock .
RUN uv sync --frozen --no-install-project
COPY . .
EXPOSE 8080
CMD ["sh", "-c", "uv run python manage.py runserver 0.0.0.0:${PORT:-8080}"]
