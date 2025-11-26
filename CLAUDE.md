# CLAUDE.md

Este archivo proporciona orientación a Claude Code (claude.ai/code) para trabajar con el código de este repositorio.

## Descripción del Proyecto

Aplicación CLI en Dart que consume la [Fake Store API](https://fakestoreapi.com/). Construida con Clean Architecture, parseo manual de JSON (sin generación de código) y manejo funcional de errores usando el tipo `Either` de `dartz`.

## Comandos

```bash
# Instalar dependencias
dart pub get

# Ejecutar la aplicación
dart run

# Ejecutar tests
dart test

# Ejecutar un archivo de test específico
dart test test/ruta/al/archivo_test.dart

# Analizar código
dart analyze

# Formatear código
dart format .
```

## Arquitectura

Clean Architecture de tres capas con patrón Service Locator (`get_it`).

### Responsabilidades por Capa

- **Domain** (`lib/src/domain/`): Lógica de negocio pura. Entidades (inmutables, extienden `Equatable`), casos de uso (implementan `UseCase<Type, Params>`) e interfaces de repositorio. Sin dependencias externas.

- **Data** (`lib/src/data/`): Comunicación con API y transformación de datos. Los modelos extienden las entidades y proveen métodos `fromJson()`/`toJson()` + `toEntity()`. Las implementaciones de repositorio extienden `BaseRepository` para el mapeo centralizado de excepciones a fallos.

- **Core** (`lib/src/core/`): Aspectos transversales. Contenedor de inyección de dependencias, `ApiResponseHandler` (patrón Strategy para códigos HTTP), excepciones personalizadas, clases `Failure` y configuración de entorno (`EnvConfig`).

### Patrones Clave

- **Repository Pattern**: Interfaz abstracta en domain, implementación concreta en data
- **Strategy Pattern**: `ApiResponseHandler` mapea códigos HTTP a excepciones mediante un mapa de funciones
- **BaseRepository**: Centraliza lógica try-catch, convierte excepciones a `Either<Failure, T>`
- **Use Case Pattern**: Cada caso de uso es una clase callable de responsabilidad única

### Flujo de Dependencias

```
Presentación (bin/) → Casos de Uso → Interfaz Repository ← Repository Impl → DataSource → HTTP
```

Todas las dependencias registradas en `lib/src/core/injection_container.dart`:
- Casos de Uso: `registerFactory` (nueva instancia por llamada)
- Repositories, DataSources, HTTP Client: `registerLazySingleton`

### Manejo de Errores

1. DataSource lanza excepciones tipadas (`ServerException`, `ConnectionException`, `NotFoundException`, `ClientException`)
2. El método `handleRequest()` del Repository captura excepciones y retorna `Left(Failure)`
3. Presentación usa `result.fold()` para manejar éxito/fallo

### Externalización de Textos

Todos los textos de usuario en `lib/src/util/strings.dart` (clase `AppStrings`).

## Variables de Entorno

La configuración se gestiona mediante archivos `.env` usando el paquete `dotenv`.

**Configuración inicial:**
1. Copiar `.env.example` a `.env`
2. Ajustar valores según el ambiente

**Variables disponibles:**
- `API_BASE_URL`: URL base de la API
- `API_TIMEOUT`: Timeout de peticiones HTTP (ms)
- `ENVIRONMENT`: Ambiente actual (`development`, `staging`, `production`)

**Clase de configuración:** `EnvConfig` (`lib/src/core/config/env_config.dart`)
- Patrón Singleton para acceso global
- Validación de variables requeridas al inicializar
- Debe inicializarse antes de `di.init()` en `main()`

## API

URL Base: Configurada en variable de entorno `API_BASE_URL`

Endpoints consumidos:
- `GET /products` - Todos los productos
- `GET /products/{id}` - Producto por ID
- `GET /products/categories` - Todas las categorías
