-- Ejecutar como superusuario de PostgreSQL, por ejemplo:
-- "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -f sql/postgresql_setup.sql

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aptispace') THEN
        CREATE ROLE aptispace LOGIN PASSWORD 'aptispace123';
    ELSE
        ALTER ROLE aptispace WITH LOGIN PASSWORD 'aptispace123';
    END IF;
END
$$;

SELECT 'CREATE DATABASE aptispace OWNER aptispace'
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'aptispace')\gexec
