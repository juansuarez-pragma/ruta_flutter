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

- **Data** (`lib/src/data/`): Comunicación con API y transformación de datos. Los modelos extienden las entidades y proveen métodos `fromJson()`/`toJson()` + `toEntity()`. Las implementaciones de repositorio extienden `BaseRepository` para el mapeo centralizado de excepciones a fallos.

- **Presentation** (`lib/src/presentation/`): Capa de interfaz de usuario desacoplada mediante el patrón Ports & Adapters (Hexagonal Architecture). Permite intercambiar implementaciones de UI (consola, GUI, web, móvil) sin modificar la lógica de negocio.

- **Core** (`lib/src/core/`): Aspectos transversales. Contenedor de inyección de dependencias, `ApiResponseHandler` (patrón Strategy para códigos HTTP), excepciones personalizadas, clases `Failure`, configuración de entorno (`EnvConfig`) y constantes de endpoints (`ApiEndpoints`).

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
│   └── environment.dart
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
2. Registrar la nueva implementación en `injection_container.dart`:
   ```dart
   sl.registerLazySingleton<UserInterface>(() => NuevaImplementacionUI());
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

// 3. Registrar en injection_container.dart
sl.registerLazySingleton<OrderRemoteDataSource>(
  () => OrderRemoteDataSourceImpl(apiClient: sl()),
);
```

### Flujo de Dependencias

```
bin/main → Application → UserInterface (Port) ← ConsoleUserInterface (Adapter)
                ↓
           Casos de Uso → Interfaz Repository ← Repository Impl → DataSources → ApiClient → HTTP
```

Todas las dependencias registradas en `lib/src/core/injection_container.dart`:
- `Application`, Casos de Uso: `registerFactory` (nueva instancia por llamada)
- `UserInterface`, Repositories, DataSources, HTTP Client: `registerLazySingleton`

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
- `API_BASE_URL`: URL base de la API
- `API_TIMEOUT`: Timeout de peticiones HTTP (ms)
- `ENVIRONMENT`: Ambiente actual (`development`, `staging`, `production`)

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
