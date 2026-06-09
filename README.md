# AptiSpace

Proyecto web Java/OpenXava para evaluación de aptitud espacial - desplazamiento S2.

## Abrir en IntelliJ IDEA
1. Abrir IntelliJ IDEA.
2. Seleccionar `Open`.
3. Elegir la carpeta `C:\Users\Casa\AptiSpace`.
4. Importar como proyecto Maven.

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

URL local:

```text
http://localhost:8080/AptiSpace
```

Usuarios de prueba:

```text
Evaluador: evaluador / evaluador123
Evaluado: evaluado / evaluado123
Admin: admin / admin123
```
