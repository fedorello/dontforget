from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import create_tables
from app.features.profiles.router import router as profiles_router
from app.features.medicines.router import router as medicines_router
from app.features.shopping.router import router as shopping_router
from app.features.todos.router import router as todos_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    await create_tables()
    yield


app = FastAPI(
    title="DontForget API",
    description="Smart reminders for medications, shopping and tasks",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(profiles_router, prefix="/api/v1")
app.include_router(medicines_router, prefix="/api/v1")
app.include_router(shopping_router, prefix="/api/v1")
app.include_router(todos_router, prefix="/api/v1")


@app.get("/health")
async def health():
    return {"status": "ok", "version": "1.0.0"}


@app.get("/")
async def root():
    return {
        "app": "DontForget API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health",
    }
