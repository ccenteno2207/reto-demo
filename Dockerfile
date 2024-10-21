# Etapa 1: Construcción - ccenteno
# FROM maven:3.8.5-openjdk-17 AS builder
FROM openjdk:17-jdk-slim AS builder

# Variables de Maven
ENV MAVEN_VERSION=3.6.9
ENV MAVEN_HOME=/opt/apache-maven-${MAVEN_VERSION}
ENV PATH=$MAVEN_HOME/bin:$PATH

# Instalar Maven 3.6.9 manualmente
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/bin/mvn 
#    && rm -rf /var/lib/apt/lists/*

# Verificar la instalación de Maven
RUN mvn -version && java -version

WORKDIR /app
COPY pom.xml .
COPY mvnw mvnw.cmd .

RUN chmod +x mvnw
RUN mvn wrapper:wrapper
RUN ./mvnw dependency:go-offline

COPY src ./src
RUN ./mvnw clean package -DskipTests

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=builder /app/target/demo-0.0.1-SNAPSHOT.jar /app/demo.jar

EXPOSE 8080

CMD ["java", "-jar", "/app/demo.jar"]