# Diagrama de Arquitectura - Fake Store CLI

**Proyecto:** fase_2_consumo_api
**Tipo:** Aplicacion CLI en Dart
**Arquitectura:** Clean Architecture (3 capas)
**API Externa:** https://fakestoreapi.com

---

## Vista Interactiva

Para visualizar los diagramas:
1. Instala la extension **Mermaid Preview** en VS Code
2. O usa [Mermaid Live Editor](https://mermaid.live)

---

## 1. Diagrama de Arquitectura General

```mermaid
%%{init: {
    'theme': 'dark',
    'themeVariables': {
        'background': '#181a20',
        'primaryColor': '#2c3e50',
        'primaryTextColor': '#ffffff',
        'primaryBorderColor': '#3498db',
        'lineColor': '#3498db',
        'edgeLabelBackground':'#2c3e50',
        'nodeTextColor':'#ffffff',
        'fontSize': '16px',
        'fontFamily': 'Arial, sans-serif'
    },
    'flowchart': {
        'nodeSpacing': 80,
        'rankSpacing': 120,
        'curve': 'basis',
        'padding': 20,
        'useMaxWidth': false,
        'htmlLabels': false
    }
}}%%

flowchart TB
    subgraph PRESENTATION["CAPA DE PRESENTACION"]
        direction TB
        UI[ConsoleUserInterface]
        APP[ApplicationController]
        CONTRACTS[UserInterface Contract]
    end

    subgraph DOMAIN["CAPA DE DOMINIO - Dart Puro"]
        direction TB
        UC1[GetAllProductsUseCase]
        UC2[GetProductByIdUseCase]
        UC3[GetAllCategoriesUseCase]
        UC4[GetProductsByCategoryUseCase]
        REPO_INT[ProductRepository Interface]
        ENTITY[ProductEntity]
    end

    subgraph DATA["CAPA DE DATOS"]
        direction TB
        REPO_IMPL[ProductRepositoryImpl]
        BASE_REPO[BaseRepository]
        DS_PROD[ProductRemoteDataSource]
        DS_CAT[CategoryRemoteDataSource]
        MODEL[ProductModel]
        API_CLIENT[ApiClient]
    end

    subgraph CORE["CORE - Transversal"]
        direction TB
        CONFIG[EnvConfig]
        ERRORS[Exceptions & Failures]
        NETWORK[ApiResponseHandler]
        USECASE_BASE[UseCase Base]
    end

    subgraph DI["INYECCION DE DEPENDENCIAS"]
        direction TB
        CONTAINER[InjectionContainer]
        GET_IT[GetItAdapter]
    end

    subgraph EXTERNAL["RECURSOS EXTERNOS"]
        direction TB
        API[Fake Store API]
        ENV[.env Variables]
    end

    %% Conexiones Presentation
    UI --> APP
    APP --> CONTRACTS
    APP --> UC1
    APP --> UC2
    APP --> UC3
    APP --> UC4

    %% Conexiones Domain
    UC1 --> REPO_INT
    UC2 --> REPO_INT
    UC3 --> REPO_INT
    UC4 --> REPO_INT
    REPO_INT --> ENTITY

    %% Conexiones Data
    REPO_IMPL -.->|implements| REPO_INT
    REPO_IMPL --> BASE_REPO
    REPO_IMPL --> DS_PROD
    REPO_IMPL --> DS_CAT
    DS_PROD --> API_CLIENT
    DS_CAT --> API_CLIENT
    DS_PROD --> MODEL
    MODEL --> ENTITY

    %% Conexiones Core
    API_CLIENT --> NETWORK
    API_CLIENT --> CONFIG
    BASE_REPO --> ERRORS
    UC1 -.-> USECASE_BASE
    UC2 -.-> USECASE_BASE
    UC3 -.-> USECASE_BASE
    UC4 -.-> USECASE_BASE

    %% Conexiones DI
    CONTAINER --> GET_IT
    CONTAINER -.->|registra| APP
    CONTAINER -.->|registra| REPO_IMPL
    CONTAINER -.->|registra| DS_PROD
    CONTAINER -.->|registra| DS_CAT

    %% Conexiones Externas
    API_CLIENT -->|HTTPS| API
    CONFIG --> ENV

    %% Estilos
    classDef presentation fill:#34495e,stroke:#3498db,stroke-width:3px,color:#ffffff
    classDef domain fill:#27ae60,stroke:#2ecc71,stroke-width:3px,color:#ffffff
    classDef data fill:#8e44ad,stroke:#9b59b6,stroke-width:3px,color:#ffffff
    classDef core fill:#e67e22,stroke:#f39c12,stroke-width:3px,color:#ffffff
    classDef di fill:#16a085,stroke:#1abc9c,stroke-width:3px,color:#ffffff
    classDef external fill:#f39c12,stroke:#f1c40f,stroke-width:3px,color:#000000

    class UI,APP,CONTRACTS presentation
    class UC1,UC2,UC3,UC4,REPO_INT,ENTITY domain
    class REPO_IMPL,BASE_REPO,DS_PROD,DS_CAT,MODEL,API_CLIENT data
    class CONFIG,ERRORS,NETWORK,USECASE_BASE core
    class CONTAINER,GET_IT di
    class API,ENV external
```

---

## 2. Diagrama de Flujo de Datos

```mermaid
%%{init: {
    'theme': 'dark',
    'themeVariables': {
        'background': '#181a20',
        'primaryColor': '#2c3e50',
        'primaryTextColor': '#ffffff',
        'primaryBorderColor': '#3498db',
        'lineColor': '#3498db'
    }
}}%%

sequenceDiagram
    autonumber
    participant User as Usuario
    participant CLI as ConsoleUserInterface
    participant App as ApplicationController
    participant UC as UseCase
    participant Repo as ProductRepository
    participant DS as DataSource
    participant API as ApiClient
    participant External as Fake Store API

    User->>CLI: Selecciona opcion del menu
    CLI->>App: MenuOption
    App->>UC: call(Params)
    UC->>Repo: getAllProducts()
    Repo->>DS: getAll()
    DS->>API: getList(endpoint, fromJson)
    API->>External: GET /products
    External-->>API: JSON Response
    API-->>DS: List<ProductModel>
    DS-->>Repo: List<ProductModel>
    Repo->>Repo: model.toEntity()
    Repo-->>UC: Either<Failure, List<ProductEntity>>
    UC-->>App: Either<Failure, List<ProductEntity>>
    App->>App: result.fold()
    App->>CLI: showProducts() o showError()
    CLI-->>User: Muestra resultado
```

---

## 3. Diagrama de Clases - Domain Layer

```mermaid
%%{init: {
    'theme': 'dark',
    'themeVariables': {
        'background': '#181a20',
        'primaryColor': '#2c3e50',
        'primaryTextColor': '#ffffff'
    }
}}%%

classDiagram
    direction TB

    class UseCase~Type, Params~ {
        <<abstract>>
        +call(Params params) Future~Either~Failure, Type~~
    }

    class NoParams {
        +props List~Object~
    }

    class GetAllProductsUseCase {
        -repository ProductRepository
        +call(NoParams) Future~Either~Failure, List~ProductEntity~~~
    }

    class GetProductByIdUseCase {
        -repository ProductRepository
        +call(GetProductByIdParams) Future~Either~Failure, ProductEntity~~
    }

    class GetAllCategoriesUseCase {
        -repository ProductRepository
        +call(NoParams) Future~Either~Failure, List~String~~~
    }

    class GetProductsByCategoryUseCase {
        -repository ProductRepository
        +call(CategoryParams) Future~Either~Failure, List~ProductEntity~~~
    }

    class ProductRepository {
        <<interface>>
        +getAllProducts() Future~Either~Failure, List~ProductEntity~~~
        +getProductById(int id) Future~Either~Failure, ProductEntity~~
        +getAllCategories() Future~Either~Failure, List~String~~~
        +getProductsByCategory(String) Future~Either~Failure, List~ProductEntity~~~
    }

    class ProductEntity {
        +int id
        +String title
        +double price
        +String description
        +String category
        +String image
        +props List~Object~
    }

    UseCase <|-- GetAllProductsUseCase
    UseCase <|-- GetProductByIdUseCase
    UseCase <|-- GetAllCategoriesUseCase
    UseCase <|-- GetProductsByCategoryUseCase

    GetAllProductsUseCase --> ProductRepository
    GetProductByIdUseCase --> ProductRepository
    GetAllCategoriesUseCase --> ProductRepository
    GetProductsByCategoryUseCase --> ProductRepository

    ProductRepository --> ProductEntity
```

---

## 4. Diagrama de Clases - Data Layer

```mermaid
%%{init: {
    'theme': 'dark',
    'themeVariables': {
        'background': '#181a20',
        'primaryColor': '#2c3e50',
        'primaryTextColor': '#ffffff'
    }
}}%%

classDiagram
    direction TB

    class ProductRepository {
        <<interface>>
    }

    class BaseRepository {
        <<abstract>>
        #handleRequest~T~(action, notFoundMessage) Future~Either~Failure, T~~
    }

    class ProductRepositoryImpl {
        -_productDataSource ProductRemoteDataSource
        -_categoryDataSource CategoryRemoteDataSource
        +getAllProducts()
        +getProductById(int id)
        +getAllCategories()
        +getProductsByCategory(String)
    }

    class ProductRemoteDataSource {
        <<interface>>
        +getAll() Future~List~ProductModel~~
        +getById(int id) Future~ProductModel~
        +getByCategory(String) Future~List~ProductModel~~
    }

    class CategoryRemoteDataSource {
        <<interface>>
        +getAll() Future~List~String~~
    }

    class ApiClient {
        <<interface>>
        +get~T~(endpoint, fromJson) Future~T~
        +getList~T~(endpoint, fromJsonList) Future~List~T~~
        +getPrimitiveList~T~(endpoint) Future~List~T~~
    }

    class ApiClientImpl {
        -_client http.Client
        -_responseHandler ApiResponseHandler
        -_config EnvConfig
    }

    class ProductModel {
        +int id
        +String title
        +double price
        +String description
        +String category
        +String image
        +fromJson(Map) ProductModel
        +toEntity() ProductEntity
    }

    BaseRepository <|-- ProductRepositoryImpl
    ProductRepository <|.. ProductRepositoryImpl
    ProductRepositoryImpl --> ProductRemoteDataSource
    ProductRepositoryImpl --> CategoryRemoteDataSource
    ProductRemoteDataSource --> ApiClient
    CategoryRemoteDataSource --> ApiClient
    ApiClient <|.. ApiClientImpl
    ProductRemoteDataSource --> ProductModel
```

---

## 5. Diagrama de Errores y Failures

```mermaid
%%{init: {
    'theme': 'dark',
    'themeVariables': {
        'background': '#181a20',
        'primaryColor': '#2c3e50',
        'primaryTextColor': '#ffffff'
    }
}}%%

flowchart LR
    subgraph EXCEPTIONS["Excepciones - Data Layer"]
        AE[AppException]
        SE[ServerException]
        NE[NotFoundException]
        CE[ClientException]
        COE[ConnectionException]
    end

    subgraph FAILURES["Failures - Domain Layer"]
        F[Failure]
        SF[ServerFailure]
        NF[NotFoundFailure]
        CF[ClientFailure]
        COF[ConnectionFailure]
    end

    subgraph HANDLER["BaseRepository.handleRequest"]
        TRY[try/catch]
    end

    AE --> SE
    AE --> NE
    AE --> CE
    AE --> COE

    F --> SF
    F --> NF
    F --> CF
    F --> COF

    SE -->|catch| TRY
    NE -->|catch| TRY
    CE -->|catch| TRY
    COE -->|catch| TRY

    TRY -->|Left| SF
    TRY -->|Left| NF
    TRY -->|Left| CF
    TRY -->|Left| COF

    classDef exception fill:#c0392b,stroke:#e74c3c,stroke-width:2px,color:#ffffff
    classDef failure fill:#8e44ad,stroke:#9b59b6,stroke-width:2px,color:#ffffff
    classDef handler fill:#27ae60,stroke:#2ecc71,stroke-width:2px,color:#ffffff

    class AE,SE,NE,CE,COE exception
    class F,SF,NF,CF,COF failure
    class TRY handler
```

---

## 6. Diagrama de Inyeccion de Dependencias

```mermaid
%%{init: {
    'theme': 'dark',
    'themeVariables': {
        'background': '#181a20',
        'primaryColor': '#2c3e50',
        'primaryTextColor': '#ffffff'
    }
}}%%

flowchart TB
    subgraph ENTRY["Entry Point"]
        MAIN[main.dart]
    end

    subgraph DI["Dependency Injection"]
        IC[InjectionContainer]
        GIA[GetItAdapter]
        SLC[ServiceLocatorContract]
    end

    subgraph REGISTRATIONS["Registros"]
        direction TB
        R1[EnvConfig - Singleton]
        R2[http.Client - Singleton]
        R3[ApiResponseHandler - Singleton]
        R4[ApiClient - Singleton]
        R5[ProductRemoteDataSource - Singleton]
        R6[CategoryRemoteDataSource - Singleton]
        R7[ProductRepository - Singleton]
        R8[UseCases - Factory]
        R9[ApplicationController - Factory]
        R10[UserInterface - Singleton]
    end

    MAIN -->|1. EnvConfig.initialize| R1
    MAIN -->|2. di.init| IC
    IC --> GIA
    GIA -.->|implements| SLC

    IC --> R1
    IC --> R2
    IC --> R3
    R3 --> R4
    R4 --> R5
    R4 --> R6
    R5 --> R7
    R6 --> R7
    R7 --> R8
    R8 --> R9
    R10 --> R9

    IC -->|returns| R9

    classDef entry fill:#e74c3c,stroke:#c0392b,stroke-width:2px,color:#ffffff
    classDef di fill:#3498db,stroke:#2980b9,stroke-width:2px,color:#ffffff
    classDef singleton fill:#27ae60,stroke:#229954,stroke-width:2px,color:#ffffff
    classDef factory fill:#f39c12,stroke:#d68910,stroke-width:2px,color:#ffffff

    class MAIN entry
    class IC,GIA,SLC di
    class R1,R2,R3,R4,R5,R6,R7,R10 singleton
    class R8,R9 factory
```

---

## 7. Estructura de Directorios

```
lib/src/
|-- core/                          # Transversal
|   |-- config/                    # EnvConfig, DotenvReader
|   |-- constants/                 # ApiEndpoints
|   |-- errors/                    # Exceptions & Failures
|   |-- network/                   # ApiResponseHandler
|   |-- usecase/                   # UseCase base, NoParams
|
|-- data/                          # Capa de Datos
|   |-- datasources/
|   |   |-- core/                  # ApiClient
|   |   |-- product/               # ProductRemoteDataSource
|   |   |-- category/              # CategoryRemoteDataSource
|   |-- models/                    # ProductModel
|   |-- repositories/              # ProductRepositoryImpl
|
|-- domain/                        # Capa de Dominio (Dart Puro)
|   |-- entities/                  # ProductEntity
|   |-- repositories/              # ProductRepository (interface)
|   |-- usecases/                  # 4 UseCases
|
|-- presentation/                  # Capa de Presentacion
|   |-- adapters/                  # ConsoleUserInterface
|   |-- contracts/                 # UserInterface, MenuOption
|   |-- application.dart           # ApplicationController
|
|-- di/                            # Inyeccion de Dependencias
|   |-- adapters/                  # GetItAdapter
|   |-- contracts/                 # ServiceLocatorContract
|   |-- injection_container.dart
|
|-- util/                          # Utilidades
    |-- strings.dart               # AppStrings
```

---

## 8. Endpoints de la API

```mermaid
%%{init: {
    'theme': 'dark',
    'themeVariables': {
        'background': '#181a20',
        'primaryColor': '#2c3e50',
        'primaryTextColor': '#ffffff'
    }
}}%%

flowchart LR
    subgraph API["Fake Store API - fakestoreapi.com"]
        E1["GET /products"]
        E2["GET /products/{id}"]
        E3["GET /products/categories"]
        E4["GET /products/category/{name}"]
    end

    subgraph USECASES["Use Cases"]
        UC1[GetAllProductsUseCase]
        UC2[GetProductByIdUseCase]
        UC3[GetAllCategoriesUseCase]
        UC4[GetProductsByCategoryUseCase]
    end

    UC1 --> E1
    UC2 --> E2
    UC3 --> E3
    UC4 --> E4

    classDef api fill:#3498db,stroke:#2980b9,stroke-width:2px,color:#ffffff
    classDef uc fill:#27ae60,stroke:#229954,stroke-width:2px,color:#ffffff

    class E1,E2,E3,E4 api
    class UC1,UC2,UC3,UC4 uc
```

---

## Caracteristicas Clave del Sistema

| Caracteristica | Implementacion |
|----------------|----------------|
| **Arquitectura** | Clean Architecture (3 capas) |
| **Patron de Errores** | Either<Failure, T> con dartz |
| **Inyeccion de Dependencias** | get_it con abstraccion |
| **Seguridad** | Variables de entorno en .env |
| **Testing** | 170 tests con patron AAA |
| **Documentacion** | Doc comments con /// |
| **Principios** | SOLID, DRY, YAGNI |

---

## Flujo de Datos Resumido

1. **Usuario** selecciona opcion en CLI
2. **ApplicationController** invoca el UseCase correspondiente
3. **UseCase** llama al Repository (interface)
4. **Repository** delega a DataSource
5. **DataSource** usa ApiClient para HTTP
6. **ApiClient** comunica con Fake Store API
7. **Respuesta** fluye de regreso transformando Model -> Entity
8. **Either** maneja exito (Right) o error (Left)
9. **UI** muestra resultado al usuario

---

*Generado automaticamente por el generador de diagramas Mermaid*
*Fuente: arquitectura-all-diagram-mermaid.md*
