# Manual de Desarrollo - AptiSpace

## 1. Introducción

AptiSpace es una aplicación web desarrollada para la administración digital del Test Espacial (Desplazamiento) perteneciente a la Batería Factorial de Aptitudes. El sistema permite automatizar el proceso de aplicación, seguimiento, corrección y almacenamiento de resultados de evaluaciones psicológicas relacionadas con la aptitud espacial.

El proyecto surge como una alternativa a los procesos tradicionales basados en papel, reduciendo errores humanos y optimizando los tiempos de evaluación y análisis de resultados.

---

# 2. Objetivos del Desarrollo

## Objetivo General

Desarrollar una plataforma web capaz de administrar digitalmente el Test Espacial (Desplazamiento), automatizando la aplicación, corrección y generación de resultados.

## Objetivos Específicos

* Digitalizar el proceso de evaluación.
* Automatizar la corrección de pruebas.
* Gestionar usuarios con diferentes roles.
* Almacenar resultados históricos.
* Facilitar la consulta de información para evaluadores y evaluados.
* Generar resultados confiables mediante cálculos automáticos.

---

# 3. Tecnologías Utilizadas

| Tecnología    | Uso                      |
| ------------- | ------------------------ |
| Java          | Lenguaje principal       |
| JSP           | Interfaz web             |
| OpenXava      | Framework empresarial    |
| Maven         | Gestión de dependencias  |
| PostgreSQL    | Base de datos            |
| Apache Tomcat | Servidor de aplicaciones |
| IntelliJ IDEA | Entorno de desarrollo    |
| Docker        | Contenerización          |
| Railway       | Despliegue en la nube    |

---

# 4. Metodología de Desarrollo

El proyecto fue desarrollado siguiendo un enfoque incremental compuesto por las siguientes etapas:

## 4.1 Análisis

Durante esta fase se identificó el problema relacionado con la aplicación manual del Test Espacial y se definieron los requerimientos funcionales y no funcionales.

Se determinaron tres actores principales:

* Administrador
* Evaluador (Psicólogo)
* Evaluado

---

## 4.2 Diseño

Se diseñó la arquitectura general del sistema utilizando el patrón Modelo-Vista-Controlador (MVC).

También se elaboró el modelo relacional de la base de datos y la estructura de navegación del sistema.

---

## 4.3 Implementación

La implementación se realizó utilizando Java Web y OpenXava.

La lógica del negocio fue dividida en paquetes especializados para mantener una estructura organizada y facilitar el mantenimiento del código.

---

# 5. Arquitectura del Sistema

El proyecto se encuentra organizado bajo la siguiente estructura:

```text
src/main/java/com/aptispace

├── acciones
├── modelo
├── servicio
└── web
```

## Acciones

Contiene las acciones personalizadas ejecutadas dentro de OpenXava.

### Clases principales

* IniciarPruebaAction
* FinalizarPruebaAction
* CalcularResultadoAction

Estas clases permiten controlar el flujo de aplicación y corrección de las pruebas.

---

## Modelo

Contiene las entidades persistentes de la aplicación.

### Entidades principales

* Usuario
* Rol
* Evaluado
* GrupoEvaluacion
* Prueba
* Ejercicio
* OpcionEjercicio
* AplicacionPrueba
* RespuestaEvaluado
* ResultadoPrueba
* ObservacionPsicologica

Estas entidades representan las tablas almacenadas en PostgreSQL.

---

## Servicio

Contiene la lógica de negocio.

### ServicioCorreccion

Responsable de:

* Evaluar respuestas.
* Contabilizar aciertos.
* Contabilizar errores.
* Calcular la puntuación final S2.

---

## Web

Contiene los servlets encargados de la interacción con los usuarios.

### Componentes principales

* AuthServlet
* LogoutServlet
* MiPerfilServlet
* MiPruebaServlet
* MiResultadosServlet
* UploadsServlet

---

# 6. Diseño de la Base de Datos

La base de datos PostgreSQL fue diseñada para almacenar toda la información relacionada con usuarios, pruebas y resultados.

## Tablas principales

### Seguridad

* rol
* usuario
* usuario_rol

### Gestión de evaluados

* evaluado
* grupo_evaluacion
* grupo_evaluado

### Gestión de pruebas

* prueba
* ejercicio
* opcion_ejercicio

### Corrección

* plantilla_correccion
* plantilla_ejercicio

### Aplicación

* aplicacion_prueba
* respuesta_evaluado

### Resultados

* resultado_prueba
* observacion_psicologica

---

# 7. Implementación del Test Espacial S2

El sistema implementa el Test Espacial (Desplazamiento) utilizando un banco de ejercicios precargado.

Cuando un evaluador inicia una aplicación:

1. Se selecciona un evaluado.
2. Se selecciona la prueba S2.
3. Se genera automáticamente una muestra aleatoria de ejercicios.
4. El evaluado responde cada ejercicio.
5. Se registran las respuestas.
6. Se finaliza la aplicación.
7. Se calcula el resultado.

---

# 8. Algoritmo de Corrección

La puntuación final se calcula mediante la fórmula:

S2 = Aciertos - Errores

Regla adicional:

Si el resultado obtenido es menor que cero, la puntuación final se almacena como cero.

```java
resultado = aciertos - errores;

if(resultado < 0){
    resultado = 0;
}
```

---

# 9. Gestión de Roles

## Evaluador

Puede:

* Gestionar grupos.
* Gestionar evaluados.
* Aplicar pruebas.
* Consultar resultados.
* Registrar observaciones psicológicas.

## Evaluado

Puede:

* Acceder a sus pruebas asignadas.
* Responder ejercicios.
* Consultar resultados.
* Gestionar información personal.

---

# 10. Despliegue

El sistema fue preparado para funcionar tanto en entornos locales como en la nube.

## Entorno Local

* PostgreSQL
* Maven
* Tomcat

Ejecución:

```bash
mvn cargo:run
```

URL:

```text
https://aptispace-production.up.railway.app/AptiSpace/
```

---

## Entorno de Producción

Plataforma utilizada:

* Railway

Variables de entorno:

* PORT
* DATABASE_URL
* APTISPACE_SESSION_SECRET

---

# 11. Resultados Obtenidos

La implementación de AptiSpace permitió:

* Reducir tiempos de corrección.
* Eliminar cálculos manuales.
* Mantener historial de evaluaciones.
* Mejorar la administración de pruebas.
* Automatizar la generación de resultados.

---

# 12. Conclusiones

AptiSpace demuestra que la digitalización de pruebas psicométricas puede mejorar significativamente la eficiencia de los procesos de evaluación. La utilización de Java, OpenXava y PostgreSQL permitió construir una solución robusta, escalable y fácil de mantener, capaz de automatizar completamente la aplicación y corrección del Test Espacial (Desplazamiento).
