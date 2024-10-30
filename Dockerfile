# Use an appropriate base image with JDK 11
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the Maven-built JAR file into the container
COPY target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar petclinic.jar

# Expose the port your application is set to run on
EXPOSE 8080

# Run the application with the MySQL profile enabled
CMD ["java", "-Dspring.profiles.active=mysql", "-jar", "petclinic.jar"]
