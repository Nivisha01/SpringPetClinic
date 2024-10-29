# Use an official Java runtime as a parent image
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the Maven-built JAR file into the container at /app
COPY target/petclinic-0.0.1-SNAPSHOT.jar petclinic.jar

# Run the jar file
ENTRYPOINT ["java", "-jar", "petclinic.jar"]

# Expose the port the app runs on
EXPOSE 8080
