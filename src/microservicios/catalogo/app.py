from fastapi import FastAPI, APIRouter, Header
from pydantic import BaseModel
import os
import time
import uuid
import logging

api = FastAPI(title="SeaBook - Catálogo")

logging.basicConfig(level=os.getenv("NIVEL_LOG", "INFO"))
logger = logging.getLogger("catalogo")

router = APIRouter(prefix="/api/catalogo")


class RespuestaBusqueda(BaseModel):
    correlacion_id: str
    q: str
    resultados: list[str]
    duracion_ms: int


def obtener_correlacion_id(cabecera: str | None) -> str:
    return cabecera or str(uuid.uuid4())


@api.get("/salud")
def salud_raiz():
    return {"ok": True, "servicio": "catalogo"}


@router.get("/salud")
def salud_api():
    return {"ok": True, "servicio": "catalogo"}


@router.get("/buscar", response_model=RespuestaBusqueda)
def buscar(q: str, x_correlation_id: str | None = Header(default=None)):
    inicio = time.time()
    correlacion_id = obtener_correlacion_id(x_correlation_id)

    logger.info("busqueda", extra={"correlacion_id": correlacion_id, "q": q})

    resultados = [f"LIB-{i:03d}-{q.upper()}" for i in range(1, 6)]
    duracion_ms = int((time.time() - inicio) * 1000)

    return RespuestaBusqueda(
        correlacion_id=correlacion_id,
        q=q,
        resultados=resultados,
        duracion_ms=duracion_ms,
    )


api.include_router(router)