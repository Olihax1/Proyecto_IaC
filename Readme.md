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
