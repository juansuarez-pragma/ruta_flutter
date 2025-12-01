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

Clean Architecture de tres capas con patrón Service Locator (`get_it`) y Ports & Adapters para la capa de presentación.

### Responsabilidades por Capa

- **Domain** (`lib/src/domain/`): Lógica de negocio pura. Entidades (inmutables, extienden `Equatable`), casos de uso (implementan `UseCase<Type, Params>`) e interfaces de repositorio. Sin dependencias externas.

- **Data** (`lib/src/data/`): Comunicación con API y transformación de datos. Los modelos proveen métodos `fromJson()` y `toEntity()` para transformar datos JSON a entidades de dominio. Las implementaciones de repositorio extienden `BaseRepository` para el mapeo centralizado de excepciones a fallos.

- **Presentation** (`lib/src/presentation/`): Capa de interfaz de usuario desacoplada mediante el patrón Ports & Adapters (Hexagonal Architecture). Permite intercambiar implementaciones de UI (consola, GUI, web, móvil) sin modificar la lógica de negocio.

- **Core** (`lib/src/core/`): Aspectos transversales. `ApiResponseHandler` (patrón Strategy para códigos HTTP), excepciones personalizadas, clases `Failure`, configuración de entorno (`EnvConfig`) y constantes de endpoints (`ApiEndpoints`).

- **DI** (`lib/src/di/`): Contenedor de inyección de dependencias. Centraliza el registro de todas las implementaciones usando `get_it` como Service Locator.

### Patrones Clave

- **Repository Pattern**: Interfaz abstracta en domain, implementación concreta en data
- **Strategy Pattern**: `ApiResponseHandler` mapea códigos HTTP a excepciones mediante un mapa de funciones
- **BaseRepository**: Centraliza lógica try-catch, convierte excepciones a `Either<Failure, T>`
- **Use Case Pattern**: Cada caso de uso es una clase callable de responsabilidad única
- **Ports & Adapters Pattern**: Desacopla la UI de la lógica de negocio mediante interfaces abstractas
- **Interface Segregation Principle (ISP)**: Interfaces de UI segregadas por responsabilidad
- **Single Responsibility Principle (SRP)**: Un archivo = una clase/enum/interface
- **Adapter Pattern**: Desacopla dependencias externas (dotenv, http) mediante interfaces

### Organización de Archivos (SRP)

Cada clase, enum o interface tiene su propio archivo. Los módulos usan barrel files para simplificar imports:

```
lib/src/core/
├── config/
│   ├── config.dart              # Barrel file
│   ├── env_reader.dart          # Interface abstracta (Port)
│   ├── dotenv_reader.dart       # Adapter para dotenv
│   ├── env_config.dart          # Usa EnvReader (desacoplado)
│   ├── env_config_exception.dart
│   └── utils/
│       └── environment_variables.dart  # Variables requeridas
├── errors/
│   ├── exceptions.dart          # Barrel file
│   ├── app_exception.dart
│   ├── server_exception.dart
│   ├── not_found_exception.dart
│   ├── client_exception.dart
│   ├── connection_exception.dart
│   ├── failures.dart            # Barrel file
│   ├── failure.dart
│   ├── server_failure.dart
│   ├── not_found_failure.dart
│   ├── client_failure.dart
│   └── connection_failure.dart
├── usecase/
│   ├── usecase.dart             # Barrel file
│   ├── use_case.dart
│   └── no_params.dart
└── ...

lib/src/data/datasources/
├── datasources.dart             # Barrel file principal
├── core/
│   ├── core.dart                # Barrel file
│   ├── api_client.dart          # Interface genérica para HTTP
│   └── api_client_impl.dart     # Implementación con lógica común
├── product/
│   ├── product.dart             # Barrel file
│   ├── product_remote_datasource.dart
│   └── product_remote_datasource_impl.dart
└── category/
    ├── category.dart            # Barrel file
    ├── category_remote_datasource.dart
    └── category_remote_datasource_impl.dart
```

**Uso de barrel files:**
```dart
// En lugar de múltiples imports específicos:
import 'package:.../errors/server_exception.dart';
import 'package:.../errors/client_exception.dart';

// Usar el barrel file:
import 'package:.../errors/exceptions.dart';
```

### Capa de Presentación (Ports & Adapters + ISP)

```
lib/src/presentation/
├── contracts/
│   ├── contracts.dart           # Barrel file
│   ├── user_interface.dart      # Interface compuesta (Port)
│   ├── user_input.dart
│   ├── message_output.dart
│   ├── product_output.dart
│   ├── category_output.dart
│   └── menu_option.dart
├── adapters/
│   └── console_user_interface.dart # Adapter: implementación para consola
└── application.dart               # Coordinador entre UI y casos de uso
```

**Interfaces Segregadas (ISP):**

Las interfaces de UI están segregadas por responsabilidad para cumplir con el Interface Segregation Principle:

- **`UserInput`**: Entrada de datos del usuario (`showMainMenu()`, `promptProductId()`)
- **`MessageOutput`**: Mensajes generales (`showWelcome()`, `showError()`, `showGoodbye()`, `showOperationInfo()`)
- **`ProductOutput`**: Visualización de productos (`showProducts()`, `showProduct()`)
- **`CategoryOutput`**: Visualización de categorías (`showCategories()`)
- **`UserInterface`**: Combina todas las interfaces anteriores

Esto permite que implementaciones parciales (ej. un widget que solo muestra productos) implementen únicamente las interfaces que necesitan.

**Componentes:**

- **`UserInterface`** (Port): Interfaz compuesta que extiende `UserInput`, `MessageOutput`, `ProductOutput` y `CategoryOutput`.

- **`ConsoleUserInterface`** (Adapter): Implementación concreta para terminal usando `stdin`/`stdout`.

- **`ApplicationController`**: Orquesta el flujo de la aplicación. Recibe una instancia de `UserInterface` por inyección de dependencias y coordina la interacción con los casos de uso.

**Cómo cambiar la UI:**

Para implementar una nueva interfaz (Flutter, web, etc.):

1. Crear una clase que implemente `UserInterface` (o solo las interfaces específicas que necesite)
2. Registrar la nueva implementación en `lib/src/di/injection_container.dart`:
   ```dart
   serviceLocator.registerLazySingleton<UserInterface>(() => NuevaImplementacionUI());
   ```

La lógica de negocio permanece intacta.

### Capa de DataSources (Escalabilidad)

La capa de DataSources está diseñada para escalar a múltiples endpoints sin duplicar código HTTP:

```
ApiClient (Interface genérica)
    ↑
ApiClientImpl (Lógica HTTP común: get, getList, getPrimitiveList)
    ↑
┌───┴───────────────┐
│                   │
ProductRemoteDS   CategoryRemoteDS   (+ futuros datasources)
```

**Componentes:**

- **`ApiClient`** (Interface): Define métodos genéricos para peticiones HTTP:
  - `get<T>()`: Obtener un objeto único
  - `getList<T>()`: Obtener lista de objetos con fromJson
  - `getPrimitiveList<T>()`: Obtener lista de tipos primitivos (strings, ints)

- **`ApiClientImpl`**: Centraliza la lógica HTTP (manejo de errores, headers, timeout). Evita duplicación de código en cada DataSource.

- **DataSources específicos** (`ProductRemoteDataSource`, `CategoryRemoteDataSource`): Delegan las peticiones HTTP al `ApiClient` y solo definen endpoints + transformaciones.

**Agregar un nuevo endpoint:**

```dart
// 1. Crear interface
abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getAll();
  Future<OrderModel> getById(int id);
}

// 2. Crear implementación (mínimo código repetido)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;
  OrderRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<OrderModel>> getAll() => _apiClient.getList(
    endpoint: ApiEndpoints.orders,
    fromJsonList: OrderModel.fromJson,
  );

  @override
  Future<OrderModel> getById(int id) => _apiClient.get(
    endpoint: ApiEndpoints.orderById(id),
    fromJson: (json) => OrderModel.fromJson(json as Map<String, dynamic>),
  );
}

// 3. Registrar en lib/src/di/injection_container.dart
serviceLocator.registerLazySingleton<OrderRemoteDataSource>(
  () => OrderRemoteDataSourceImpl(apiClient: serviceLocator()),
);
```

### Flujo de Dependencias

```
bin/main → ApplicationController → UserInterface (Port) ← ConsoleUserInterface (Adapter)
                ↓
           Casos de Uso → Interfaz Repository ← Repository Impl → DataSources → ApiClient → HTTP
```

Todas las dependencias registradas en `lib/src/di/injection_container.dart`:
- `ApplicationController`, Casos de Uso: `registerFactory` (nueva instancia por llamada)
- `UserInterface`, Repositories, DataSources, HTTP Client: `registerLazySingleton`

**Convención de nombres:** Se usa `serviceLocator` en lugar de abreviaciones como `sl` para mejorar la legibilidad del código.

### Manejo de Errores

1. DataSource lanza excepciones tipadas (`ServerException`, `ConnectionException`, `NotFoundException`, `ClientException`)
2. El método `handleRequest()` del Repository captura excepciones y retorna `Left(Failure)`
3. `ApplicationController` usa `result.fold()` y delega la presentación del error a `UserInterface`

### Externalización de Textos

Todos los textos de usuario en `lib/src/util/strings.dart` (clase `AppStrings`).

## Variables de Entorno

La configuración se gestiona mediante archivos `.env`. La implementación está desacoplada de la librería concreta mediante el patrón Adapter.

**Configuración inicial:**
1. Copiar `.env.example` a `.env`
2. Ajustar valores según el ambiente

**Variables disponibles:**
- `API_BASE_URL`: URL base de la API (requerida)

**Arquitectura de configuración:**

```
EnvConfig (Singleton) → EnvReader (Interface) ← DotEnvReader (Adapter)
```

- **`EnvReader`**: Interface abstracta para leer variables de entorno
- **`DotEnvReader`**: Implementación usando el paquete `dotenv`
- **`EnvConfig`**: Singleton que consume `EnvReader` sin conocer la implementación

**Cómo cambiar la librería de env:**

Para usar otra librería (ej. `flutter_dotenv`):

```dart
class FlutterDotEnvReader implements EnvReader {
  @override
  Future<void> load(String path) async {
    await dotenv.load(fileName: path);
  }

  @override
  String? operator [](String key) => dotenv.env[key];

  @override
  bool containsKey(String key) => dotenv.env.containsKey(key);
}

// En main():
await EnvConfig.instance.initialize(reader: FlutterDotEnvReader());
```

**Clase de configuración:** `EnvConfig` (`lib/src/core/config/env_config.dart`)
- Patrón Singleton para acceso global
- Desacoplado de la librería mediante `EnvReader`
- Validación de variables requeridas al inicializar
- Debe inicializarse antes de `di.init()` en `main()`

## API

URL Base: Configurada en variable de entorno `API_BASE_URL`

**Endpoints centralizados en:** `lib/src/core/constants/api_endpoints.dart`

Endpoints consumidos:
- `ApiEndpoints.products` → `GET /products`
- `ApiEndpoints.productById(id)` → `GET /products/{id}`
- `ApiEndpoints.categories` → `GET /products/categories`
- `ApiEndpoints.productsByCategory(category)` → `GET /products/category/{category}`

## Métricas de Calidad de Código

**IMPORTANTE:** Antes de implementar cualquier código, el agente DEBE verificar el cumplimiento de estas métricas. Después de implementar, ejecutar `dart analyze` y `dart format .` para validar.

### Checklist Obligatorio Pre-Implementación

- [ ] ¿El código sigue Clean Architecture? (dependencias fluyen hacia Domain)
- [ ] ¿Cada clase/enum/interface tiene su propio archivo? (SRP)
- [ ] ¿Se usan nombres descriptivos en español para comentarios?
- [ ] ¿Las excepciones incluyen información de diagnóstico?
- [ ] ¿Se evitan magic numbers? (usar constantes)
- [ ] ¿Se usa `Either<Failure, T>` para manejo de errores?

### Principios SOLID (Obligatorios)

| Principio | Implementación en este proyecto |
|-----------|--------------------------------|
| **S**ingle Responsibility | Un archivo = una clase. Cada clase tiene una única razón para cambiar. |
| **O**pen/Closed | Extender comportamiento sin modificar código existente (ej. nuevos DataSources). |
| **L**iskov Substitution | Las implementaciones pueden sustituir sus interfaces sin romper el sistema. |
| **I**nterface Segregation | Interfaces pequeñas y específicas (`UserInput`, `ProductOutput`, etc.). |
| **D**ependency Inversion | Depender de abstracciones, no de implementaciones concretas. |

### Estándares de Código

#### Nomenclatura
- **Clases**: `PascalCase` (ej. `ProductEntity`, `GetAllProductsUseCase`)
- **Archivos**: `snake_case` (ej. `product_entity.dart`, `get_all_products_usecase.dart`)
- **Variables/métodos privados**: Prefijo `_` (ej. `_apiClient`, `_handleRequest`)
- **Constantes**: `camelCase` para miembros de clase, `SCREAMING_SNAKE_CASE` solo para constantes globales
- **Comentarios**: Siempre en **español**

#### Documentación Obligatoria
Todo código público DEBE tener documentación `///` en español:

```dart
/// Caso de uso para obtener todos los productos.
///
/// Retorna [Either] con [Failure] en caso de error o lista de [ProductEntity] en éxito.
class GetAllProductsUseCase implements UseCase<List<ProductEntity>, NoParams> {
```

#### Estructura de Archivos

```dart
// 1. Imports de paquetes externos (ordenados alfabéticamente)
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// 2. Imports del proyecto (ordenados alfabéticamente)
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

// 3. Documentación de clase
/// Descripción de la clase en español.

// 4. Declaración de clase
class MiClase {
  // 5. Campos (primero finales, luego mutables)
  final Dependencia _dependencia;

  // 6. Constructor
  MiClase({required Dependencia dependencia}) : _dependencia = dependencia;

  // 7. Métodos públicos

  // 8. Métodos privados
}
```

### Manejo de Errores

#### Excepciones (Capa Data)
Las excepciones DEBEN incluir información de diagnóstico cuando sea relevante:

```dart
// ✅ Correcto: Incluye contexto
throw ConnectionException(
  uri: uri,
  originalError: e.message,
);

// ❌ Incorrecto: Sin contexto
throw ConnectionException();
```

#### Failures (Capa Domain)
Usar el patrón `Either` de `dartz` para retornar errores sin lanzar excepciones:

```dart
// ✅ Correcto
Future<Either<Failure, ProductEntity>> getProduct(int id);

// ❌ Incorrecto
Future<ProductEntity> getProduct(int id); // Puede lanzar excepciones
```

### Configuración del Linter

El proyecto usa reglas estrictas en `analysis_options.yaml`:

```yaml
analyzer:
  errors:
    unused_local_variable: error
    unused_import: error
    unused_element: error
    dead_code: error
    unused_field: error
```

**Antes de cada commit:**
1. Ejecutar `dart analyze` → 0 errores
2. Ejecutar `dart format .` → Formatear código
3. Verificar que no hay código muerto ni imports sin usar

### Patrones de Implementación

#### Nuevo Caso de Uso

```dart
// lib/src/domain/usecases/mi_nuevo_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';

/// Caso de uso para [descripción en español].
class MiNuevoUseCase implements UseCase<TipoRetorno, TipoParams> {
  final MiRepository _repository;

  MiNuevoUseCase(this._repository);

  @override
  Future<Either<Failure, TipoRetorno>> call(TipoParams params) async {
    return await _repository.miMetodo(params.valor);
  }
}
```

#### Nueva Entidad

```dart
// lib/src/domain/entities/mi_entidad.dart
import 'package:equatable/equatable.dart';

/// Entidad que representa [descripción en español].
///
/// Es inmutable y usa [Equatable] para comparación por valor.
class MiEntidad extends Equatable {
  final int id;
  final String nombre;

  const MiEntidad({
    required this.id,
    required this.nombre,
  });

  @override
  List<Object?> get props => [id, nombre];
}
```

#### Nuevo DataSource

```dart
// lib/src/data/datasources/mi_feature/mi_feature_remote_datasource.dart

/// Interface para el origen de datos remoto de [feature].
abstract class MiFeatureRemoteDataSource {
  /// Obtiene todos los [items] desde la API.
  Future<List<MiModel>> getAll();
}

// lib/src/data/datasources/mi_feature/mi_feature_remote_datasource_impl.dart

/// Implementación de [MiFeatureRemoteDataSource] usando [ApiClient].
class MiFeatureRemoteDataSourceImpl implements MiFeatureRemoteDataSource {
  final ApiClient _apiClient;

  MiFeatureRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<MiModel>> getAll() {
    return _apiClient.getList(
      endpoint: ApiEndpoints.miEndpoint,
      fromJsonList: MiModel.fromJson,
    );
  }
}
```

### Validación Final

Antes de considerar una implementación completa, verificar:

| Criterio | Validación |
|----------|------------|
| Arquitectura | Las dependencias fluyen hacia Domain (nunca al revés) |
| SOLID | Todos los principios se respetan |
| Análisis estático | `dart analyze` retorna 0 errores |
| Formato | `dart format .` no genera cambios |
| Documentación | Toda clase/método público tiene `///` en español |
| Errores | Se usa `Either<Failure, T>` en capas domain/data |
| Constantes | No hay magic numbers ni strings hardcodeados |
| Nombres | Descriptivos, sin abreviaciones confusas |

### Métricas de Calidad Objetivo

| Métrica | Objetivo | Actual |
|---------|----------|--------|
| Arquitectura y Diseño | ≥90% | 95% |
| Legibilidad y Mantenibilidad | ≥90% | 98% |
| Patrones y Buenas Prácticas | ≥90% | 98% |
| Manejo de Errores | ≥85% | 95% |
| Configuración y Seguridad | ≥85% | 95% |
| Análisis Estático | 100% | 100% |
| Cobertura de Tests | ≥90% | 93%+ |
| **TOTAL** | **≥90%** | **96%** |

## Metodología TDD

El proyecto sigue la metodología **Test-Driven Development (TDD)** de forma obligatoria para toda nueva funcionalidad.

### Ciclo Red-Green-Refactor

```
┌─────────┐    ┌─────────┐    ┌──────────┐
│   RED   │───▶│  GREEN  │───▶│ REFACTOR │───┐
│ (Test)  │    │ (Code)  │    │ (Clean)  │   │
└─────────┘    └─────────┘    └──────────┘   │
     ▲                                        │
     └────────────────────────────────────────┘
```

1. **RED**: Escribir test que FALLA (código no existe)
2. **GREEN**: Escribir código MÍNIMO para pasar
3. **REFACTOR**: Mejorar código sin romper tests

### Orden de Implementación TDD

```
1. Domain Layer (primero)
   ├── UseCase Test → UseCase Implementation
   └── Repository Interface (si es nuevo)

2. Data Layer (segundo)
   ├── DataSource Test → DataSource Implementation
   ├── Repository Test → Repository Implementation
   └── Model Test → Model (si es nuevo)

3. Presentation Layer (tercero)
   └── ApplicationController Test → ApplicationController updates
```

### Especificación Obligatoria

Antes de escribir cada test, documentar la especificación:

```dart
/// ESPECIFICACIÓN: [NombreComponente]
///
/// Responsabilidad: [Una sola responsabilidad]
///
/// Entrada:
///   - [param1]: [tipo] - [descripción]
///
/// Salida esperada (éxito):
///   - [tipo de retorno y condiciones]
///
/// Salida esperada (error):
///   - [tipos de error y cuándo ocurren]
///
/// Precondiciones:
///   - [condiciones que deben cumplirse]
///
/// Postcondiciones:
///   - [efectos después de la ejecución]
```

**Documentación completa:** Ver `docs/TDD_PROCESS.md`

## ATDD (Acceptance Test-Driven Development)

El proyecto implementa tests de aceptación en formato BDD (Behavior-Driven Development) con Given-When-Then.

### Estructura de Tests de Aceptación

```
test/acceptance/
├── acceptance_test_base.dart       # Helpers BDD
└── features/
    ├── product_listing_acceptance_test.dart
    ├── product_detail_acceptance_test.dart
    └── product_category_acceptance_test.dart
```

### Formato de Tests

```dart
test(
  'Given catálogo con productos, '
  'When solicita ver todos, '
  'Then recibe lista completa',
  () async {
    // Given
    final productList = createTestProductEntityList(count: 5);
    when(mockRepository.getAllProducts())
        .thenAnswer((_) async => Right(productList));

    // When
    final result = await useCase(const NoParams());

    // Then
    expect(result.isRight(), isTrue);
  },
);
```

### Features Documentadas

| Feature | Criterios de Aceptación | Tests |
|---------|------------------------|-------|
| Listado de Productos | 6 | 6 |
| Detalle de Producto | 6 | 6 |
| Filtrar por Categoría | 6 | 6 |
| **Total** | **18** | **18** |

**Documentación completa:** Ver `docs/FASE_3_ATDD_REPORT.md`

## CI/CD (Integración Continua)

El proyecto usa GitHub Actions para automatizar calidad de código.

### Pipeline

```
.github/workflows/ci.yml
```

**Jobs:**
1. **lint**: Formato (`dart format`) y análisis estático (`dart analyze`)
2. **unit-test**: Tests unitarios e integración
3. **acceptance-test**: Tests de aceptación ATDD

**Triggers:** Pull Request a `main`

**Comandos locales para simular CI:**
```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart test test/acceptance/
```

## Docker

El proyecto incluye soporte para contenedores Docker, permitiendo ejecutar la aplicación sin instalar Dart.

### Archivos Docker

```
Dockerfile          # Multi-stage build para imagen optimizada
.dockerignore       # Excluye archivos innecesarios del build
```

### Arquitectura del Dockerfile

El Dockerfile usa **multi-stage build** para crear una imagen final liviana:

```
┌─────────────────────────────────────────────────────────┐
│ ETAPA 1: Build (dart:3.9.2)                             │
│ ├── Instala dependencias (dart pub get)                 │
│ ├── Copia código fuente                                 │
│ └── Compila a ejecutable nativo (dart compile exe)      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│ ETAPA 2: Runtime (debian:bookworm-slim)                 │
│ ├── Instala certificados SSL (ca-certificates)          │
│ ├── Copia ejecutable compilado (~10MB)                  │
│ └── Copia configuración (.env.example → .env)           │
└─────────────────────────────────────────────────────────┘
```

**Beneficios:**
- Imagen final ~80MB (vs ~800MB con SDK completo)
- Ejecutable nativo sin necesidad de Dart runtime
- Tiempos de inicio rápidos

### Comandos Docker

```bash
# Construir imagen
docker build -t juancarlos05/fake-store-cli:latest .

# Ejecutar contenedor (modo interactivo)
docker run -it juancarlos05/fake-store-cli

# Ejecutar con variables de entorno personalizadas
docker run -it -e API_BASE_URL=https://otra-api.com juancarlos05/fake-store-cli
```

### Publicar en Docker Hub

```bash
# 1. Login en Docker Hub
docker login

# 2. Construir imagen
docker build -t juancarlos05/fake-store-cli:latest .

# 3. Publicar
docker push juancarlos05/fake-store-cli:latest
```

### Usuarios descargan y ejecutan

```bash
docker run -it juancarlos05/fake-store-cli
```

### Estructura del Dockerfile

| Línea | Comando | Descripción |
|-------|---------|-------------|
| `FROM dart:3.9.2 AS build` | Imagen base con Dart SDK |
| `WORKDIR /app` | Directorio de trabajo |
| `COPY pubspec.* ./` | Copia dependencias (optimiza cache) |
| `RUN dart pub get` | Instala dependencias |
| `COPY . .` | Copia código fuente |
| `RUN dart compile exe ...` | Compila a ejecutable nativo AOT |
| `FROM debian:bookworm-slim` | Imagen final liviana |
| `RUN apt-get install ca-certificates` | Certificados SSL para HTTPS |
| `COPY --from=build .../app` | Copia solo el ejecutable |
| `COPY --from=build .../.env.example` | Copia configuración |
| `ENTRYPOINT ["/app/bin/app"]` | Comando de inicio |

## Testing

El proyecto cuenta con una suite completa de tests unitarios e integración con cobertura del 93%+.

### Estructura de Tests

```
test/
├── fixtures/                    # Datos JSON de prueba
│   └── product_fixtures.dart
├── helpers/                     # Utilidades compartidas
│   ├── mocks.dart              # Definiciones @GenerateMocks
│   ├── mocks.mocks.dart        # Generado por build_runner
│   └── test_helpers.dart       # Funciones factory
├── unit/
│   ├── domain/
│   │   ├── entities/           # Tests de entidades (Equatable)
│   │   └── usecases/           # Tests de casos de uso
│   ├── data/
│   │   ├── models/             # Tests de fromJson/toEntity
│   │   ├── repositories/       # Tests de mapeo excepciones→failures
│   │   └── datasources/        # Tests de delegación a ApiClient
│   ├── core/
│   │   ├── network/            # Tests de ApiResponseHandler
│   │   ├── errors/             # Tests de Failures y Exceptions
│   │   └── config/             # Tests de EnvConfig
│   └── presentation/
│       └── contracts/          # Tests de MenuOption
├── integration/
│   └── presentation/           # Tests de ApplicationController (flujos completos)
└── acceptance/
    └── features/               # Tests de aceptación BDD
```

### Comandos de Testing

```bash
# Ejecutar todos los tests
dart test

# Ejecutar tests de una capa específica
dart test test/unit/domain/
dart test test/unit/data/
dart test test/unit/core/
dart test test/integration/

# Ejecutar un archivo específico
dart test test/unit/domain/usecases/get_all_products_usecase_test.dart

# Ejecutar tests con cobertura
dart test --coverage=coverage

# Generar reporte de cobertura
~/.pub-cache/bin/format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

# Regenerar mocks después de cambiar interfaces
dart run build_runner build --delete-conflicting-outputs
```

### Dependencias de Testing

```yaml
dev_dependencies:
  test: 1.25.6
  mockito: ^5.4.4        # Generación de mocks
  build_runner: ^2.4.13  # Generación de código
```

### Guía para Escribir Tests

#### Patrón AAA (Arrange-Act-Assert)

Todos los tests DEBEN seguir este patrón:

```dart
test('descripción del comportamiento esperado', () async {
  // Arrange - Preparar datos y configurar mocks
  final testData = createTestProductEntityList();
  when(mockRepository.getAllProducts())
      .thenAnswer((_) async => Right(testData));

  // Act - Ejecutar la acción bajo prueba
  final result = await useCase(const NoParams());

  // Assert - Verificar el resultado
  expect(result, Right(testData));
  verify(mockRepository.getAllProducts()).called(1);
  verifyNoMoreInteractions(mockRepository);
});
```

#### Nomenclatura de Tests

- Nombres en **español**, descriptivos del comportamiento
- Formato: `'[contexto] [acción] [resultado esperado]'`

```dart
// ✅ Correcto
test('retorna lista de productos cuando el repositorio tiene éxito', () {});
test('retorna ServerFailure cuando el datasource lanza ServerException', () {});
test('lanza NotFoundException para código 404', () {});

// ❌ Incorrecto
test('test1', () {});
test('works', () {});
test('should return products', () {});  // En inglés
```

#### Testing de Either (dartz)

```dart
// Verificar Right (éxito)
expect(result.isRight(), isTrue);
result.fold(
  (failure) => fail('No debería retornar failure'),
  (value) => expect(value, expectedValue),
);

// Verificar Left (error)
expect(result.isLeft(), isTrue);
result.fold(
  (failure) {
    expect(failure, isA<ServerFailure>());
    expect(failure.message, expectedMessage);
  },
  (_) => fail('No debería retornar Right'),
);
```

#### Uso de Mocks

```dart
// Configurar respuesta exitosa
when(mockDataSource.getAll()).thenAnswer((_) async => testModels);

// Configurar excepción
when(mockDataSource.getAll()).thenThrow(ServerException());

// Verificar llamada única
verify(mockRepository.getAll()).called(1);

// Verificar nunca llamado
verifyNever(mockRepository.delete(any));

// Verificar sin más interacciones
verifyNoMoreInteractions(mockRepository);
```

### Cobertura por Capa

| Capa | Tests | Cobertura Objetivo |
|------|-------|-------------------|
| Domain | entities, usecases | 100% |
| Data | models, repositories, datasources | ≥90% |
| Core | network, errors, config | ≥85% |
| Presentation | application, contracts | ≥80% |
| **Total** | **207 tests** | **≥90%** |

### Agregar Tests para Nueva Funcionalidad

Al agregar nueva funcionalidad, seguir este orden:

1. **Domain Tests** (primero):
   - Test de entidad (si es nueva)
   - Test de use case

2. **Data Tests**:
   - Test de model (`fromJson`, `toEntity`)
   - Test de repository (mapeo de excepciones)
   - Test de datasource (delegación a ApiClient)

3. **Core Tests** (si aplica):
   - Tests de nuevas excepciones/failures
   - Tests de nuevos handlers

4. **Integration Tests**:
   - Test del flujo completo en ApplicationController

#### Plantilla para Test de UseCase

```dart
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/mi_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late MiUseCase useCase;
  late MockMiRepository mockRepository;

  setUp(() {
    mockRepository = MockMiRepository();
    useCase = MiUseCase(mockRepository);
  });

  group('MiUseCase', () {
    test('retorna datos cuando el repositorio tiene éxito', () async {
      // Arrange
      final testData = createTestData();
      when(mockRepository.getData())
          .thenAnswer((_) async => Right(testData));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Right(testData));
      verify(mockRepository.getData()).called(1);
    });

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = ServerFailure('Error');
      when(mockRepository.getData())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(failure));
    });
  });
}
```

#### Plantilla para Test de Repository

```dart
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/repositories/mi_repository_impl.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late MiRepositoryImpl repository;
  late MockMiRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMiRemoteDataSource();
    repository = MiRepositoryImpl(dataSource: mockDataSource);
  });

  group('MiRepositoryImpl', () {
    test('retorna Right con datos cuando datasource tiene éxito', () async {
      // Arrange
      final testModels = createTestModelList();
      when(mockDataSource.getAll()).thenAnswer((_) async => testModels);

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('retorna Left ServerFailure cuando datasource lanza ServerException', () async {
      // Arrange
      when(mockDataSource.getAll()).thenThrow(ServerException());

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('No debería retornar Right'),
      );
    });

    test('retorna Left ConnectionFailure cuando datasource lanza ConnectionException', () async {
      // Arrange
      when(mockDataSource.getAll()).thenThrow(
        ConnectionException(uri: Uri.parse('https://api.test.com')),
      );

      // Act
      final result = await repository.getAll();

      // Assert
      result.fold(
        (failure) => expect(failure, isA<ConnectionFailure>()),
        (_) => fail('No debería retornar Right'),
      );
    });
  });
}
```

### Agregar Nuevos Mocks

Cuando se crea una nueva interface que necesita ser mockeada:

1. Agregar al archivo `test/helpers/mocks.dart`:
   ```dart
   @GenerateMocks([
     // ... mocks existentes
     NuevaInterface,  // Agregar aquí
   ])
   void main() {}
   ```

2. Regenerar mocks:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Importar en el test:
   ```dart
   import '../../helpers/mocks.mocks.dart';
   // Usar: MockNuevaInterface
   ```

### Helpers Disponibles

En `test/helpers/test_helpers.dart`:

```dart
// Crear entidad de prueba
ProductEntity createTestProductEntity({
  int id = 1,
  String title = 'Producto de prueba',
  double price = 99.99,
  // ...
});

// Crear modelo de prueba
ProductModel createTestProductModel({...});

// Crear lista de entidades
List<ProductEntity> createTestProductEntityList({int count = 2});

// Crear lista de modelos
List<ProductModel> createTestProductModelList({int count = 2});

// Crear lista de categorías
List<String> createTestCategories();
```

### Fixtures Disponibles

En `test/fixtures/product_fixtures.dart`:

```dart
// JSON válido
const Map<String, dynamic> validProductJson;
const Map<String, dynamic> validProductJson2;

// JSON con precio entero (para probar conversión num→double)
const Map<String, dynamic> productJsonWithIntPrice;

// JSON incompleto (para probar errores)
const Map<String, dynamic> incompleteProductJson;

// JSON con tipo incorrecto
const Map<String, dynamic> wrongTypeProductJson;

// Lista de JSONs
const List<Map<String, dynamic>> validProductListJson;

// Lista de categorías
const List<String> validCategoriesList;
```

### Verificación Pre-Commit

Antes de cada commit, ejecutar:

```bash
# 1. Todos los tests pasan
dart test

# 2. Análisis estático sin errores
dart analyze

# 3. Código formateado
dart format .

# 4. (Opcional) Verificar cobertura
dart test --coverage=coverage
```
