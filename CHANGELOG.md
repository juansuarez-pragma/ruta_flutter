# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [1.2.0] - 2024

### Added
- Soporte para Docker con multi-stage build
- Imagen publicada en Docker Hub (`juancarlos05/fake-store-cli`)
- Documentación completa de Docker en CLAUDE.md

### Changed
- README simplificado priorizando Docker como opción principal de ejecución

## [1.1.0] - 2024

### Added
- Pipeline CI/CD con GitHub Actions (lint, unit-test, acceptance-test)
- Tests de aceptación ATDD con formato BDD (Given-When-Then)
- Endpoint `GET /products/category/{category}` para filtrar productos
- `GetProductsByCategoryUseCase` integrado en la aplicación
- Opción 4 en menú: "Obtener productos por categoría"
- Suite completa de tests unitarios e integración (164+ tests)
- Cobertura de código del 87%

### Changed
- `Application` renombrado a `ApplicationController`
- Estructura de tests reorganizada (`test/unit/`, `test/acceptance/`)
- CI restringido solo a rama `main`

### Removed
- Código DDD no utilizado (Value Objects, Aggregates, Domain Events)

## [1.0.0] - 2024

### Added
- Arquitectura Clean Architecture de tres capas (Domain, Data, Presentation)
- Patrón Ports & Adapters para capa de presentación
- Consumo de Fake Store API con 4 endpoints:
  - `GET /products` - Listar todos los productos
  - `GET /products/{id}` - Obtener producto por ID
  - `GET /products/categories` - Listar categorías
  - `GET /products/category/{category}` - Productos por categoría
- Manejo funcional de errores con `Either<Failure, T>` (dartz)
- Inyección de dependencias con `get_it`
- Configuración mediante variables de entorno (.env)
- Interfaz CLI interactiva
- Parseo manual de JSON (sin generación de código)
- Documentación técnica completa en CLAUDE.md
