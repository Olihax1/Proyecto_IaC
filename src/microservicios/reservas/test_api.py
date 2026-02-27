from fastapi.testclient import TestClient
from app import api

cliente = TestClient(api)

def test_salud():
    r = cliente.get("/salud")
    assert r.status_code == 200