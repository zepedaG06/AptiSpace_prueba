INSERT INTO rol (id, nombre_rol, descripcion) VALUES (2, 'PSICOLOGO', 'Registra evaluados, asigna pruebas, consulta resultados y agrega observaciones');
INSERT INTO rol (id, nombre_rol, descripcion) VALUES (3, 'EVALUADO', 'Realiza la prueba y consulta resultados autorizados');

INSERT INTO usuario (id, nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES (2, 'evaluador', 'evaluador123', 'Evaluador', 'Demo', 'evaluador@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);
INSERT INTO usuario (id, nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES (3, 'evaluado', 'evaluado123', 'Persona', 'Demo', 'evaluado@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);

INSERT INTO usuario_rol (usuario_id, rol_id) VALUES (2, 2);
INSERT INTO usuario_rol (usuario_id, rol_id) VALUES (3, 3);

INSERT INTO evaluado (id, usuario_id, nombres, apellidos, fecha_nacimiento, edad, sexo, estudios_realizados, carrera, anio_carrera, profesion, fecha_registro)
VALUES (1, 3, 'Persona', 'Demo', DATE '2000-01-01', 26, 'OTRO', 'Secundaria completa', 'Demo', 1, 'Demo', CURRENT_DATE);

INSERT INTO grupo_evaluacion (id, nombre, codigo, psicologo_id, fecha_creacion, activo)
VALUES (1, 'Espacio demo', 'DEMO2026', 2, CURRENT_DATE, TRUE);
INSERT INTO grupo_evaluado (grupo_id, evaluado_id) VALUES (1, 1);

INSERT INTO prueba (id, nombre, descripcion, tiempo_limite, cantidad_ejercicios, estado)
VALUES (1, 'BFA Espacial - Desplazamiento S2', 'Banco precargado de ejercicios visuales. Al iniciar una aplicacion se eligen ejercicios aleatorios.', 30, 4, 'ACTIVA');

INSERT INTO ejercicio (id, prueba_id, numero, imagen_modelo, enunciado) VALUES (1, 1, 1, 'images/s2/modelo-01.svg', 'Seleccione las figuras que corresponden al desplazamiento indicado.');
INSERT INTO ejercicio (id, prueba_id, numero, imagen_modelo, enunciado) VALUES (2, 1, 2, 'images/s2/modelo-02.svg', 'Seleccione las figuras que corresponden al desplazamiento indicado.');
INSERT INTO ejercicio (id, prueba_id, numero, imagen_modelo, enunciado) VALUES (3, 1, 3, 'images/s2/modelo-03.svg', 'Seleccione las figuras que corresponden al desplazamiento indicado.');
INSERT INTO ejercicio (id, prueba_id, numero, imagen_modelo, enunciado) VALUES (4, 1, 4, 'images/s2/modelo-04.svg', 'Seleccione las figuras que corresponden al desplazamiento indicado.');
INSERT INTO ejercicio (id, prueba_id, numero, imagen_modelo, enunciado) VALUES (5, 1, 5, 'images/s2/modelo-05.svg', 'Seleccione las figuras que corresponden al desplazamiento indicado.');
INSERT INTO ejercicio (id, prueba_id, numero, imagen_modelo, enunciado) VALUES (6, 1, 6, 'images/s2/modelo-06.svg', 'Seleccione las figuras que corresponden al desplazamiento indicado.');

INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (1, 'A', 'images/s2/opcion-a.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (1, 'B', 'images/s2/opcion-b.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (1, 'C', 'images/s2/opcion-c.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (1, 'D', 'images/s2/opcion-d.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (1, 'E', 'images/s2/opcion-e.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (2, 'A', 'images/s2/opcion-b.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (2, 'B', 'images/s2/opcion-c.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (2, 'C', 'images/s2/opcion-d.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (2, 'D', 'images/s2/opcion-e.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (2, 'E', 'images/s2/opcion-a.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (3, 'A', 'images/s2/opcion-c.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (3, 'B', 'images/s2/opcion-d.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (3, 'C', 'images/s2/opcion-e.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (3, 'D', 'images/s2/opcion-a.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (3, 'E', 'images/s2/opcion-b.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (4, 'A', 'images/s2/opcion-d.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (4, 'B', 'images/s2/opcion-e.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (4, 'C', 'images/s2/opcion-a.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (4, 'D', 'images/s2/opcion-b.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (4, 'E', 'images/s2/opcion-c.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (5, 'A', 'images/s2/opcion-e.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (5, 'B', 'images/s2/opcion-a.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (5, 'C', 'images/s2/opcion-b.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (5, 'D', 'images/s2/opcion-c.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (5, 'E', 'images/s2/opcion-d.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (6, 'A', 'images/s2/opcion-a.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (6, 'B', 'images/s2/opcion-b.svg', TRUE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (6, 'C', 'images/s2/opcion-c.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (6, 'D', 'images/s2/opcion-d.svg', FALSE);
INSERT INTO opcion_ejercicio (ejercicio_id, letra, imagen_opcion, es_correcta) VALUES (6, 'E', 'images/s2/opcion-e.svg', FALSE);

INSERT INTO plantilla_correccion (id, descripcion, activa) VALUES (1, 'Plantilla S2 demo precargada', TRUE);
INSERT INTO plantilla_ejercicio (plantilla_id, ejercicio_id) VALUES (1, 1);
INSERT INTO plantilla_ejercicio (plantilla_id, ejercicio_id) VALUES (1, 2);
INSERT INTO plantilla_ejercicio (plantilla_id, ejercicio_id) VALUES (1, 3);
INSERT INTO plantilla_ejercicio (plantilla_id, ejercicio_id) VALUES (1, 4);
INSERT INTO plantilla_ejercicio (plantilla_id, ejercicio_id) VALUES (1, 5);
INSERT INTO plantilla_ejercicio (plantilla_id, ejercicio_id) VALUES (1, 6);
