# --- Stage 2: Build the application ---
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the source code and pom.xml
COPY . .

# Package the application (skipping tests for speed)
RUN mvn clean package -DskipTests

# --- Stage 2: Run the application ---
FROM eclipse-temurin:17-jre-alpine

# Create a non-root system user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

WORKDIR /app

# Copy the compiled JAR file from the builder stage
COPY --from=builder /app/target/*.jar /app/target/expenseapp.jar

# Expose the application port
EXPOSE 8080

# Configure JVM parameters to respect container memory limits
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0"

# Execute the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/target/expenseapp.jar"]

