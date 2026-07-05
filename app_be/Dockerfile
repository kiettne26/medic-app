# syntax=docker/dockerfile:1.4
# =========================================================================
#  MULTI-STAGE DOCKERFILE FOR MICROSERVICES (JDK 21)
# =========================================================================

# Stage 1: Build all projects using Maven and eclipse-temurin JDK 21
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Copy parent pom.xml
COPY pom.xml .

# Copy poms of submodules to fetch dependencies first
COPY common/pom.xml common/
COPY eureka-server/pom.xml eureka-server/
COPY api-gateway/pom.xml api-gateway/
COPY auth-service/pom.xml auth-service/
COPY user-service/pom.xml user-service/
COPY booking-service/pom.xml booking-service/
COPY notification-service/pom.xml notification-service/
COPY analytics-service/pom.xml analytics-service/

# Cache dependencies
RUN mvn dependency:go-offline -B

# Copy all source codes
COPY common common/
COPY eureka-server eureka-server/
COPY api-gateway api-gateway/
COPY auth-service auth-service/
COPY user-service user-service/
COPY booking-service booking-service/
COPY notification-service notification-service/
COPY analytics-service analytics-service/

# Build all packages, skipping tests
RUN mvn clean package -DskipTests

# ----------------- SERVICES RUN STAGES -----------------

# 1. Eureka Server (Discovery)
FROM eclipse-temurin:21-jre-alpine AS eureka-server
WORKDIR /app
COPY --from=builder /app/eureka-server/target/*.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

# 2. API Gateway
FROM eclipse-temurin:21-jre-alpine AS api-gateway
WORKDIR /app
COPY --from=builder /app/api-gateway/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

# 3. Auth Service
FROM eclipse-temurin:21-jre-alpine AS auth-service
WORKDIR /app
COPY --from=builder /app/auth-service/target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

# 4. User Service
FROM eclipse-temurin:21-jre-alpine AS user-service
WORKDIR /app
COPY --from=builder /app/user-service/target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

# 5. Booking Service
FROM eclipse-temurin:21-jre-alpine AS booking-service
WORKDIR /app
COPY --from=builder /app/booking-service/target/*.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

# 6. Notification Service
FROM eclipse-temurin:21-jre-alpine AS notification-service
WORKDIR /app
COPY --from=builder /app/notification-service/target/*.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]

# 7. Analytics Service
FROM eclipse-temurin:21-jre-alpine AS analytics-service
WORKDIR /app
COPY --from=builder /app/analytics-service/target/*.jar app.jar
EXPOSE 8085
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
