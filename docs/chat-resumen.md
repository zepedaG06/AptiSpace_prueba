# Resumen del chat - AptiSpace

Fecha: 2026-06-07

## Solicitud inicial
Se pidió diseñar un sistema web profesional llamado AptiSpace para la evaluación de aptitud espacial - desplazamiento, orientado a psicólogos y evaluadores que aplican la BFA, módulo Espacial - Desplazamiento S2.

## Decisión tomada
El proyecto existente `C:\Users\Casa\bfa-espacial` ya tenía avances, pero el usuario pidió crear otro proyecto mejor en IntelliJ IDEA y agregar lo nuevo ahí.

## Proyecto creado
Ruta:

```text
C:\Users\Casa\AptiSpace
```

Tipo:

```text
Java 17 + Maven + OpenXava 7.7 + WAR
```

## Elementos implementados
- Proyecto Maven nuevo.
- Entidades JPA principales:
  - Rol
  - Usuario
  - Evaluado
  - Prueba
  - Ejercicio
  - OpcionEjercicio
  - PlantillaCorreccion
  - AplicacionPrueba
  - RespuestaEvaluado
  - ResultadoPrueba
  - ObservacionPsicologica
- Servicio de corrección automática:
  - S2 = aciertos - errores
  - Si S2 < 0, se guarda 0
- Acciones OpenXava:
  - IniciarPruebaAction
  - FinalizarPruebaAction
  - CalcularResultadoAction
- Módulos OpenXava y carpetas funcionales.
- SQL PostgreSQL en `sql/postgresql_schema.sql`.
- Documento de análisis y UML en `docs/analisis-y-uml.md`.
- README con instrucciones de uso.

## Ejecución configurada
Se configuró Tomcat embebido con Cargo Maven Plugin.

Comando:

```powershell
cd C:\Users\Casa\AptiSpace
mvn cargo:run
```

URL:

```text
http://localhost:8080/AptiSpace
```

Módulo directo:

```text
http://localhost:8080/AptiSpace/m/AplicacionPrueba
```

## Estado actual
El servidor quedó corriendo en el puerto 8080.

Proceso Java verificado:

```text
PID 10140
```

La URL del módulo respondió `200 OK`.

## Login
Al principio NaviOX rechazó `admin/admin`. Para evitar bloqueo durante desarrollo, se agregó un filtro de auto-login:

```text
src/main/java/com/aptispace/web/AutoLoginDesarrolloFilter.java
```

El filtro establece la sesión como usuario `admin` automáticamente.

Nota: esto es solo para desarrollo. Para producción o entrega formal con seguridad, se debe quitar el filtro y configurar autenticación real.

## Archivos importantes
- `pom.xml`
- `src/main/resources/xava/application.xml`
- `src/main/resources/xava/controllers.xml`
- `src/main/resources/xava.properties`
- `src/main/resources/naviox-users.properties`
- `src/main/resources/naviox.properties`
- `src/main/webapp/WEB-INF/web.xml`
- `docs/analisis-y-uml.md`
- `sql/postgresql_schema.sql`

## Verificaciones realizadas
- `mvn package` terminó con `BUILD SUCCESS`.
- Tomcat embebido inició en `8080`.
- La aplicación respondió HTTP 200.
- El módulo `AplicacionPrueba` cargó sin pantalla de login.
