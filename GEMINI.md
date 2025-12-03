# GEMINI.md

Guía para Gemini AI al trabajar con este repositorio.

## Descripción

Aplicación CLI en Dart que consume la [Fake Store API](https://fakestoreapi.com/). Clean Architecture, parseo manual de JSON y manejo funcional de errores con `Either` de `dartz`.

## Comandos

```bash
dart pub get                      # Instalar dependencias
dart run                          # Ejecutar aplicación
dart test                         # Ejecutar tests (164+, 87% cobertura)
dart analyze                      # Análisis estático
dart format .                     # Formatear código

# Docker
docker run -it juancarlos05/fake-store-cli
```

## Arquitectura

```
lib/src/
├── domain/          # Entidades, UseCases, Repository interfaces
├── data/            # Models (fromJson/toEntity), DataSources, Repository impls
├── presentation/    # UI desacoplada (Ports & Adapters)
├── core/            # Errors, Network, Config (EnvConfig singleton)
└── di/              # get_it (usar `serviceLocator`, no `sl`)
```

**Flujo:** UI → UseCase → Repository Interface ← Repository Impl → DataSource → ApiClient → HTTP

## Convenciones

- **Clean Architecture**: domain/data/presentation/core
- **Inyección de dependencias**: `get_it` en `lib/src/di/injection_container.dart`
- **Manejo de errores**: `Either<Failure, T>` de `dartz`, excepciones convertidas a Failures en Repository
- **Parseo JSON**: Manual en Models, sin generación de código
- **Textos de usuario**: Externalizados en `lib/src/util/strings.dart`
- **Variables de entorno**: `.env` con `API_BASE_URL`, manejado por `EnvConfig`
- **Documentación**: Comentarios `///` en español
- **SRP**: Un archivo = una clase/enum/interface

## Testing

- **Patrón AAA**: Arrange-Act-Assert
- **Nombres en español**: `'retorna lista cuando tiene éxito'`
- **Mocks**: `test/helpers/mocks.dart`, regenerar con `dart run build_runner build`
- **Helpers**: `test/helpers/test_helpers.dart`

## API Endpoints

- `GET /products` - Listar productos
- `GET /products/{id}` - Producto por ID
- `GET /products/categories` - Listar categorías
- `GET /products/category/{category}` - Productos por categoría
