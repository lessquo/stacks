from datetime import datetime
from uuid import UUID

from pydantic import AliasGenerator, BaseModel, ConfigDict, EmailStr
from pydantic.alias_generators import to_camel


class CreateUser(BaseModel):
    email: EmailStr


class UserResponse(BaseModel):
    model_config = ConfigDict(
        from_attributes=True,
        alias_generator=AliasGenerator(serialization_alias=to_camel),
    )

    id: UUID
    email: EmailStr
    created_at: datetime
    updated_at: datetime
