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

- **`Application`**: Orquesta el flujo de la aplicación. Recibe una instancia de `UserInterface` por inyección de dependencias y coordina la interacción con los casos de uso.

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
bin/main → Application → UserInterface (Port) ← ConsoleUserInterface (Adapter)
                ↓
           Casos de Uso → Interfaz Repository ← Repository Impl → DataSources → ApiClient → HTTP
```

Todas las dependencias registradas en `lib/src/di/injection_container.dart`:
- `Application`, Casos de Uso: `registerFactory` (nueva instancia por llamada)
- `UserInterface`, Repositories, DataSources, HTTP Client: `registerLazySingleton`

**Convención de nombres:** Se usa `serviceLocator` en lugar de abreviaciones como `sl` para mejorar la legibilidad del código.

### Manejo de Errores

1. DataSource lanza excepciones tipadas (`ServerException`, `ConnectionException`, `NotFoundException`, `ClientException`)
2. El método `handleRequest()` del Repository captura excepciones y retorna `Left(Failure)`
3. `Application` usa `result.fold()` y delega la presentación del error a `UserInterface`

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
| **TOTAL** | **≥90%** | **96.83%** |
