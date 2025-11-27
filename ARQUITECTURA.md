# Arquitectura del Proyecto - Fase 2: Consumo de API

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Visión General de Clean Architecture](#visión-general-de-clean-architecture)
3. [Estructura de Capas](#estructura-de-capas)
4. [Patrones de Diseño Implementados](#patrones-de-diseño-implementados)
5. [Flujo de Datos](#flujo-de-datos)
6. [Manejo de Errores](#manejo-de-errores)
7. [Variables de Entorno](#variables-de-entorno)
8. [Inyección de Dependencias](#inyección-de-dependencias)
9. [Diagrama de Arquitectura](#diagrama-de-arquitectura)

---

## Introducción

Este proyecto implementa **Clean Architecture** (Arquitectura Limpia) propuesta por Robert C. Martin (Uncle Bob). El objetivo principal es crear una aplicación escalable, mantenible y testeable mediante la separación clara de responsabilidades.

### Principios Fundamentales

- **Independencia de Frameworks**: La lógica de negocio no depende de bibliotecas externas.
- **Testeable**: La lógica de negocio puede probarse sin UI, base de datos o servicios externos.
- **Independencia de UI**: La interfaz puede cambiar sin afectar la lógica de negocio.
- **Independencia de Base de Datos**: Podemos cambiar la fuente de datos sin afectar el dominio.
- **Independencia de Agentes Externos**: La lógica de negocio no sabe nada sobre el mundo exterior.

---

## Visión General de Clean Architecture

La arquitectura está dividida en **tres capas principales**, cada una con responsabilidades específicas:

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                         │
│                   (bin/main.dart)                       │
│                 CLI Interactivo                         │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                      DOMAIN LAYER                       │
│           (lib/src/domain/)                             │
│  • Entidades (Entities)                                 │
│  • Casos de Uso (Use Cases)                             │
│  • Contratos de Repositorio (Repository Interfaces)     │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                       DATA LAYER                        │
│            (lib/src/data/)                              │
│  • Modelos (Models)                                     │
│  • Fuentes de Datos (DataSources)                       │
│  • Implementación de Repositorios                       │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                       CORE LAYER                        │
│             (lib/src/core/)                             │
│  • Errores y Excepciones                                │
│  • Utilidades de Red                                    │
│  • Inyección de Dependencias                            │
│  • Clases Base Reutilizables                            │
│  • Configuración de Entorno (EnvConfig)                 │
└─────────────────────────────────────────────────────────┘
```

---

## Estructura de Capas

### 1. Capa de Dominio (Domain Layer)

**Ubicación:** `lib/src/domain/`

La capa más interna y pura. Contiene la lógica de negocio de la aplicación. **No tiene dependencias externas** y no conoce detalles de implementación.

#### 1.1 Entidades (`entities/`)

Representan los objetos de negocio del dominio. Son clases inmutables que contienen la lógica de negocio pura.

**Ejemplo: `product_entity.dart`**

```dart
class ProductEntity extends Equatable {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  @override
  List<Object> get props => [id, title, price, description, category, image];
}
```

**Características:**
- Extiende `Equatable` para comparación de objetos por valor
- Inmutable (todos los campos son `final`)
- No contiene lógica de persistencia o presentación

#### 1.2 Repositorios (`repositories/`)

Define **interfaces abstractas** (contratos) que la capa de datos debe implementar.

**Ejemplo: `product_repository.dart`**

```dart
abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getAllProducts();
  Future<Either<Failure, ProductEntity>> getProductById(int id);
  Future<Either<Failure, List<String>>> getAllCategories();
}
```

**Características:**
- Retorna `Either<Failure, Type>` para manejo funcional de errores
- No contiene implementación, solo define el contrato
- Permite cambiar la fuente de datos sin afectar el dominio

#### 1.3 Casos de Uso (`usecases/`)

Contienen la **lógica de negocio específica** de la aplicación. Cada caso de uso realiza una única acción.

**Ejemplo: `get_all_products_usecase.dart`**

```dart
class GetAllProductsUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetAllProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getAllProducts();
  }
}
```

**Características:**
- Implementa la interfaz `UseCase<Type, Params>`
- Encapsula una única acción de negocio
- Orquesta la llamada al repositorio

---

### 2. Capa de Datos (Data Layer)

**Ubicación:** `lib/src/data/`

Responsable de **obtener y almacenar datos**. Implementa los contratos definidos en la capa de dominio.

#### 2.1 Modelos (`models/`)

Representan la estructura de datos que viene de fuentes externas (API, base de datos). Contienen lógica de serialización/deserialización.

**Ejemplo: `product_model.dart`**

```dart
class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  // Parseo manual de JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
    );
  }

  // Mapeo a entidad de dominio
  ProductEntity toEntity() => ProductEntity(
        id: id,
        title: title,
        price: price,
        description: description,
        category: category,
        image: image,
      );
}
```

**Características:**
- Clase independiente con sus propios campos
- Implementa `fromJson()` para deserialización
- Método `toEntity()` para mapear a objetos de dominio
- Parseo manual sin herramientas de generación de código

#### 2.2 Fuentes de Datos (`datasources/`)

Responsables de comunicarse con fuentes externas (APIs, bases de datos, caché).

**Ejemplo: `api_datasource.dart`**

```dart
abstract class ApiDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductById(int id);
  Future<List<String>> getAllCategories();
}

class ApiDataSourceImpl implements ApiDataSource {
  final http.Client client;
  final ApiResponseHandler responseHandler;
  final EnvConfig _config;

  ApiDataSourceImpl({
    required this.client,
    required this.responseHandler,
    EnvConfig? config,
  }) : _config = config ?? EnvConfig.instance;

  String get _baseUrl => _config.apiBaseUrl;

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final uri = Uri.parse('$_baseUrl/products');
    try {
      final response = await client.get(uri);
      responseHandler.handleResponse(response);
      return (json.decode(response.body) as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } on http.ClientException {
      throw ConnectionException();
    }
  }
  // ... más métodos
}
```

**Características:**
- Maneja la comunicación HTTP
- Lanza excepciones específicas en caso de error
- Convierte JSON en modelos
- Obtiene la URL base desde `EnvConfig` (no hardcodeada)

#### 2.3 Implementación de Repositorios (`repositories/`)

Implementa los contratos definidos en la capa de dominio. Coordina entre fuentes de datos y transforma modelos en entidades.

**Ejemplo: `product_repository_impl.dart`**

```dart
class ProductRepositoryImpl extends BaseRepository implements ProductRepository {
  final ApiDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts() async {
    return handleRequest(() async {
      final products = await dataSource.getAllProducts();
      return products.map((model) => model.toEntity()).toList();
    });
  }
  // ... más métodos
}
```

**Características:**
- Extiende `BaseRepository` para reutilizar manejo de errores
- Transforma modelos en entidades
- Convierte excepciones en `Failure`

---

### 3. Capa Core (Core Layer)

**Ubicación:** `lib/src/core/`

Contiene **lógica transversal** que es utilizada por múltiples capas.

#### 3.1 Errores (`core/errors/`)

Define excepciones y fallos del dominio.

**`exceptions.dart`** - Excepciones técnicas:
```dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}
```

**`failures.dart`** - Fallos de negocio:
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
  @override
  List<Object> get props => [message];
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
  @override
  List<Object> get props => [message];
}
```

**Diferencia clave:**
- **Exceptions**: Problemas técnicos que ocurren en la capa de datos
- **Failures**: Representación de errores para la capa de dominio/presentación

#### 3.2 Manejo de Respuestas HTTP (`core/network/`)

**`api_response_handler.dart`** - Implementa el patrón Strategy para manejar códigos HTTP:

```dart
class ApiResponseHandler {
  final Map<int, Function(http.Response)> _strategies = {
    400: (response) => throw ClientException(AppStrings.badRequest),
    401: (response) => throw ClientException(AppStrings.unauthorized),
    404: (response) => throw NotFoundException(AppStrings.notFound),
    500: (response) => throw ServerException(AppStrings.serverError),
  };

  void handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Success
    }

    // Buscar estrategia específica
    if (_strategies.containsKey(response.statusCode)) {
      _strategies[response.statusCode]!(response);
      return;
    }

    // Fallback para rangos de errores
    if (response.statusCode >= 400 && response.statusCode < 500) {
      throw ClientException(AppStrings.clientError);
    }

    if (response.statusCode >= 500) {
      throw ServerException(AppStrings.serverError);
    }
  }
}
```

#### 3.3 Inyección de Dependencias (`di/injection_container.dart`)

Utiliza el patrón **Service Locator** con el paquete `get_it`:

```dart
/// Instancia global del Service Locator.
/// Se usa nombre descriptivo en lugar de abreviaciones como 'sl'.
final GetIt serviceLocator = GetIt.instance;

Future<void> init() async {
  // Use Cases - Factory (nueva instancia cada vez)
  serviceLocator.registerFactory(() => GetAllProductsUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => GetProductByIdUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => GetAllCategoriesUseCase(serviceLocator()));

  // Repository - Lazy Singleton (instancia única, creada cuando se necesita)
  serviceLocator.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(serviceLocator()),
  );

  // DataSource - Lazy Singleton
  serviceLocator.registerLazySingleton<ApiDataSource>(
    () => ApiDataSourceImpl(serviceLocator(), serviceLocator()),
  );

  // Network - Lazy Singleton
  serviceLocator.registerLazySingleton(() => ApiResponseHandler());

  // HTTP Client - Lazy Singleton
  serviceLocator.registerLazySingleton(() => http.Client());
}
```

**Beneficios:**
- Desacoplamiento de dependencias
- Facilita testing (podemos inyectar mocks)
- Control centralizado del ciclo de vida

#### 3.4 Clase Base para Repositorios (`repositories/base/`)

**`base_repository.dart`** - Centraliza el manejo de excepciones:

```dart
class BaseRepository {
  Future<Either<Failure, T>> handleRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final result = await request();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ClientException catch (e) {
      return Left(ClientFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(AppStrings.unexpectedError));
    }
  }
}
```

---

## Patrones de Diseño Implementados

### 1. Repository Pattern

**Problema:** Necesitamos abstraer la fuente de datos para que la lógica de negocio no dependa de detalles de implementación.

**Solución:** Definir una interfaz en la capa de dominio e implementarla en la capa de datos.

**Beneficios:**
- Cambiar de API a base de datos local sin afectar el dominio
- Facilita testing con repositorios mock
- Separación clara de responsabilidades

### 2. Strategy Pattern

**Problema:** Manejar múltiples códigos de estado HTTP de forma escalable.

**Solución:** `ApiResponseHandler` utiliza un mapa de estrategias donde cada código HTTP tiene una función asociada.

**Beneficios:**
- Fácil agregar nuevos códigos de estado
- Código limpio y mantenible
- Sigue el principio Open/Closed

### 3. Service Locator Pattern

**Problema:** Necesitamos gestionar dependencias de forma centralizada.

**Solución:** Usar `get_it` para registrar y resolver dependencias.

**Beneficios:**
- Desacoplamiento de componentes
- Facilita pruebas unitarias
- Control del ciclo de vida de objetos

### 4. Use Case Pattern

**Problema:** Encapsular lógica de negocio específica de forma reutilizable.

**Solución:** Cada caso de uso es una clase que implementa la interfaz `UseCase<Type, Params>`.

**Beneficios:**
- Una responsabilidad por clase (Single Responsibility)
- Fácil de testear
- Reutilizable en diferentes partes de la aplicación

### 5. Singleton Pattern

**Problema:** Necesitamos una única instancia de configuración accesible globalmente.

**Solución:** `EnvConfig` implementa el patrón Singleton con constructor privado e instancia estática.

**Beneficios:**
- Garantiza una única fuente de verdad para la configuración
- Acceso global sin pasar dependencias por constructores
- Inicialización lazy (solo cuando se necesita)
- Estado compartido entre todas las partes de la aplicación

---

## Flujo de Datos

### Ejemplo: Obtener Todos los Productos

```
┌──────────────┐
│     USER     │
│ (CLI Input)  │
└──────┬───────┘
       │
       │ 1. Selecciona opción "1"
       ▼
┌──────────────────────────────────┐
│   PRESENTATION LAYER             │
│   (bin/fase_2_consumo_api.dart)  │
│   _handleGetAllProducts()        │
└──────┬───────────────────────────┘
       │
       │ 2. Llama a executeUseCase()
       ▼
┌──────────────────────────────────┐
│   USE CASE                       │
│   GetAllProductsUseCase          │
│   call(NoParams)                 │
└──────┬───────────────────────────┘
       │
       │ 3. Llama a repository.getAllProducts()
       ▼
┌──────────────────────────────────┐
│   REPOSITORY                     │
│   ProductRepositoryImpl          │
│   getAllProducts()               │
└──────┬───────────────────────────┘
       │
       │ 4. Llama a dataSource.getAllProducts()
       ▼
┌──────────────────────────────────┐
│   DATA SOURCE                    │
│   ApiDataSourceImpl              │
│   getAllProducts()               │
└──────┬───────────────────────────┘
       │
       │ 5. Hace petición HTTP GET /products
       ▼
┌──────────────────────────────────┐
│   EXTERNAL API                   │
│   https://fakestoreapi.com       │
└──────┬───────────────────────────┘
       │
       │ 6. Retorna JSON
       ▼
┌──────────────────────────────────┐
│   DATA SOURCE                    │
│   Convierte JSON a ProductModel  │
└──────┬───────────────────────────┘
       │
       │ 7. Retorna List<ProductModel>
       ▼
┌──────────────────────────────────┐
│   REPOSITORY                     │
│   Convierte a List<ProductEntity>│
│   Retorna Either<Failure, List>  │
└──────┬───────────────────────────┘
       │
       │ 8. Retorna Either al caso de uso
       ▼
┌──────────────────────────────────┐
│   PRESENTATION                   │
│   Fold Either y muestra resultado│
└──────┬───────────────────────────┘
       │
       │ 9. Muestra productos en consola
       ▼
┌──────────────┐
│     USER     │
│  (Visualiza) │
└──────────────┘
```

---

## Manejo de Errores

El proyecto implementa un **manejo robusto de errores** en múltiples niveles:

### 1. Nivel de DataSource (Excepciones)

```dart
// Si hay error de conexión
throw ConnectionException(AppStrings.connectionError);

// Si el servidor retorna 404
throw NotFoundException(AppStrings.notFound);

// Si el servidor retorna 500
throw ServerException(AppStrings.serverError);
```

### 2. Nivel de Repository (Conversión a Failures)

```dart
// BaseRepository.handleRequest() captura excepciones y las convierte
try {
  final result = await request();
  return Right(result); // Éxito
} on ServerException catch (e) {
  return Left(ServerFailure(e.message)); // Error
}
```

### 3. Nivel de Presentación (Mostrar al Usuario)

```dart
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (products) => _displayProducts(products),
);
```

### Ventajas del Tipo Either

El tipo `Either<L, R>` del paquete `dartz` permite:
- **Manejo funcional de errores** (sin try-catch en presentación)
- **Tipo seguro**: El compilador fuerza manejar ambos casos (éxito y error)
- **Código más limpio y expresivo**

---

## Variables de Entorno

El proyecto utiliza el paquete `dotenv` para gestionar la configuración de forma segura, evitando hardcodear URLs y valores sensibles en el código.

### Configuración

**Archivos:**
- `.env.example`: Plantilla con las variables requeridas (versionado)
- `.env`: Configuración real del ambiente (excluido de git)

**Variables disponibles:**

| Variable | Descripción | Requerida | Valor por defecto |
|----------|-------------|-----------|-------------------|
| `API_BASE_URL` | URL base de la API | Sí | - |

### Clase EnvConfig

**Ubicación:** `lib/src/core/config/env_config.dart`

Implementa el patrón **Singleton** para proporcionar acceso global y tipado a las variables de configuración.

```dart
/// Clase de configuración que gestiona las variables de entorno.
class EnvConfig {
  // Singleton instance
  static final EnvConfig _instance = EnvConfig._internal();
  static EnvConfig get instance => _instance;

  // Constructor privado para Singleton
  EnvConfig._internal();

  /// Inicializa la configuración cargando las variables de entorno.
  Future<void> initialize({String envPath = '.env'}) async {
    if (_isInitialized) return;
    _dotEnv = DotEnv(includePlatformEnvironment: true)..load([envPath]);
    _validateRequiredVariables();
    _isInitialized = true;
  }

  // Getters para variables de configuración
  String get apiBaseUrl => _get('API_BASE_URL');
}
```

**Características:**
- Patrón Singleton para instancia única global
- Validación de variables requeridas al inicializar
- Getters tipados para cada variable
- Soporte para valores por defecto
- Lanza `EnvConfigException` si faltan variables requeridas

### Uso en la Aplicación

```dart
// bin/fase_2_consumo_api.dart
void main() async {
  // 1. Cargar variables de entorno PRIMERO
  try {
    await EnvConfig.instance.initialize();
  } on EnvConfigException catch (e) {
    print('Error de configuración: $e');
    exit(1);
  }

  // 2. Inicializar dependencias
  await di.init();

  // ...
}
```

### Beneficios

- **Seguridad**: Las credenciales no se exponen en el código fuente
- **Flexibilidad**: Diferentes configuraciones por ambiente (dev, staging, prod)
- **Mantenibilidad**: Cambios de configuración sin modificar código
- **Testabilidad**: Fácil inyección de configuraciones mock en tests

---

## Inyección de Dependencias

### Configuración Inicial

```dart
// bin/fase_2_consumo_api.dart
void main() async {
  await init(); // Inicializa el contenedor de dependencias
  // ...
}
```

### Uso en la Aplicación

```dart
// Obtener instancia del caso de uso
final getAllProductsUseCase = serviceLocator<GetAllProductsUseCase>();

// Ejecutar caso de uso
final result = await getAllProductsUseCase(NoParams());
```

### Ciclo de Vida de Objetos

| Tipo | Método | Descripción | Uso |
|------|--------|-------------|-----|
| **Factory** | `registerFactory()` | Nueva instancia cada vez | Use Cases |
| **Lazy Singleton** | `registerLazySingleton()` | Instancia única, creada cuando se necesita | Repositories, DataSources |
| **Singleton** | `registerSingleton()` | Instancia única, creada inmediatamente | (No usado en este proyecto) |

---

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                       │
│                         (bin/main.dart)                         │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Show Menu    │  │ Get Input    │  │ Display Data │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└────────────────────────────┬────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│ GetAllProducts│  │GetProductById │  │GetAllCategories│ USE CASES
│   UseCase     │  │   UseCase     │  │   UseCase      │
└───────┬───────┘  └───────┬───────┘  └───────┬────────┘
        │                  │                   │
        └──────────────────┼───────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────────┐
        │      ProductRepository Interface     │  DOMAIN
        │          (Abstract Contract)         │
        └──────────────────┬───────────────────┘
                           │
                           │ implements
                           ▼
        ┌──────────────────────────────────────┐
        │     ProductRepositoryImpl            │  DATA
        │    extends BaseRepository            │
        └──────────────────┬───────────────────┘
                           │
                           │ uses
                           ▼
        ┌──────────────────────────────────────┐
        │        ApiDataSource Interface       │
        │          (Abstract Contract)         │
        └──────────────────┬───────────────────┘
                           │
                           │ implements
                           ▼
        ┌──────────────────────────────────────┐
        │         ApiDataSourceImpl            │
        │      uses ApiResponseHandler         │
        └──────────────────┬───────────────────┘
                           │
                           │ HTTP Requests
                           ▼
        ┌──────────────────────────────────────┐
        │      Fake Store API (External)       │
        │    https://fakestoreapi.com          │
        └──────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          CORE LAYER                             │
│                                                                 │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐        │
│  │  Errors &   │  │   Network    │  │   Dependency   │        │
│  │ Exceptions  │  │   Handler    │  │   Injection    │        │
│  └─────────────┘  └──────────────┘  └────────────────┘        │
│                                                                 │
│  ┌─────────────────────────────────────────────────────┐       │
│  │              EnvConfig (Singleton)                   │       │
│  │         Gestión de Variables de Entorno              │       │
│  └─────────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusión

Esta arquitectura proporciona:

✅ **Separación clara de responsabilidades**
✅ **Código testeable** (cada capa puede probarse independientemente)
✅ **Escalabilidad** (fácil agregar nuevas funcionalidades)
✅ **Mantenibilidad** (cambios localizados en capas específicas)
✅ **Independencia de frameworks** (la lógica de negocio es pura)
✅ **Configuración segura** (variables de entorno externalizadas)

### Próximos Pasos Sugeridos

1. **Implementar Tests Unitarios** para cada capa
2. **Agregar Caché Local** con un segundo DataSource
3. **Implementar Paginación** en la lista de productos
4. **Agregar Logging** para facilitar debugging
5. **Crear Interceptores HTTP** para headers comunes

---

**Documentación generada para el proyecto Fase 2: Consumo de API**
Versión: 1.1.0
Última actualización: 2025-11-27
