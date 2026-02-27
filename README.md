# UNIVERSIDAD PRIVADA ANTENOR ORREGO

# ESCUELA DE INGENIERÍA DE SISTEMAS E INTELIGENCIA ARTIFICIAL

**Integrantes:**
- Anton Figueroa, Raul
- Chavez Segura, Cristhoper
- Rivera Chamorro, Kristel
- Saldaña Ylquimiche, Oliver
- Velasquez Avalos, Marycielo

**Docente:**
- Leturia Rodriguez, Walter Ivan

**Curso:**
Infraestructura como código

### PROBLEMA

SeaBook es una plataforma digital crítica encargada de gestionar los préstamos bibliotecarios para toda la comunidad de la UTP en sus 15 campus a nivel nacional de la UTP. Para atender la magnitud de la falla actual, es vital comprender el Perfil Operativo y de Carga al que está sometido el sistema:

- Usuarios totales en el sistema: más de 150.000 usuarios registrados, abarcando estudiantes, docentes, personal administrativo y bibliotecarios.
- Usuarios concurrentes ( simultáneos): En momentos de estrés, el sistema recibe hasta 15 000 usuarios conectados a la vez, enviando solicitudes ( clics, búsquedas, reservas) en el mismo segundo.
- Periodos críticos de actividad: la carga máxima ocurre diariamente en horas pico ( 10:00 a 11:00 am y 10:00 a 11:00 pm), y de forma estacional durante eventos críticos como inicios de semestre y semanas de exámenes.
- Tiempo de disponibilidad exigido: el servicio requiere estar en línea 24/7 ( 99.99% de uptime) para asegurar el acceso continuo al material de estudio; no hay margen para "apagar el sistema por mantenimiento".

Sin embargo, la plataforma fue construida bajo una arquitectura monolítica que ha sido superada por el crecimiento demográfico de la universidad. Esta limitación estructural genera problemas críticos:

1. Incapacidad para manejar la concurrencia: Durante los periodos de actividad anteriormente mencionado, el monolito no logra procesar las estimadas 15.000 solicitudes concurrentes. Esto provoca un cuello de botella que eleva los tiempos de respuesta de más de 2 minutos por acción.

2. Falta de tolerancia a fallos: al ser una arquitectura monolítica, un error en un proceso específico (ej. módulo de reservas) compromete todo el entorno, causando caídas totales del sistema. En una biblioteca, si un usuario intenta reservar un libro y el sistema falla, no solo falla esa reserva, sino que también dejan de funcionar el catálogo de búsqueda, el registro de nuevos lectores y la consulta de multas, dejando la biblioteca totalmente inoperativa.

3. Afectación de la Disponibilidad: Estas interrupciones merman drásticamente la disponibilidad del servicio, frustrando la experiencia de los usuarios e interrumpiendo las operaciones académicas diarias. Esto impide que los alumnos busquen libros en el catálogo o consulten sus fechas de devolución, paralizando las actividades académicas y generando frustración al dejar a toda la comunidad sin acceso a la información.

### La solución es clara:

Para superar estas limitaciones, se propone la migración de SeaBook hacia una arquitectura moderna y nativa en la nube utilizando Amazon Web Services ( AWS). Abandonaremos el enfoque monolítico tradicional para adoptar un modelo distribuido, garantizando la disponibilidad, escalamiento elástico ante la demanda estudiantil, seguridad de los datos y agilidad en las actualizaciones. En esta nueva arquitectura, sostenemos los siguientes pilares:

### 1. Escalabilidad automática ( Auto-Scaling) para Picos de Tráfico:

Se implementarán balanceadores de carga ( ELB) junto con grupos de autoescalado. El sistema detectará automáticamente los periodos críticos de actividad (ej. a las 10:00 am). Si la concurrencia se acerca a los 15000 usuarios, AWS aprovisionará nuevos servidores en tiempo real para garantizar tiempos de respuesta inferiores a 2 segundos. Pasada la hora pico, los servidores extra se apagarán para optimizar costos.

### 2. Desacoplamiento y tolerancia a fallos ( High Availability):

El sistema pasará a ser una arquitectura distribuida ( microservicios o contenedores) distribuida desplegada en Múltiples Zonas de

### 3. Persistencia, Backups y Gestión de Data a Gran Escala:

El sistema está diseñado para soportar la enorme cantidad de data que genera la universidad: se proyecta procesar más de 1 millón de transacciones mensuales, generando hasta 2TB de data en el primer año (con proyección escalar a 100 TB). Para proteger esto, se implementarán Backups automatizados continuos y Snapshots incrementales cada 5 minutos, garantizando que ante cualquier desastre la pérdida de información sea prácticamente nula.

### 4. Seguridad Robusta y Cumplimiento:

Se aislará la base de datos de los estudiantes y el catálogo en redes privadas (VPC), implementando firewalls de aplicaciones web (WAF) y gestión estricta de identidades (IAM). Esto protegerá la información personal de 150000 usuarios contra ataques externos ( ataques DDoS que simulan picos de tráfico).

### 5. Pipeline de Despliegue Automatizado (CI/CD):

Se establecerá un flujo de integración y Entrega Continua para el equipo de TI de la UTP. Las actualizaciones o correcciones del sistema, se podrán lanzar de forma automatizada y sin necesidad de "apagar" el sistema o generar ventanas de mantenimiento, cumpliendo con la exigencia de disponibilidad ininterrumpida.

---
##  Arquitectura General

<img width="3684" height="1717" alt="diagram-export-2-26-2026-4_00_34-PM" src="https://github.com/user-attachments/assets/156e0e0a-c8e2-408e-b862-3e8ba20c87d8" />


##  Requerimientos No Funcionales y Tecnologías AWS

###  Rendimiento

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 1 | Procesar el 95% de solicitudes en < 2 segundos con 15,000 usuarios simultáneos | **ALB**, ECS Service Auto Scaling, CloudWatch | El ALB distribuye tráfico a tareas ECS Fargate; CloudWatch activa el autoscalado dinámico de contenedores según demanda. |
| 2 | Búsquedas en catálogo desde los 15 campus en < 300 ms | **Aurora Read Réplicas**, ElastiCache (Redis) | ElastiCache crea una capa de caché en memoria para consultas frecuentes, reduciendo la carga en Aurora. |
| 3 | Soportar ráfagas de login de 15,000 usuarios en el mismo segundo | **Amazon Cognito**, AWS WAF, ALB | WAF aplica rate limiting; el ALB integra autenticación Cognito antes de que el tráfico llegue a los microservicios. |
| 4 | Portal web cargando en < 1.5 segundos desde Lima, Trujillo y Arequipa | **Amazon CloudFront**, S3, ACM | Recursos estáticos en S3 distribuidos mediante CloudFront con puntos de presencia locales. |

###  Escalabilidad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 5 | Aprovisionar nuevos contenedores en < 45 segundos al acercarse a 15,000 usuarios | **Amazon ECS**, Fargate, CloudWatch Alarms, SQS | CloudWatch dispara el autoscalado; SQS amortigua solicitudes durante el tiempo de arranque. |
| 6 | Apagar contenedores excedentes automáticamente después de las 11 pm | **ECS Scheduled Scaling**, Cost Explorer, Budgets | Scheduled Scaling ejecuta el scale-in programado; Fargate cobra solo por segundos consumidos. |
| 7 | Soportar crecimiento de 2 TB a 100 TB en 3 años sin degradación | **Aurora Storage**, S3 Intelligent-Tiering, Glacier | Aurora escala hasta 128 TB automáticamente; Lifecycle Policies mueven datos históricos a Glacier. |
| 8 | Escalar de 15,000 a 25,000 usuarios en 2 años sin refactorizar código | **Amazon ECS**, Fargate, ECR, ECS Service Auto Scaling | ECS orquesta microservicios serverless; ECR versiona imágenes para escalabilidad inmediata. |

###  Disponibilidad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 9 | 99.99% de uptime (máx. 4.38 min de caída mensual) en 3 zonas geográficas | **Multi-AZ Deployment**, Route 53, Global Accelerator, Aurora Global Database | Route 53 redirige fallos en segundos; Aurora Global Database mantiene réplicas sincronizadas entre regiones. |
| 10 | Redirigir tráfico a zona sana en < 5 segundos ante caída total de un datacenter | **Route 53**, Global Accelerator, ALB Health Checks, CloudWatch Synthetics | Global Accelerator reduce el failover a nivel de red (anycast); Synthetics detecta fallos antes que los usuarios. |
| 11 | Si falla el microservicio de reservas, catálogo y login siguen operando | **Amazon ECS Fargate**, AWS Cloud Map, AWS X-Ray | Aislamiento por microservicios; Cloud Map para service discovery dinámico; X-Ray para trazabilidad inter-servicio. |

###  Tolerancia a Fallos

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 12 | Encolar asíncronamente +15,000 clics de reserva sin perder información | **Amazon SQS**, Lambda, SNS, DLQ | Lambda procesa mensajes asíncronamente; DLQ retiene mensajes fallidos para re-procesamiento sin pérdida. |
| 13 | Reintentos automáticos hasta 3 veces antes de arrojar error al estudiante | **AWS SDK (App Retries)**, SQS Redrive Policy, X-Ray | SDK con exponential backoff para comunicaciones síncronas; SQS gestiona reintentos para procesos asíncronos. |

###  Concurrencia

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 14 | Resolver conflictos de reservas concurrentes en < 100 ms | **Aurora Row-Level Locking**, ElastiCache Redis (SETNX), Lambda, SQS FIFO | Redis SETNX implementa locks distribuidos ultrarrápidos; SQS FIFO garantiza procesamiento ordenado por libro. |

### Recuperabilidad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 15 | Snapshots incrementales continuos con RPO máximo de 5 minutos | **AWS Backup**, Aurora Continuous Backup, S3 Versioning | Aurora Continuous Backup captura cambios en tiempo real (PITR con RPO de segundos); S3 Versioning protege archivos. |
| 16 | RTO < 15 minutos para restaurar desde zonas secundarias ante desastre en Lima | **Terraform**, Aurora Global Database | Terraform recrea la infraestructura automáticamente; Aurora Global Database permite promover réplica secundaria en < 1 minuto. |

###  Seguridad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 17 | Detectar y bloquear ataques DDoS que simulen picos de 15,000 usuarios | **AWS Shield Advanced**, WAF, Firewall Manager, CloudFront | Shield Advanced provee protección DDoS 24/7; CloudFront absorbe tráfico volumétrico antes del origen. |
| 18 | Base de datos y catálogo sin acceso directo a internet | **Amazon VPC**, Security Groups, VPC Endpoints (PrivateLink) | Aurora en subredes privadas; Security Groups como firewall a nivel de recurso; PrivateLink elimina exposición pública. |
| 19 | Cifrado TLS 1.3 en todas las transacciones desde los 15 campus | **AWS Certificate Manager**, ALB, Secrets Manager | ALB gestiona terminación TLS 1.3 con certificados ACM; Secrets Manager rota credenciales automáticamente. |

###  Privacidad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 20 | PII de 150,000 usuarios cifrada en reposo | **AWS KMS**, CloudTrail, S3 SSE-KMS | CloudTrail audita cada uso de llaves KMS; SSE-KMS aplica cifrado nativo a objetos S3. |
| 21 | Anonimizar IDs y nombres antes de exportar datos para analítica | **AWS Glue (ETL)**, S3, Athena, IAM Roles | Glue elimina/cifra campos PII en jobs ETL; Athena consulta datos anonimizados sin moverlos. |

###  Desplegabilidad y Mantenibilidad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 22 | Despliegues con cero segundos de downtime | **Blue/Green Deployment**, CodeDeploy, Route 53 (weighted routing) | CodeDeploy orquesta el cambio de tráfico; la nueva versión debe estar 100% operativa antes de apagar la anterior. |
| 23 | Modificar el módulo de préstamos sin reiniciar la plataforma entera | **AWS CodeBuild**, ECR, Microservicios ECS | Cada microservicio tiene su propio ciclo de vida; CodeBuild genera imágenes solo para el módulo modificado. |
| 24 | Pipeline CI/CD para lanzar parches de seguridad a producción en < 15 minutos | **AWS CodePipeline**, CodeCommit/GitHub, CodeBuild, ECR | Push al repositorio activa el pipeline automáticamente; tests en paralelo y despliegue en ECS Fargate en segundos. |
| 25 | Rollback automático a versión estable en < 5 minutos si hay errores | **CodeDeploy Rollback**, CodePipeline, CloudWatch Alarms, Lambda | CloudWatch detecta errores en métricas; CodePipeline revierte automáticamente; Lambda ejecuta lógica de validación. |

###  Observabilidad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 26 | Asignar Correlation ID al 100% de las peticiones entrantes | **AWS X-Ray**, OpenTelemetry (ADOT), CloudWatch ServiceLens | ADOT instrumenta microservicios automáticamente; ServiceLens une métricas, trazas y logs en un mapa visual. |
| 27 | Alertar a administradores TI si contenedores consumen 85% de memoria | **CloudWatch Alarms + SNS**, Grafana, AWS Chatbot, Container Insights | Container Insights recopila métricas; Chatbot envía alertas SNS a Slack/Teams en tiempo real. |
| 28 | Centralizar logs de auditoría de los 15 campus y retenerlos 1 año | **CloudWatch Logs**, Logs Insights, S3 + Object Lock, Lifecycle Policies | Logs exportados a S3 con Object Lock (inmutabilidad); Lifecycle Policies los mueven a Glacier tras 90 días (-80% costos). |

###  Integridad

| # | Requerimiento | Tecnologías AWS | Descripción |
|---|---------------|-----------------|-------------|
| 29 | Confirmación en dos fases para consistencia de reservas de préstamo | **Amazon Aurora (ACID)**, Lambda, SQS FIFO | SQS FIFO garantiza orden exacto; Lambda de compensación revierte cambios automáticamente ante errores. |

---

##  Stack Tecnológico Principal

```
Compute:      Amazon ECS + AWS Fargate
Database:     Amazon Aurora (Multi-AZ + Global Database)
Cache:        Amazon ElastiCache (Redis)
Messaging:    Amazon SQS (FIFO + DLQ) + Amazon SNS
Storage:      Amazon S3 + Glacier
CDN:          Amazon CloudFront
Security:     AWS WAF + Shield Advanced + KMS + ACM + Secrets Manager
Networking:   VPC + ALB + Route 53 + Global Accelerator
Auth:         Amazon Cognito
Observ.:      CloudWatch + X-Ray + OpenTelemetry
CI/CD:        CodePipeline + CodeBuild + CodeDeploy + ECR
IaC:          Terraform + Checkov
```

---
# SeaBook (AWS + IaC)



## 0) Flujo Git

Ramas:
- main: solo releases (tags, por ejemplo v1.0.0)
- develop: integración
- feature/*: trabajo diario

Comandos sugeridos:
bash
```
git checkout -b feature/infra-inicial
git push -u origin feature/infra-inicial
git tag v1.0.0
git push --tags
```

---

## 1) Requisitos en tu PC

### 1.1 Software
Instalar:
- *Git*
- *Docker Desktop*
- *Python 3.11+*
- *Terraform 1.6+*
- *AWS CLI v2*

Verificación:
bash
```
git --version
docker --version
python --version
terraform -version
aws --version
```

### 1.2 Acceso AWS
Configurar credenciales "perfil":
bash
```
aws configure --profile seabook
aws sts get-caller-identity --profile seabook
```

---

## 2) Estructura de carpetas

- iac/: Infraestructura como Código (Terraform)
- src/: Microservicios, lambdas, frontend
- config/: scripts / ansible (.sh)
- serverapps/: SonarQube, Checkov, Jenkins, Grafana (local)

---

## 3) Desarrollo local para probar endpoints)

### 3.1 Microservicio Catálogo
bash
```
cd src/microservicios/catalogo
python -m venv .venv
# .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app:api --host 0.0.0.0 --port 8001
```

Prueba:
bash
```
curl http://localhost:8001/salud
curl "http://localhost:8001/catalogo/buscar?q=aws"
```

### 3.2 Microservicio Reservas
bash
```
cd src/microservicios/reservas
python -m venv .venv
pip install -r requirements.txt
uvicorn app:api --host 0.0.0.0 --port 8002
```

Prueba:
bash
```
curl http://localhost:8002/salud
curl -X POST http://localhost:8002/reservas   -H "Content-Type: application/json"   -d '{"id_libro":"LIB-001","id_usuario":"USR-999"}'
```

> Advertencia : para publicar a "SNS" se requiere "SNS_TEMA_ARN" y credenciales AWS/IAM. Si no existe, la API devuelve error controlado.

---

## 4) Calidad de aplicación (SonarQube local)

En otra terminal:
bash
```
cd serverapps
docker compose -f docker-compose.sonarqube.yml up -d
```

Abrir:
- SonarQube: http://localhost:9000

Luego (ejemplo con Catálogo):
bash
```
cd src/microservicios/catalogo
pip install -r requirements-dev.txt
pytest -q --junitxml=reportes/junit.xml
sonar-scanner # Sonar scanner requiere token
```

---

## 5) Test de vulnerabilidades (Checkov con Docker Compose)

bash
```
cd serverapps
docker compose -f docker-compose.checkov.yml run --rm checkov
```

---

## 6) Infraestructura (Terraform) en AWS

### 6.1 Variables
# Dominio si se usa ACM/CloudFront con TLS
Copia:
bash
```
cd iac/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edita terraform.tfvars
- region
- prefijo
- dominio 
- certificado_acm_arn


### 6.2 Deploy
bash
```
cd iac/terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

### 6.3 Destroy
bash
```
terraform destroy
```

---

## 7) Observabilidad

### 7.1 Qué se demuestra
- Métricas: ECS (CPU/Memoria) + SQS (mensajes) + Aurora
- Logs: CloudWatch Logs + Logs Insights
- Trazas: X-Ray (microservicios y Lambda)
- Alertas: CloudWatch Alarms -> SNS (notificación)

### 7.2 Demostración final
1. Abrir Frontend CloudFront/S3 y ejecuta una búsqueda.
2. Crea una reserva ALB -> microservicio Reservas.
3. Verifica en CloudWatch:
   - Logs del servicio
   - Métrica de ECS - CPU/Memoria
4. Verificar en X-Ray:
   - Trace con correlation_id propagado
5. Generar una carga, varias reservas y mostrar:
   - Aumento de mensajes en SQS FIFO
   - Alarmas si supera umbral configurado

---

## 8) Archivos clave

- docs/PREVIEW_DESARROLLO.md: guía ordenada
- serverapps/docker-compose.*.yml: SonarQube, Grafana, Jenkins, Checkov
- iac/terraform/: IaC completa
- src/: microservicios, lambda y frontend estático
