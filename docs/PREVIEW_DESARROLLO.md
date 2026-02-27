# Preview de Desarrollo

## Rama de trabajo
- Desarrollo: `feature/*`
- Integración: `develop`
- Release: `main` + tag

## ¿Dónde ejecutar cada cosa?

### 2.1 Tests de aplicación
Carpeta:
- `src/microservicios/catalogo`
- `src/microservicios/reservas`

Comandos:
```bash
python -m venv .venv
pip install -r requirements.txt
pip install -r requirements-dev.txt
pytest -q --junitxml=reportes/junit.xml
```

### 2.2 Calidad de aplicación - SonarQube local
Carpeta:
- `serverapps`

Comandos:
```bash
docker compose -f docker-compose.sonarqube.yml up -d
```

Luego, en cada microservicio:
```bash
sonar-scanner
```

### 2.3 Vulnerabilidades - Checkov
Carpeta:
- `serverapps`

Comandos:
```bash
docker compose -f docker-compose.checkov.yml run --rm checkov
```

### 2.4 Infraestructura - Terraform
Carpeta:
- `iac/terraform`

Comandos:
```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

### 2.5 Observabilidad - Demostración final
Servicios:
- CloudWatch (Logs, Insights, Alarms)
- X-Ray (Tracing)

Demostración:
1. Usuario final hace búsqueda/reserva.
2. Se evidencian logs en CloudWatch.
3. Se evidencian trazas en X-Ray.
4. Se evidencian métricas y, si aplica, alarmas.