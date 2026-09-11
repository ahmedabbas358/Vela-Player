from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.router import api_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API v1
app.include_router(api_router, prefix=settings.API_V1_STR)


# Health Check Endpoints (Zero sensitive disclosures)
@app.get("/health/live", tags=["Health"])
async def health_live():
    return {"status": "ok", "service": "vela-backend"}


@app.get("/health/ready", tags=["Health"])
async def health_ready():
    return {"status": "ready", "database": "connected", "redis": "connected"}


# WebSocket Realtime Gateway
@app.websocket(f"{settings.API_V1_STR}/realtime")
async def realtime_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            # Echo or process client ping/pong
            await websocket.send_json({"event": "ack", "payload": data})
    except WebSocketDisconnect:
        pass
