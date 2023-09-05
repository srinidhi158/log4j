# Dockerfile
# Use the official OpenJDK 8 image as the base image
FROM openjdk:8-jdk-alpine

# Copy the Spring Boot application JAR file into the container
COPY target/demo-0.0.1-SNAPSHOT.jar /app/demo.jar

# Copy the application's log4j2.xml configuration (if needed)
COPY src/main/resources/log4j2.xml /app/log4j2.xml
COPY src/main/resources/application.properties /app/application.properties

# Set the working directory to /app
WORKDIR /app

# Expose the port your Spring Boot application will run on (if needed)
EXPOSE 8888

# This is where you should pass your database configuration as environment variables.
# Update these environment variables with your MySQL host, port, database name, username, and password.
ENV SPRING_DATASOURCE_URL=jdbc:mysql://mysql-container:3306/employee
ENV SPRING_DATASOURCE_USERNAME=admin
ENV SPRING_DATASOURCE_PASSWORD=Test@123

CMD ["java", "-jar", "demo.jar"]