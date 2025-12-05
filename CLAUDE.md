# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## IMPORTANTE: Sistema de Orquestación Automática df*

Este proyecto utiliza un **sistema de agentes orquestado especializados en Dart/Flutter**. Para CUALQUIER tarea que no sea una pregunta simple, DEBES:

1. **Usar el agente `dforchestrator`** para clasificar la solicitud y decidir qué recursos usar
2. El orquestador decidirá si usar MCPs directamente, agentes especializados df*, o combinación

### Invocación del Orquestador

```
Para tareas de desarrollo, SIEMPRE invocar:
Task tool -> subagent_type: "dforchestrator" -> prompt: "[solicitud del usuario]"
```

### Cuándo Usar el Orquestador

| Tipo de Solicitud | Usar Orquestador |
|-------------------|------------------|
| "implementa", "crea", "diseña" | SÍ - Pipeline completo df* |
| "revisa", "audita", "valida" | SÍ - Selecciona agente(s) df* |
| "ejecuta tests", "analiza" | SÍ - Decide MCP vs Agente |
| "complejidad", "métricas", "calidad" | SÍ - DFCODEQUALITY |
| "qué es X", "explica" | NO - Respuesta directa |

### Invocación Directa de Agentes (Bypass)

Si el usuario solicita explícitamente un agente:
- "usa el agente DFSECURITY" → Invocar DFSECURITY directamente
- "con DFCODEQUALITY analiza" → Invocar DFCODEQUALITY directamente

---

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

## Sistema de Agentes df* (Dart/Flutter Specialized)

Este proyecto utiliza un **orquestador híbrido central** que coordina **11 agentes especializados en Dart/Flutter** (prefijo `df`) y **MCPs (Model Context Protocol)** para desarrollo con calidad y seguridad garantizadas. El sistema cubre el **90% de los problemas reportados por la industria** en código generado por IA.

### Arquitectura Híbrida (Agentes df* + MCP)

```
                         ┌─────────────────────────────────────┐
                         │         DFORCHESTRATOR              │
                         │   (Punto de entrada automático)     │
                         └──────────────┬──────────────────────┘
                                        │
              ┌─────────────────────────┼─────────────────────────┐
              │                         │                         │
              ▼                         ▼                         ▼
       ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
       │  MCP DIRECTO │         │   HÍBRIDO    │         │   PIPELINE   │
       │ (operacional)│         │ (MCP+Agente) │         │  (completo)  │
       └──────────────┘         └──────────────┘         └──────────────┘
              │                         │                         │
              ▼                         ▼                         ▼
       dart analyze              run_tests →              DFPLANNER → DFSOLID
       dart test                 DFIMPLEMENTER →          → DFSECURITY ↔ DFDEP
       pub search                run_tests                → DFIMPLEMENTER
       format, etc.              (si fallan)              → [DFQUALITY] → DFVER
```

### Flujo de Desarrollo con Orquestador

```
USUARIO ──► DFORCHESTRATOR ──┬── MCP directo (tareas operacionales)
                             │
                             ├── Agente único df* (tareas especializadas)
                             │
                             ├── Híbrido (MCP + Agente df*)
                             │
                             └── Pipeline completo df* (features complejas)
                                     │
                                     ▼
                             DFPLANNER → DFSOLID → DFSECURITY ↔ DFDEPENDENCIES
                                     → DFIMPLEMENTER → [DFQUALITY AGENTS]
                                     → DFTEST → DFVERIFIER
```

### Agentes df* Disponibles

| Agente | Rol | Función |
|--------|-----|---------|
| **dforchestrator** | Orquestador Central | Clasifica intent, decide MCP vs agente df*, coordina ejecución, Reflection Loop |
| **dfplanner** | Arquitecto Investigador Flutter/Dart | Investiga codebase, patrones Flutter (BLoC/Riverpod/Provider), diseña planes |
| **dfsolid** | Guardian de Calidad Flutter/Dart | Valida SOLID, YAGNI, DRY, detecta anti-patterns Flutter |
| **dfsecurity** | Guardian de Seguridad Flutter/Dart | OWASP Mobile Top 10, Platform Channels, WebView, Deep Linking |
| **dfdependencies** | Guardian de Dependencias Flutter/Dart | Previene slopsquatting, valida pub.dev, plugins Flutter, SDK constraints |
| **dfimplementer** | Desarrollador TDD Flutter/Dart | TDD (Red-Green-Refactor), BLoC/Riverpod/Provider, guardrails anti-alucinación |
| **dfdocumentation** | Especialista en Docs | Effective Dart docs, dartdoc, README, pubspec.yaml |
| **dfcodequality** | Analista de Calidad | Complejidad ciclomática/cognitiva, Effective Dart, DCM |
| **dfperformance** | Auditor de Performance | 60fps/16ms frame budget, widget rebuilds, memory leaks, isolates |
| **dftest** | Especialista QA | Unit, widget, integration, E2E, golden tests, testing pyramid |
| **dfverifier** | Auditor de Completitud | Verificación plan, pubspec.yaml, assets, platform configs, builds |

### MCPs Integrados

| MCP Server | Herramientas | Uso |
|------------|--------------|-----|
| **mcp__dart__** | analyze_files, run_tests, dart_format, dart_fix, pub, pub_dev_search | Operaciones Dart/Flutter |
| **mcp__pragma__** | listPragmaResources, getPragmaResources | Recursos Pragma |
| **mcp__ide__** | getDiagnostics | Diagnósticos del IDE |

### Clasificación de Intent del Orquestador

| Intent | Cuándo | Recurso |
|--------|--------|---------|
| `MCP_ONLY` | Operaciones sin razonamiento | MCP directo |
| `AGENT_SINGLE` | Tarea especializada | Agente específico |
| `HYBRID` | Ejecutar + analizar/arreglar | MCP + Agente |
| `PIPELINE` | Feature compleja | Pipeline completo |
| `QUICK_ANSWER` | Pregunta informativa | Respuesta directa |

### Cobertura de Problemas de la Industria

| Categoría | Cobertura | Agentes Responsables |
|-----------|-----------|---------------------|
| Seguridad (OWASP Mobile Top 10) | 100% | DFSECURITY |
| Supply Chain / Slopsquatting | 100% | DFDEPENDENCIES |
| Alucinaciones de código | 88% | DFIMPLEMENTER, DFDEPENDENCIES |
| Calidad / Sobre-ingeniería | 85% | DFSOLID, DFCODEQUALITY |
| Testing | 67% | DFTEST, DFVERIFIER |
| Arquitectura Flutter | 85% | DFPLANNER, DFSOLID |
| Performance Flutter (60fps) | 100% | DFPERFORMANCE |
| Memory Management | 100% | DFPERFORMANCE, DFCODEQUALITY |
| Widget Rebuilds & Optimization | 100% | DFPERFORMANCE |
| Code Quality Metrics (DCM) | 100% | DFCODEQUALITY |
| Documentation (Effective Dart) | 100% | DFDOCUMENTATION |

### Activación de Agentes

El **DFORCHESTRATOR** se activa automáticamente y decide qué recursos usar:

| Trigger | Decisión del Orquestador |
|---------|--------------------------|
| "ejecuta tests", "dart analyze", "formatea" | MCP directo (sin agente) |
| "busca paquete", "lista devices" | MCP directo (sin agente) |
| "implementa", "crea feature", "diseña" | PIPELINE: DFPLANNER → ... → DFVERIFIER |
| "valida", "revisa diseño", "code review" | AGENT: DFSOLID |
| "audita seguridad", "OWASP", "vulnerabilidades" | AGENT: DFSECURITY |
| "verifica paquetes", "dependencias", "plugins" | AGENT: DFDEPENDENCIES |
| "escribe código", "TDD", "implementa paso" | HYBRID: DFIMPLEMENTER + mcp__dart__run_tests |
| "documentación", "doc comments", "dartdoc" | AGENT: DFDOCUMENTATION |
| "calidad", "complejidad", "métricas" | AGENT: DFCODEQUALITY |
| "performance", "60fps", "rebuilds", "memory" | AGENT: DFPERFORMANCE |
| "tests", "cobertura", "QA", "widget test" | AGENT: DFTEST |
| "verifica", "está completo", "audita" | AGENT: DFVERIFIER |
| "qué es", "cómo funciona", "explica" | Respuesta directa (sin recursos) |

### Principios del Sistema df*

- **Investigación primero**: DFPLANNER siempre investiga patterns Flutter antes de proponer
- **Seguridad móvil**: DFSECURITY valida OWASP Mobile Top 10, Platform Channels, WebView
- **Anti-slopsquatting**: DFDEPENDENCIES verifica paquetes en pub.dev, plugins Flutter
- **TDD estricto**: DFIMPLEMENTER nunca escribe código sin test que falle (BLoC/Riverpod/Provider)
- **Documentación Effective Dart**: DFDOCUMENTATION audita doc comments y dartdoc
- **Métricas de calidad**: DFCODEQUALITY valida complejidad con DCM (450+ rules)
- **Performance 60fps**: DFPERFORMANCE audita frame budget 16ms, rebuilds y memory leaks
- **Guardrails múltiples**: Validación en cada fase del pipeline df*
- **Verificación Flutter**: DFVERIFIER valida pubspec.yaml, assets, platform configs, builds
- **Anti-alucinación**: Guardrails verifican APIs y paquetes antes de usar
- **Reflection Loop**: DFORCHESTRATOR incluye auto-evaluación (+30% completion rate)

### Ubicación

```
.claude/agents/
├── dforchestrator.md      # Orquestador central df* (Reflection Loop, Checkpoints)
├── dfplanner.md           # Arquitecto investigador Flutter/Dart
├── dfsolid.md             # Validador SOLID + anti-patterns Flutter
├── dfsecurity.md          # Guardian seguridad (OWASP Mobile Top 10)
├── dfdependencies.md      # Guardian dependencias (pub.dev, plugins Flutter)
├── dfimplementer.md       # Desarrollador TDD (BLoC/Riverpod/Provider)
├── dfdocumentation.md     # Especialista Effective Dart docs
├── dfcodequality.md       # Analista calidad (DCM, complejidad)
├── dfperformance.md       # Auditor performance (60fps, 16ms frame budget)
├── dftest.md              # Especialista QA (unit, widget, integration, golden)
└── dfverifier.md          # Auditor completitud (pubspec, assets, builds)
```

### Beneficios del Orquestador Híbrido df*

| Beneficio | Descripción |
|-----------|-------------|
| **Especialización Flutter/Dart** | Todos los agentes df* conocen patrones, anti-patterns y best practices Flutter |
| **Eficiencia de tokens** | MCPs directos evitan overhead de agentes para tareas simples |
| **Mejor latencia** | Operaciones simples no pasan por razonamiento de agente |
| **Contexto compartido** | MCP como capa de contexto entre agentes df* |
| **Reflection Loop** | Auto-evaluación del orquestador (+30% completion rate) |
| **Checkpoints** | Recuperación ante fallos con estado guardado |
| **Human Escalation** | 4 niveles de escalamiento (INFO, CONSULTA, ALERTA, BLOQUEO) |
| **Especialización ~83%** | Mejora del +24% vs sistema genérico anterior |
