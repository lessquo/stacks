FROM eclipse-temurin:21-jdk
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Prefetch Gradle + dependencies in their own layer so source edits don't refetch.
COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle gradle
RUN ./gradlew --no-daemon dependencies

COPY src src

EXPOSE 8080
CMD ["./gradlew", "--no-daemon", "bootRun"]
