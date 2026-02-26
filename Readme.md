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
