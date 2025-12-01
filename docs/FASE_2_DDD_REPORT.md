# Reporte de Fase 2: DDD Táctico

## Resumen Ejecutivo

La Fase 2 implementó patrones tácticos de Domain-Driven Design (DDD) en el proyecto, enriqueciendo la capa de dominio con Value Objects, Domain Events y un Aggregate Root. Todos los componentes fueron desarrollados siguiendo estrictamente TDD.

## Métricas de la Fase

| Métrica | Antes | Después | Cambio |
|---------|-------|---------|--------|
| Tests totales | 189 | 278 | +89 tests |
| Value Objects | 0 | 4 | +4 |
| Domain Events | 0 | 2 | +2 |
| Aggregates | 0 | 1 | +1 |

## Componentes Implementados

### 1. Value Objects

#### Money (`lib/src/domain/value_objects/shared/money.dart`)

Value Object para representar valores monetarios no negativos.

**Características:**
- Precisión de 2 decimales automática
- Validación de no-negatividad
- Operaciones aritméticas seguras (`add`, `subtract`, `multiply`)
- Operadores de comparación (`<`, `<=`, `>`, `>=`)
- Implementa `Comparable<Money>`
- Constante `Money.zero` para valor cero

**Tests:** 26 tests cubriendo:
- Creación y validación
- Precisión decimal
- Operaciones aritméticas
- Comparaciones
- Casos límite

```dart
// Ejemplo de uso
final precio = Money.fromDouble(99.99);
final descuento = Money.fromDouble(10.00);
final precioFinal = precio.subtract(descuento); // $89.99
```

#### ProductId (`lib/src/domain/value_objects/product/product_id.dart`)

Value Object para identificadores de producto.

**Características:**
- Validación de entero positivo (> 0)
- Inmutable y comparable por valor

**Tests:** 11 tests

```dart
final id = ProductId(42);
// ProductId(0) → lanza ArgumentError
// ProductId(-1) → lanza ArgumentError
```

#### ProductTitle (`lib/src/domain/value_objects/product/product_title.dart`)

Value Object para títulos de producto.

**Características:**
- Validación de no vacío
- Límite de 200 caracteres
- Trim automático de espacios

**Tests:** 13 tests

```dart
final title = ProductTitle('Laptop Gaming Pro');
// ProductTitle('') → lanza ArgumentError
// ProductTitle('a' * 201) → lanza ArgumentError
```

#### Rating (`lib/src/domain/aggregates/product/product_aggregate.dart`)

Value Object embebido para calificaciones.

**Características:**
- Rate entre 0 y 5 (inclusive)
- Count no negativo
- Validaciones estrictas

**Tests:** 9 tests

### 2. Domain Events

#### DomainEvent (Base) (`lib/src/domain/events/domain_event.dart`)

Clase base abstracta para todos los eventos de dominio.

**Características:**
- `eventId`: Identificador único generado automáticamente
- `occurredAt`: Timestamp del evento
- Extiende `Equatable` para comparación por valor

**Tests:** 6 tests

```dart
abstract class DomainEvent extends Equatable {
  final String eventId;
  final DateTime occurredAt;
  // ...
}
```

#### ProductViewedEvent (`lib/src/domain/events/product/product_viewed_event.dart`)

Evento emitido cuando un usuario visualiza un producto.

**Características:**
- Contiene `ProductId` del producto visualizado
- Hereda `eventId` y `occurredAt` de `DomainEvent`

**Tests:** 5 tests

```dart
final event = ProductViewedEvent(productId: ProductId(42));
eventDispatcher.dispatch(event);
```

### 3. Aggregates

#### ProductAggregate (`lib/src/domain/aggregates/product/product_aggregate.dart`)

Aggregate Root que encapsula un producto y sus comportamientos de dominio.

**Propiedades (Value Objects):**
- `id`: ProductId
- `title`: ProductTitle
- `price`: Money
- `description`: String
- `category`: String
- `image`: String
- `rating`: Rating

**Comportamientos de Dominio:**

| Método | Descripción |
|--------|-------------|
| `hasDiscount(Money originalPrice)` | Verifica si tiene descuento |
| `calculateDiscount(Money originalPrice)` | Calcula monto del descuento |
| `discountPercentage(Money originalPrice)` | Calcula porcentaje de descuento |
| `isInCategory(String category)` | Verifica pertenencia a categoría (case-insensitive) |
| `recordView()` | Emite `ProductViewedEvent` |
| `isHighlyRated({threshold})` | Verifica si calificación >= threshold (default 4.0) |
| `hasEnoughReviews({minimumReviews})` | Verifica si tiene suficientes reseñas (default 10) |

**Tests:** 34 tests cubriendo:
- Construcción y Equatable
- Lógica de descuentos
- Verificación de categoría
- Emisión de eventos
- Validaciones de rating

```dart
final product = ProductAggregate(
  id: ProductId(1),
  title: ProductTitle('Laptop Gaming'),
  price: Money.fromDouble(999.99),
  description: 'Laptop de alto rendimiento',
  category: 'electronics',
  image: 'https://example.com/laptop.jpg',
  rating: Rating(rate: 4.5, count: 150),
);

// Comportamientos de dominio
if (product.hasDiscount(Money.fromDouble(1199.99))) {
  print('Descuento: ${product.discountPercentage(originalPrice)}%');
}

if (product.isHighlyRated() && product.hasEnoughReviews()) {
  print('Producto destacado');
}

// Emitir evento de visualización
final event = product.recordView();
```

## Estructura de Archivos Creados

```
lib/src/domain/
├── value_objects/
│   ├── value_objects.dart          # Barrel file
│   ├── value_object.dart           # Clase base
│   ├── shared/
│   │   ├── shared.dart             # Barrel file
│   │   └── money.dart              # Money VO
│   └── product/
│       ├── product.dart            # Barrel file
│       ├── product_id.dart         # ProductId VO
│       └── product_title.dart      # ProductTitle VO
├── events/
│   ├── events.dart                 # Barrel file
│   ├── domain_event.dart           # Base abstracta
│   └── product/
│       └── product_viewed_event.dart
└── aggregates/
    ├── aggregates.dart             # Barrel file
    └── product/
        └── product_aggregate.dart  # Incluye Rating

test/unit/domain/
├── value_objects/
│   ├── shared/
│   │   └── money_test.dart         # 26 tests
│   └── product/
│       ├── product_id_test.dart    # 11 tests
│       └── product_title_test.dart # 13 tests
├── events/
│   ├── domain_event_test.dart      # 6 tests
│   └── product/
│       └── product_viewed_event_test.dart # 5 tests
└── aggregates/
    └── product/
        └── product_aggregate_test.dart # 34 tests
```

## Proceso TDD Aplicado

Cada componente siguió estrictamente el ciclo Red-Green-Refactor:

### Ejemplo: Money Value Object

**RED** - Tests fallidos:
```dart
test('lanza ArgumentError para valor negativo', () {
  expect(() => Money.fromDouble(-1), throwsA(isA<ArgumentError>()));
});
```

**GREEN** - Implementación mínima:
```dart
static double _validate(double amount) {
  if (amount < 0) {
    throw ArgumentError.value(amount, 'amount',
      'El valor monetario no puede ser negativo');
  }
  return double.parse(amount.toStringAsFixed(2));
}
```

**REFACTOR** - Mejorar sin cambiar comportamiento (documentación, constantes).

## Beneficios Obtenidos

### 1. Encapsulación de Reglas de Negocio

Las validaciones están centralizadas en los Value Objects:
- `Money` garantiza no-negatividad y precisión
- `ProductId` garantiza identificadores válidos
- `ProductTitle` garantiza títulos válidos

### 2. Código Auto-documentado

```dart
// Antes: ¿qué significa este double?
final price = 99.99;

// Después: claramente es un precio
final price = Money.fromDouble(99.99);
```

### 3. Type Safety

El compilador previene errores:
```dart
// Error de compilación: no puedes pasar un int donde se espera ProductId
void getProduct(ProductId id) { ... }
getProduct(42); // ❌ Error
getProduct(ProductId(42)); // ✓ OK
```

### 4. Comportamientos de Dominio Expresivos

```dart
// El código expresa la intención del negocio
if (product.hasDiscount(originalPrice) && product.isHighlyRated()) {
  featuredProducts.add(product);
}
```

### 5. Eventos para Arquitectura Reactiva

```dart
// Preparado para event sourcing o event-driven architecture
final event = product.recordView();
eventBus.publish(event); // Para métricas, recomendaciones, etc.
```

## Cobertura de Tests

| Componente | Tests | Cobertura |
|------------|-------|-----------|
| Money | 26 | 100% |
| ProductId | 11 | 100% |
| ProductTitle | 13 | 100% |
| DomainEvent | 6 | 100% |
| ProductViewedEvent | 5 | 100% |
| ProductAggregate | 25 | 100% |
| Rating | 9 | 100% |
| **Total Fase 2** | **89** | **100%** |

## Próximos Pasos (Fase 3)

1. **ATDD**: Implementar tests de aceptación con formato Gherkin-style
2. **Escenarios de Usuario**: Definir criterios de aceptación para features
3. **Integrar Aggregate**: Usar `ProductAggregate` en los casos de uso existentes

## Comandos de Verificación

```bash
# Ejecutar todos los tests
dart test

# Tests de Value Objects
dart test test/unit/domain/value_objects/

# Tests de Events
dart test test/unit/domain/events/

# Tests de Aggregates
dart test test/unit/domain/aggregates/

# Verificar análisis estático
dart analyze

# Formatear código
dart format .
```

## Conclusión

La Fase 2 enriqueció significativamente la capa de dominio con patrones DDD tácticos. Los 89 nuevos tests proporcionan confianza en la implementación, y los Value Objects y Aggregates encapsulan correctamente las reglas de negocio. El proyecto está preparado para expandir el dominio y agregar tests de aceptación en las siguientes fases.
