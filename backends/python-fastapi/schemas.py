from datetime import datetime
from typing import Annotated
from uuid import UUID

from email_validator import EmailNotValidError, validate_email
from pydantic import AfterValidator, AliasGenerator, BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


def _validate_email(value: str) -> str:
    try:
        validate_email(value, check_deliverability=False)
    except EmailNotValidError as exc:
        raise ValueError(str(exc)) from exc
    return value


# Validate the address but keep the client's original string — EmailStr would
# normalize (e.g. punycode -> Unicode), breaking the spec's `format: email`.
Email = Annotated[str, AfterValidator(_validate_email)]


class CreateUser(BaseModel):
    email: Email


class UserResponse(BaseModel):
    model_config = ConfigDict(
        from_attributes=True,
        alias_generator=AliasGenerator(serialization_alias=to_camel),
    )

    id: UUID
    email: str
    created_at: datetime
    updated_at: datetime
