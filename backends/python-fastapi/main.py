from typing import Annotated
from uuid import UUID

from fastapi import Depends, FastAPI, HTTPException, Response
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.exceptions import HTTPException as StarletteHTTPException

from db import get_session
from models import User
from problem import (
    http_exception_handler,
    integrity_error_handler,
    validation_exception_handler,
)
from schemas import CreateUser, UserResponse

app = FastAPI()
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(IntegrityError, integrity_error_handler)

SessionDep = Annotated[AsyncSession, Depends(get_session)]


@app.get("/")
async def health_check() -> Response:
    return Response(status_code=200)


@app.post("/users", status_code=201, response_model=UserResponse)
async def create_user(body: CreateUser, session: SessionDep):
    user = User(email=body.email)
    session.add(user)
    await session.commit()
    return user


@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: str, session: SessionDep):
    try:
        uid = UUID(user_id)
    except ValueError:
        raise HTTPException(status_code=404)
    user = await session.get(User, uid)
    if user is None:
        raise HTTPException(status_code=404)
    return user
