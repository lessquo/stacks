from typing import Annotated
from uuid import UUID

from fastapi import Depends, FastAPI, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession

from db import get_session
from models import User
from schemas import CreateUser, UserResponse

app = FastAPI()

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
async def get_user(user_id: UUID, session: SessionDep):
    user = await session.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404)
    return user
