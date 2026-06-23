INSERT INTO rol (nombre_rol, descripcion) VALUES ('ADMINISTRADOR', 'Gestiona usuarios, roles, seguridad, bitacora y configuracion basica');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('EVALUADOR', 'Registra evaluados, asigna pruebas, consulta resultados y agrega observaciones');
INSERT INTO rol (nombre_rol, descripcion) VALUES ('EVALUADO', 'Realiza la prueba y consulta resultados autorizados');

INSERT INTO usuario (nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES ('admin', 'admin123', 'Administrador', 'AptiSpace', 'admin@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);
INSERT INTO usuario (nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES ('evaluador', 'evaluador123', 'Evaluador', 'Demo', 'evaluador@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);
INSERT INTO usuario (nombre_usuario, contrasena, nombres, apellidos, correo, estado, fecha_creacion)
VALUES ('evaluado', 'evaluado123', 'Persona', 'Demo', 'evaluado@aptispace.local', 'ACTIVO', CURRENT_TIMESTAMP);

INSERT INTO usuario_rol (usuario_id, rol_id)
SELECT u.id, r.id FROM usuario u, rol r WHERE u.nombre_usuario = 'admin' AND r.nombre_rol = 'ADMINISTRADOR';
INSERT INTO usuario_rol (usuario_id, rol_id)
SELECT u.id, r.id FROM usuario u, rol r WHERE u.nombre_usuario = 'evaluador' AND r.nombre_rol = 'EVALUADOR';
INSERT INTO usuario_rol (usuario_id, rol_id)
SELECT u.id, r.id FROM usuario u, rol r WHERE u.nombre_usuario = 'evaluado' AND r.nombre_rol = 'EVALUADO';

INSERT INTO prueba (nombre, descripcion, tiempo_limite, cantidad_ejercicios, estado)
VALUES ('BFA Espacial - Desplazamiento S2', 'Evaluacion de aptitud espacial por desplazamiento y giro sin inversion.', 30, 4, 'ACTIVA');
