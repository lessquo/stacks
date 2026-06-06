from fastapi import FastAPI, Response

app = FastAPI()


@app.get("/")
async def health_check() -> Response:
    return Response(status_code=200)
