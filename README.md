# AptiSpace

Proyecto web Java/OpenXava para evaluación de aptitud espacial - desplazamiento S2.

## Abrir en IntelliJ IDEA
1. Abrir IntelliJ IDEA.
2. Seleccionar `Open`.
3. Buscar la ruta donde se guardo el proyecto.
4. Importar como proyecto Maven.

## Ejecutar desde IntelliJ con Main
1. Ejecutar `mvn package -DskipTests` una vez para generar `target/classes`.
2. Crear una configuracion `Application`.
3. Main class: `com.aptispace.Main`.
4. Working directory: raiz del proyecto `AptiSpace`.
5. Abrir:

```text
http://localhost:8081/AptiSpace/
```

Tambien se puede ejecutar desde terminal:

```powershell
mvn exec:java -Dapp.port=8081
```

## URL oficial
La app desplegada en Railway esta disponible en:

```text
https://aptispace-production.up.railway.app/AptiSpace/
```

Healthcheck:

```text
https://aptispace-production.up.railway.app/AptiSpace/health
```

El healthcheck debe responder `OK`.

## Estructura
- `src/main/java/com/aptispace/modelo`: entidades JPA.
- `src/main/java/com/aptispace/servicio`: lógica de corrección.
- `src/main/java/com/aptispace/acciones`: acciones OpenXava.
- `src/main/resources/xava`: módulos y controladores OpenXava.
- `sql/postgresql_schema.sql`: modelo relacional PostgreSQL.
- `docs/analisis-y-uml.md`: análisis, requerimientos y UML.

## Corrección S2
S2 = aciertos - errores. Si el valor es menor que cero, el sistema guarda cero.

## Flujo de prueba actual
El banco S2 ya viene precargado con ejercicios, opciones e imagenes de ejemplo.
El psicologo no necesita crear las imagenes ni armar cada ejercicio manualmente.

1. Entrar a `AplicacionPrueba`.
2. Crear una aplicacion seleccionando el evaluado, la prueba S2 y el psicologo.
3. Guardar la aplicacion.
4. Presionar `iniciar`.
5. El sistema asigna automaticamente ejercicios aleatorios segun `cantidadEjercicios` de la prueba.
6. Abrir las respuestas generadas y marcar las opciones A-E.
7. Presionar `finalizar`.
8. Presionar `calcularResultado`.

Para variar la cantidad aplicada, editar la prueba y cambiar `cantidadEjercicios`.
Cada nueva aplicacion toma una muestra aleatoria diferente del banco disponible.

## Ejecutar
Desde `C:\Users\Casa\AptiSpace`:

```powershell
mvn cargo:run
```

## PostgreSQL local
La app esta configurada para guardar en PostgreSQL:

```text
Base: aptispace
Usuario: aptispace
Clave: aptispace123
URL: jdbc:postgresql://localhost:5432/aptispace
```

Crear la base y el usuario con la clave del superusuario `postgres`:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -f sql\postgresql_setup.sql
```

Si quieres crear el esquema manualmente:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U aptispace -d aptispace -f sql\postgresql_schema.sql
```

URL local:

```text
http://localhost:8080/AptiSpace/
```

Usuarios de prueba:

```text
Evaluador: evaluador@aptispace.local / evaluador123
Evaluado: evaluado@aptispace.local / evaluado123
```

El evaluador controla plantillas, grupos, asignaciones, resultados y observaciones.
El evaluado solo entra a su prueba, resultado e informacion personal.

## Railway
Railway despliega desde la rama `main`.

Variables esperadas en el servicio web:

```text
PORT
DATABASE_URL
APTISPACE_SESSION_SECRET
```

`DATABASE_URL` debe referenciar la base PostgreSQL de Railway, por ejemplo:

```text
${{aptispace-db.DATABASE_URL}}
```

No usar `JDBC_DATABASE_URL` junto con `DATABASE_URL`, porque la app prioriza `JDBC_DATABASE_URL`.

El deploy usa el WAR precompilado:

```text
deploy/AptiSpace.war
```

Si se cambia codigo Java, JSP o recursos de la app, recompilar y actualizar el WAR antes de hacer push:

```powershell
mvn.cmd -DskipTests package
Copy-Item target\aptispace-1.0.0.war deploy\AptiSpace.war -Force
```
