# Stage 1: Build with Maven on Corretto
FROM amazoncorretto:23 AS builder
WORKDIR /app

# Install Maven
RUN yum install -y maven && yum clean all

# Copy pom.xml and download dependencies first
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code only after dependencies are cached
COPY src ./src

# Build the project
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM amazoncorretto:23
WORKDIR /app

# Copy jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 9090
EXPOSE 5005
EXPOSE 9091
#EXPOSE 9092

ENV JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]

