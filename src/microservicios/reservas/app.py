from fastapi import FastAPI, APIRouter, Header, HTTPException
from pydantic import BaseModel
import os
import uuid
import json
import logging
import boto3
from botocore.exceptions import BotoCoreError, ClientError

api = FastAPI(title="SeaBook - Reservas")

router = APIRouter(prefix="/api/reservas")

@router.get("/salud")
def salud():
    return {"ok": True, "servicio": "reservas"}

api.include_router(router)

logging.basicConfig(level=os.getenv("NIVEL_LOG", "INFO"))
logger = logging.getLogger("reservas")

class SolicitudReserva(BaseModel):
    id_libro: str
    id_usuario: str

class RespuestaReserva(BaseModel):
    correlacion_id: str
    estado: str
    mensaje: str

def obtener_correlacion_id(cabecera: str | None) -> str:
    return cabecera or str(uuid.uuid4())

def publicar_sns(mensaje: dict, sns_tema_arn: str):
    cliente = boto3.client("sns", region_name=os.getenv("AWS_REGION"))
    cliente.publish(
        TopicArn=sns_tema_arn,
        Message=json.dumps(mensaje, ensure_ascii=False),
    )


@api.post("/reservas", response_model=RespuestaReserva)
def crear_reserva(payload: SolicitudReserva, x_correlation_id: str | None = Header(default=None)):
    correlacion_id = obtener_correlacion_id(x_correlation_id)
    sns_tema_arn = os.getenv("SNS_TEMA_ARN")

    evento = {
        "tipo": "reserva",
        "correlacion_id": correlacion_id,
        "id_libro": payload.id_libro,
        "id_usuario": payload.id_usuario,
    }

    logger.info("solicitud_reserva", extra=evento) # Log auditorIa

    if not sns_tema_arn:
        raise HTTPException(status_code=500, detail="Falta SNS_TEMA_ARN para publicar evento.")

    try:
        publicar_sns(evento, sns_tema_arn)
    except (BotoCoreError, ClientError) as e:
        logger.error("fallo_sns", extra={"correlacion_id": correlacion_id, "error": str(e)})
        raise HTTPException(status_code=502, detail="No se pudo publicar evento en SNS.")

    return RespuestaReserva(
        correlacion_id=correlacion_id,
        estado="encolado",
        mensaje="Reserva enviada a SNS -> SQS FIFO para procesamiento asíncrono.",
    )