import json
import os
import logging

logging.basicConfig(level=os.getenv("NIVEL_LOG", "INFO"))
logger = logging.getLogger("compensacion")

def handler(evento, contexto):
    logger.info("evento_sqs_recibido", extra={"registros": len(evento.get("Records", []))}) # Log entrada

    for registro in evento.get("Records", []):
        cuerpo = registro.get("body", "{}")
        try:
            mensaje = json.loads(cuerpo)
        except json.JSONDecodeError:
            mensaje = {"cuerpo_raw": cuerpo}

        logger.warning("compensacion", extra={"mensaje": mensaje}) # Accion compensatoria

    return {"estado": "ok"}