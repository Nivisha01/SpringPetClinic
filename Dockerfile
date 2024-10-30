# Use a base image with JRE
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the Maven-built JAR file into the container
COPY target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar petclinic.jar

# Expose the application port
EXPOSE 8080

# Run the JAR file
CMD ["java", "-jar", "petclinic.jar"]
