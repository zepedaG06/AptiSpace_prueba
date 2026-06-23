#!/usr/bin/env sh
set -eu

APP_PORT="${PORT:-8080}"
APP_DIR="/usr/local/tomcat/webapps/AptiSpace"
JDBC_URL="${JDBC_DATABASE_URL:-${DATABASE_URL:-jdbc:postgresql://localhost:5432/aptispace}}"
JDBC_USER="${JDBC_DATABASE_USERNAME:-${POSTGRES_USER:-aptispace}}"
JDBC_PASSWORD="${JDBC_DATABASE_PASSWORD:-${POSTGRES_PASSWORD:-aptispace123}}"

case "$JDBC_URL" in
  postgres://*|postgresql://*)
    WITHOUT_PROTO="${JDBC_URL#*://}"
    CREDS="${WITHOUT_PROTO%@*}"
    HOST_DB="${WITHOUT_PROTO#*@}"
    JDBC_USER="${JDBC_DATABASE_USERNAME:-${CREDS%%:*}}"
    JDBC_PASSWORD="${JDBC_DATABASE_PASSWORD:-${CREDS#*:}}"
    JDBC_URL="jdbc:postgresql://${HOST_DB}"
    ;;
esac

export CATALINA_OPTS="${CATALINA_OPTS:-"-Xms64m -Xmx256m -XX:MaxMetaspaceSize=192m -XX:+UseSerialGC"} -Dserver.port=${APP_PORT} -Daptispace.session.secret=${APTISPACE_SESSION_SECRET:-aptispace-local-session-key}"

if [ ! -d "$APP_DIR" ]; then
  mkdir -p "$APP_DIR"
  (cd "$APP_DIR" && jar -xf /usr/local/tomcat/webapps/AptiSpace.war)
  rm -f /usr/local/tomcat/webapps/AptiSpace.war
fi

cat > "$APP_DIR/WEB-INF/classes/META-INF/persistence.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<persistence xmlns="http://xmlns.jcp.org/xml/ns/persistence"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/persistence http://xmlns.jcp.org/xml/ns/persistence/persistence_2_2.xsd"
             version="2.2">
    <persistence-unit name="default">
        <provider>org.hibernate.jpa.HibernatePersistenceProvider</provider>
        <class>com.aptispace.modelo.Rol</class>
        <class>com.aptispace.modelo.Usuario</class>
        <class>com.aptispace.modelo.Bitacora</class>
        <class>com.aptispace.modelo.ConfiguracionBasica</class>
        <class>com.aptispace.modelo.Evaluado</class>
        <class>com.aptispace.modelo.GrupoEvaluacion</class>
        <class>com.aptispace.modelo.Prueba</class>
        <class>com.aptispace.modelo.Ejercicio</class>
        <class>com.aptispace.modelo.OpcionEjercicio</class>
        <class>com.aptispace.modelo.PlantillaCorreccion</class>
        <class>com.aptispace.modelo.AplicacionPrueba</class>
        <class>com.aptispace.modelo.RespuestaEvaluado</class>
        <class>com.aptispace.modelo.ResultadoPrueba</class>
        <class>com.aptispace.modelo.ObservacionPsicologica</class>
        <class>com.aptispace.modelo.ArchivoSubido</class>
        <properties>
            <property name="javax.persistence.jdbc.driver" value="org.postgresql.Driver"/>
            <property name="javax.persistence.jdbc.url" value="${JDBC_URL}"/>
            <property name="javax.persistence.jdbc.user" value="${JDBC_USER}"/>
            <property name="javax.persistence.jdbc.password" value="${JDBC_PASSWORD}"/>
            <property name="hibernate.dialect" value="org.hibernate.dialect.PostgreSQLDialect"/>
            <property name="hibernate.hbm2ddl.auto" value="update"/>
            <property name="hibernate.show_sql" value="false"/>
            <property name="hibernate.format_sql" value="true"/>
        </properties>
    </persistence-unit>
</persistence>
EOF

sed -i "s/port=\"8080\"/port=\"${APP_PORT}\"/g" /usr/local/tomcat/conf/server.xml

exec catalina.sh run
