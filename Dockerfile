FROM eclipse-temurin:21-jre
WORKDIR app
COPY target/demo-ecs-0.0.2-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]