FROM maven:3.9-eclipse-temurin-17

WORKDIR /app

COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline

COPY . .
RUN chmod +x docker-entrypoint.sh && mvn -q -DskipTests package

ENV PORT=8080
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]
