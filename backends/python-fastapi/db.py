import os

from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

DATABASE_URL = (
    f"postgresql+asyncpg://{os.environ.get('DB_USER', 'stacks')}:"
    f"{os.environ.get('DB_PASSWORD', 'stacks')}@"
    f"{os.environ.get('DB_HOST', 'localhost')}:"
    f"{os.environ.get('DB_PORT', '5432')}/"
    f"{os.environ.get('DB_NAME', 'stacks')}"
)

engine = create_async_engine(DATABASE_URL)
async_session = async_sessionmaker(engine, expire_on_commit=False)
