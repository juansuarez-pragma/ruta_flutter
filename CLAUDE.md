# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripción

Aplicación CLI en Dart que consume la [Fake Store API](https://fakestoreapi.com/). Clean Architecture, parseo manual de JSON y manejo funcional de errores con `Either` de `dartz`.

## Comandos

```bash
dart pub get                      # Instalar dependencias
dart run                          # Ejecutar aplicación
dart test                         # Ejecutar todos los tests
dart test test/ruta/archivo.dart  # Test específico
dart analyze                      # Análisis estático
dart format .                     # Formatear código

# Regenerar mocks después de cambiar interfaces
dart run build_runner build --delete-conflicting-outputs

# Docker
docker build -t fake-store-cli .
docker run -it fake-store-cli
```

## Arquitectura

Clean Architecture de tres capas + Core transversal:

```
lib/src/
├── domain/          # Lógica de negocio pura (sin dependencias externas)
│   ├── entities/    # Clases inmutables con Equatable
│   ├── repositories/# Interfaces abstractas
│   └── usecases/    # Implementan UseCase<Type, Params>
├── data/            # Comunicación externa
│   ├── models/      # fromJson() + toEntity()
│   ├── datasources/ # ApiClient delega HTTP
│   └── repositories/# Extienden BaseRepository
├── presentation/    # UI desacoplada (Ports & Adapters)
│   ├── contracts/   # Interfaces segregadas (ISP)
│   └── adapters/    # ConsoleUserInterface
├── core/            # Transversal
│   ├── config/      # EnvConfig (Singleton + Adapter)
│   ├── errors/      # Exceptions → Failures
│   ├── network/     # ApiResponseHandler (Strategy)
│   └── usecase/     # UseCase base + NoParams
└── di/              # get_it (usar `serviceLocator`, no `sl`)
```

**Flujo de datos:**
```
UI → UseCase → Repository Interface ← Repository Impl → DataSource → ApiClient → HTTP
```

## Agregar Nueva Funcionalidad

### Nuevo Endpoint (orden TDD)

1. **Domain**: Test de UseCase → Implementación → Agregar método a Repository interface
2. **Data**: Test de DataSource → Implementación delegando a ApiClient
3. **Data**: Test de Repository → Implementación extendiendo BaseRepository
4. **DI**: Registrar en `lib/src/di/injection_container.dart`
5. **Presentation**: Integrar en ApplicationController

### Ejemplo DataSource

```dart
// Solo definir endpoint + transformación, ApiClient maneja HTTP
Future<List<OrderModel>> getAll() => _apiClient.getList(
  endpoint: ApiEndpoints.orders,
  fromJsonList: OrderModel.fromJson,
);
```

## Convenciones

### Nomenclatura
- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Privados**: Prefijo `_`
- **Comentarios/Docs**: Siempre en español con `///`

### Principio SRP
Un archivo = una clase/enum/interface. Usar barrel files para exports.

### Manejo de Errores
- DataSource lanza excepciones tipadas (`ServerException`, `ConnectionException`, etc.)
- Repository captura con `handleRequest()` y retorna `Either<Failure, T>`
- Presentation usa `result.fold()` para manejar ambos casos

### Código
```dart
// ✅ Correcto
Future<Either<Failure, ProductEntity>> getProduct(int id);

// ❌ Incorrecto - puede lanzar excepciones
Future<ProductEntity> getProduct(int id);
```

## Testing

- **Patrón AAA**: Arrange-Act-Assert
- **Nombres en español**: `'retorna lista cuando el repositorio tiene éxito'`
- **164+ tests**, 87% cobertura
- **Mocks**: Definir en `test/helpers/mocks.dart`, regenerar con build_runner
- **Helpers**: `test/helpers/test_helpers.dart` (factories de entidades/modelos)
- **Fixtures**: `test/fixtures/product_fixtures.dart` (JSON de prueba)

```dart
test('retorna productos cuando tiene éxito', () async {
  // Arrange
  when(mockRepository.getAll()).thenAnswer((_) async => Right(testData));
  // Act
  final result = await useCase(NoParams());
  // Assert
  expect(result, Right(testData));
  verify(mockRepository.getAll()).called(1);
});
```

## Variables de Entorno

```bash
cp .env.example .env
```

| Variable | Descripción | Requerida |
|----------|-------------|-----------|
| `API_BASE_URL` | URL base de la API | Sí |

`EnvConfig` debe inicializarse antes de `di.init()` en `main()`.

## API Endpoints

Centralizados en `lib/src/core/constants/api_endpoints.dart`:

- `GET /products` - Listar productos
- `GET /products/{id}` - Producto por ID
- `GET /products/categories` - Listar categorías
- `GET /products/category/{category}` - Productos por categoría

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`):
- **lint**: `dart format` + `dart analyze`
- **unit-test**: Tests unitarios
- **acceptance-test**: Tests ATDD (Given-When-Then)

## Validación Pre-Commit

```bash
dart analyze        # 0 errores
dart format .       # Sin cambios
dart test           # Todos pasan
```

## Textos de Usuario

Externalizados en `lib/src/util/strings.dart` (clase `AppStrings`).
