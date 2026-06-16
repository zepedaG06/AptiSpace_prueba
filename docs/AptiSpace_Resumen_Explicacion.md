# Arquitectura: Sistema AptiSpace

## 1. Modelo de Datos y Persistencia (Capa JPA)

La base de datos de AptiSpace esta estructurada bajo el estandar JPA, priorizando la integridad referencial y la automatizacion de la interfaz de usuario mediante OpenXava.

**Entidad Central: AplicacionPrueba**
Actua como la tabla pivote del sistema.
* **Gestion de Estados Nativos:** El ciclo de vida de la evaluacion se controla mediante un enum estricto (ASIGNADA, EN_PROCESO, FINALIZADA), lo que evita inconsistencias logicas en el flujo.
* **Encapsulamiento del Tiempo:** Para prevenir discrepancias entre el reloj del cliente y el servidor, el calculo del tiempo no se realiza en la vista. Los metodos internos iniciar() y finalizar() capturan la marca de tiempo exacta (LocalDateTime.now()) y calculan la duracion en segundos utilizando la libreria nativa java.time.Duration.
* **Integridad en Cascada:** Se implementan relaciones @OneToMany y @OneToOne con cascade = CascadeType.ALL y orphanRemoval = true. Si se elimina una aplicacion, el motor destruye automaticamente las respuestas y resultados asociados, manteniendo la base de datos libre de registros huerfanos.
* **Optimizacion de Consultas:** La tabla incluye indices explicitos (@Table(indexes = {...})) en las columnas evaluado_id y prueba_id para garantizar la escalabilidad y rapidez al generar reportes con grandes volumenes de datos.

**Entidad de Salida: ResultadoPrueba**
* **Inmutabilidad de Datos:** Los campos de calificacion (aciertos, errores, puntuacionS2) estan protegidos con la anotacion @ReadOnly. Esto garantiza que ni siquiera un usuario administrador pueda alterar manualmente una calificacion desde la interfaz; el dato es inyectado exclusivamente por el servicio de backend.

---

## 2. Controladores de Interfaz (Ciclo de Vida)

El flujo de usuario esta gobernado por tres controladores principales que heredan de ViewBaseAction y actuan como intermediarios entre la vista web y la logica de base de datos.

* **IniciarPruebaAction (Arranque y Anti-fraude):** Al dispararse, este controlador implementa programacion defensiva verificando que la prueba no este ya en curso. Para mitigar el riesgo de fraude, invoca el metodo asignarEjerciciosAleatorios, el cual clona el banco de ejercicios y aplica Collections.shuffle() para generar un orden de evaluacion unico por candidato.
* **FinalizarPruebaAction (Cierre del Sistema):** Aplica el principio de delegacion de responsabilidades. El controlador no manipula las variables de estado directamente, sino que llama al metodo aplicacion.finalizar() de la entidad para registrar la hora de cierre, actualiza el objeto en la base de datos mediante em.merge(aplicacion) y bloquea la interfaz de usuario.
* **CalcularResultadoAction (Puente de Baremacion):** Para evitar el codigo espagueti en la capa de vista, este controlador delega todo el calculo matematico llamando directamente al metodo estatico ServicioCorreccion.corregirYGuardar(id). Al finalizar, extrae la metrica calculada y proporciona feedback inmediato al evaluador en la interfaz.

---

## 3. Motor de Calificacion (ServicioCorreccion)

El nucleo logico de AptiSpace reside en una clase utilitaria encapsulada que procesa la baremacion oficial de la Bateria Factorial de Aptitudes (BFA) sin instanciar objetos innecesarios.

**Implementacion del Algoritmo S2:**
La rubrica espacial establece que los errores penalizan los aciertos bajo la siguiente formula: S2 = aciertos - errores.

El motor recorre las respuestas del candidato, delegando la autoevaluacion a cada objeto (respuesta.corregir()). Para cumplir con la regla de negocio que prohibe puntuaciones negativas finales, el sistema intercepta el calculo matematico utilizando la libreria estandar de Java:

int puntuacionS2 = Math.max(0, aciertos - errores);

Si el balance resulta en un valor negativo, el algoritmo devuelve automaticamente un 0.

**Transacciones Seguras:**
El metodo corregirYGuardar() utiliza el EntityManager para gestionar el ciclo de persistencia en una sola transaccion limpia. Ademas, previene errores de concurrencia forzando la carga en memoria de las relaciones anidadas (aplicacion.getRespuestas().size()) antes de ejecutar los calculos, asegurando que los datos inyectados a PostgreSQL sean definitivos e inalterables.