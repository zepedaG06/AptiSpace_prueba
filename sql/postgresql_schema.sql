CREATE TABLE IF NOT EXISTS rol (
    id BIGSERIAL PRIMARY KEY,
    nombre_rol VARCHAR(40) NOT NULL UNIQUE,
    descripcion VARCHAR(250)
);

CREATE TABLE IF NOT EXISTS usuario (
    id BIGSERIAL PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(120) NOT NULL,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    correo VARCHAR(120),
    foto_perfil VARCHAR(255),
    estado VARCHAR(20) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS usuario_rol (
    usuario_id BIGINT NOT NULL REFERENCES usuario(id),
    rol_id BIGINT NOT NULL REFERENCES rol(id),
    PRIMARY KEY (usuario_id, rol_id)
);

CREATE TABLE IF NOT EXISTS evaluado (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT UNIQUE REFERENCES usuario(id),
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    edad INT NOT NULL CHECK (edad BETWEEN 10 AND 99),
    sexo VARCHAR(20) NOT NULL,
    estudios_realizados VARCHAR(150),
    carrera VARCHAR(120),
    anio_carrera INT CHECK (anio_carrera BETWEEN 1 AND 12),
    profesion VARCHAR(120),
    fecha_registro DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS grupo_evaluacion (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    psicologo_id BIGINT REFERENCES usuario(id),
    fecha_creacion DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS grupo_evaluado (
    grupo_id BIGINT NOT NULL REFERENCES grupo_evaluacion(id),
    evaluado_id BIGINT NOT NULL REFERENCES evaluado(id),
    PRIMARY KEY (grupo_id, evaluado_id)
);

CREATE TABLE IF NOT EXISTS prueba (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(500),
    tiempo_limite INT NOT NULL CHECK (tiempo_limite > 0),
    cantidad_ejercicios INT NOT NULL DEFAULT 8 CHECK (cantidad_ejercicios > 0),
    estado VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS ejercicio (
    id BIGSERIAL PRIMARY KEY,
    prueba_id BIGINT NOT NULL REFERENCES prueba(id),
    numero INT NOT NULL,
    imagen_modelo VARCHAR(255),
    enunciado VARCHAR(300),
    tipo_respuesta VARCHAR(20) NOT NULL DEFAULT 'UNICA',
    UNIQUE (prueba_id, numero)
);

CREATE TABLE IF NOT EXISTS opcion_ejercicio (
    id BIGSERIAL PRIMARY KEY,
    ejercicio_id BIGINT NOT NULL REFERENCES ejercicio(id),
    letra CHAR(1) NOT NULL CHECK (letra IN ('A','B','C','D','E')),
    imagen_opcion VARCHAR(255),
    es_correcta BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (ejercicio_id, letra)
);

CREATE TABLE IF NOT EXISTS plantilla_correccion (
    id BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR(300) NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS plantilla_ejercicio (
    plantilla_id BIGINT NOT NULL REFERENCES plantilla_correccion(id),
    ejercicio_id BIGINT NOT NULL REFERENCES ejercicio(id),
    PRIMARY KEY (plantilla_id, ejercicio_id)
);

CREATE TABLE IF NOT EXISTS aplicacion_prueba (
    id BIGSERIAL PRIMARY KEY,
    evaluado_id BIGINT NOT NULL REFERENCES evaluado(id),
    prueba_id BIGINT NOT NULL REFERENCES prueba(id),
    psicologo_id BIGINT REFERENCES usuario(id),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    tiempo_utilizado INT DEFAULT 0,
    estado VARCHAR(20) NOT NULL,
    autorizada_reaplicacion BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS respuesta_evaluado (
    id BIGSERIAL PRIMARY KEY,
    aplicacion_id BIGINT NOT NULL REFERENCES aplicacion_prueba(id),
    ejercicio_id BIGINT NOT NULL REFERENCES ejercicio(id),
    opcion_a BOOLEAN NOT NULL DEFAULT FALSE,
    opcion_b BOOLEAN NOT NULL DEFAULT FALSE,
    opcion_c BOOLEAN NOT NULL DEFAULT FALSE,
    opcion_d BOOLEAN NOT NULL DEFAULT FALSE,
    opcion_e BOOLEAN NOT NULL DEFAULT FALSE,
    es_acierto BOOLEAN DEFAULT FALSE,
    es_error BOOLEAN DEFAULT FALSE,
    fecha_respuesta TIMESTAMP NOT NULL,
    UNIQUE (aplicacion_id, ejercicio_id)
);

CREATE TABLE IF NOT EXISTS resultado_prueba (
    id BIGSERIAL PRIMARY KEY,
    aplicacion_id BIGINT NOT NULL UNIQUE REFERENCES aplicacion_prueba(id),
    aciertos INT NOT NULL DEFAULT 0,
    errores INT NOT NULL DEFAULT 0,
    sin_responder INT NOT NULL DEFAULT 0,
    puntuacion_s2 INT NOT NULL DEFAULT 0,
    fecha_resultado TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS observacion_psicologica (
    id BIGSERIAL PRIMARY KEY,
    aplicacion_id BIGINT NOT NULL REFERENCES aplicacion_prueba(id),
    psicologo_id BIGINT REFERENCES usuario(id),
    comentario VARCHAR(2000) NOT NULL,
    fecha_observacion TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_aplicacion_evaluado ON aplicacion_prueba(evaluado_id);
CREATE INDEX IF NOT EXISTS idx_aplicacion_prueba ON aplicacion_prueba(prueba_id);
CREATE INDEX IF NOT EXISTS idx_respuesta_aplicacion ON respuesta_evaluado(aplicacion_id);
CREATE INDEX IF NOT EXISTS idx_resultado_fecha ON resultado_prueba(fecha_resultado);
