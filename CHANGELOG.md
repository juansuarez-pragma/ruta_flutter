# Changelog

Historial de cambios del proyecto. Sin releases formales aún.

## Unreleased

### Funcionalidades
- CLI interactiva con 4 endpoints de Fake Store API
- Clean Architecture (Domain/Data/Presentation)
- Manejo de errores con `Either<Failure, T>` (dartz)
- Soporte Docker (imagen: `juancarlos05/fake-store-cli`)
- CI/CD con GitHub Actions
- Suite de tests (164+ tests, 87% cobertura)

### Endpoints
- `GET /products` - Listar productos
- `GET /products/{id}` - Producto por ID
- `GET /products/categories` - Listar categorías
- `GET /products/category/{category}` - Productos por categoría
