# Imagen base de Dart
FROM dart:3.9.2 AS build

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias primero (mejor cache)
COPY pubspec.* ./

# Instalar dependencias
RUN dart pub get

# Copiar el resto del código
COPY . .

# Compilar a ejecutable nativo (AOT)
RUN dart compile exe bin/fase_2_consumo_api.dart -o bin/app

# ============================================
# Imagen final (más liviana)
# ============================================
FROM debian:bookworm-slim

# Instalar dependencias mínimas de runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar ejecutable compilado
COPY --from=build /app/bin/app /app/bin/app

# Copiar archivo de configuración (desde .env.example)
COPY --from=build /app/.env.example /app/.env

# Ejecutar en modo interactivo
ENTRYPOINT ["/app/bin/app"]
