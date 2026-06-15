FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
COPY . .
RUN MAVEN_OPTS="-Xms64m -Xmx384m -XX:MaxMetaspaceSize=192m" mvn -q -DskipTests package

FROM tomcat:9.0-jdk17-temurin

ENV PORT=8080
ENV CATALINA_OPTS="-Xms64m -Xmx256m -XX:MaxMetaspaceSize=192m -XX:+UseSerialGC"
EXPOSE 8080

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/aptispace-1.0.0.war /usr/local/tomcat/webapps/AptiSpace.war
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh && chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["docker-entrypoint.sh"]
