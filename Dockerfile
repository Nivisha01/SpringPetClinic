# Use a base image with Java installed
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the .war file from the target directory to the container
COPY target/shopping-cart-0.0.1-SNAPSHOT.war app.war

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.war"]
