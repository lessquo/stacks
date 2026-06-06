from http import HTTPStatus

from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy.exc import IntegrityError
from starlette.exceptions import HTTPException

UNIQUE_VIOLATION = "23505"


def problem(status: int, detail: str) -> JSONResponse:
    return JSONResponse(
        status_code=status,
        media_type="application/problem+json",
        content={
            "status": status,
            "title": HTTPStatus(status).phrase,
            "detail": detail,
        },
    )


async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    return problem(exc.status_code, exc.detail)


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    detail = "; ".join(
        f"{'.'.join(str(p) for p in err['loc'][1:])}: {err['msg']}"
        for err in exc.errors()
    )
    return problem(HTTPStatus.BAD_REQUEST, detail)


async def integrity_error_handler(
    request: Request, exc: IntegrityError
) -> JSONResponse:
    if getattr(exc.orig, "sqlstate", None) == UNIQUE_VIOLATION:
        return problem(HTTPStatus.CONFLICT, "Email already exists")
    raise exc
