INSERT INTO rol (nombre_rol, descripcion) VALUES ('ADMINISTRADOR', 'Gestiona usuarios, pruebas, configuraciones y reportes globales');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('PSICOLOGO', 'Registra evaluados, asigna pruebas, consulta resultados y agrega observaciones');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('EVALUADO', 'Realiza la prueba y consulta resultados autorizados');

INSERT INTO usuario (nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES ('admin', 'admin123', 'Administrador', 'AptiSpace', 'admin@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);
INSERT INTO usuario (nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES ('evaluador', 'evaluador123', 'Evaluador', 'Demo', 'evaluador@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);
INSERT INTO usuario (nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES ('evaluado', 'evaluado123', 'Persona', 'Demo', 'evaluado@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);

INSERT INTO prueba (nombre, descripcion, tiempo_limite, cantidad_ejercicios, estado)
VALUES ('BFA Espacial - Desplazamiento S2', 'Evaluación de aptitud espacial por desplazamiento y giro sin inversión.', 30, 4, 'ACTIVA');
