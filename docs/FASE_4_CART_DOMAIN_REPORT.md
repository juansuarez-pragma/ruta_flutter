# Reporte de Fase 4: Expansión del Dominio - Cart Aggregate

## Resumen Ejecutivo

La Fase 4 expandió el dominio del sistema implementando el aggregate CartAggregate para gestión del carrito de compras, siguiendo los principios de DDD y TDD establecidos en fases anteriores.

## Métricas de la Fase

| Métrica | Antes | Después | Cambio |
|---------|-------|---------|--------|
| Tests totales | 311 | 372 | +61 tests |
| Value Objects | 4 | 5 | +1 (CartItem) |
| Aggregates | 1 | 2 | +1 (CartAggregate) |
| Domain Events | 1 | 5 | +4 (Cart events) |
| Tests de aceptación | 33 | 50 | +17 |

## Nuevos Componentes

### CartItem Value Object

```
lib/src/domain/value_objects/cart/cart_item.dart
```

Value Object que encapsula un ítem del carrito:

**Propiedades:**
- `productId`: Referencia al producto (ProductId)
- `quantity`: Cantidad seleccionada (≥1)
- `unitPrice`: Precio unitario al momento de agregar (Money)

**Comportamientos:**
- `subtotal`: Calcula cantidad × precio unitario
- `withQuantity()`: Crea copia con nueva cantidad
- `incrementQuantity()`: Incrementa cantidad
- `decrementQuantity()`: Decrementa cantidad (≥1)
- `isSameProduct()`: Compara por ProductId

**Validaciones:**
- Cantidad debe ser ≥1
- Precio validado por Money (≥0)

### CartAggregate (Aggregate Root)

```
lib/src/domain/aggregates/cart/cart_aggregate.dart
```

Aggregate Root para gestión del carrito de compras:

**Invariantes:**
- Un producto solo aparece una vez
- Cantidad mínima de 1 por ítem
- Total nunca negativo

**Operaciones:**
| Método | Descripción | Evento |
|--------|-------------|--------|
| `addItem()` | Agrega producto o incrementa cantidad | `ItemAddedToCartEvent` |
| `updateQuantity()` | Actualiza cantidad de ítem | `CartItemQuantityUpdatedEvent` |
| `removeItem()` | Elimina ítem del carrito | `ItemRemovedFromCartEvent` |
| `clear()` | Vacía el carrito | `CartClearedEvent` |

**Consultas:**
- `items`: Lista inmutable de ítems
- `isEmpty` / `isNotEmpty`: Estado del carrito
- `itemCount`: Total de unidades
- `uniqueItemCount`: Productos diferentes
- `total`: Suma de subtotales
- `containsProduct()`: Verifica si existe producto
- `getItem()`: Obtiene ítem por ProductId

### Domain Events del Carrito

```
lib/src/domain/events/cart/cart_events.dart
```

| Evento | Propiedades | Descripción |
|--------|-------------|-------------|
| `ItemAddedToCartEvent` | productId, quantity, unitPrice | Producto agregado |
| `CartItemQuantityUpdatedEvent` | productId, oldQuantity, newQuantity | Cantidad actualizada |
| `ItemRemovedFromCartEvent` | productId | Producto eliminado |
| `CartClearedEvent` | itemsCleared, totalCleared | Carrito vaciado |

## Estructura de Tests

```
test/
├── unit/domain/
│   ├── value_objects/cart/
│   │   └── cart_item_test.dart           # 21 tests
│   └── aggregates/cart/
│       └── cart_aggregate_test.dart      # 23 tests
└── acceptance/features/
    └── cart_acceptance_test.dart         # 17 tests
```

### Tests Unitarios: CartItem (21 tests)

| Grupo | Tests |
|-------|-------|
| Creación | 3 |
| Validaciones | 2 |
| Cálculo de subtotal | 3 |
| Actualización de cantidad | 2 |
| Incremento/Decremento | 5 |
| Igualdad (Equatable) | 4 |
| Métodos utilitarios | 2 |

### Tests Unitarios: CartAggregate (23 tests)

| Grupo | Tests |
|-------|-------|
| Creación | 2 |
| Agregar ítems | 4 |
| Actualizar cantidad | 3 |
| Eliminar ítems | 3 |
| Cálculo de total | 3 |
| Vaciar carrito | 2 |
| Consultas | 4 |
| Inmutabilidad | 2 |

### Tests de Aceptación: Cart (17 tests)

| Criterio de Aceptación | Tests |
|------------------------|-------|
| AC1: Agregar productos | 2 |
| AC2: Ver contenido | 1 |
| AC3: Actualizar cantidad | 2 |
| AC4: Eliminar productos | 2 |
| AC5: Calcular total | 3 |
| AC6: Vaciar carrito | 1 |
| AC7: Eventos de dominio | 4 |
| AC8: CartItem subtotal | 2 |

## Patrones Aplicados

### 1. Aggregate Pattern
CartAggregate actúa como Aggregate Root, controlando el acceso a CartItems y garantizando consistencia.

### 2. Inmutabilidad
Todas las operaciones retornan nuevas instancias:
```dart
var cart = CartAggregate.empty();
cart = cart.addItem(...); // Nueva instancia
```

### 3. Event Sourcing (preparación)
Cada operación puede generar eventos:
```dart
final result = cart.addItemWithEvent(...);
// result.cart: nuevo estado
// result.event: evento generado
```

### 4. Value Object Pattern
CartItem encapsula datos con validación y comportamientos:
```dart
final item = CartItem(
  productId: ProductId(1),
  quantity: 2,
  unitPrice: Money.fromDouble(50.0),
);
print(item.subtotal); // $100.00
```

## Ejemplo de Uso Completo

```dart
// Crear carrito vacío
var cart = CartAggregate.empty();

// Agregar productos
cart = cart.addItem(
  productId: ProductId(1),
  quantity: 2,
  unitPrice: Money.fromDouble(100.0),
);

cart = cart.addItem(
  productId: ProductId(2),
  quantity: 1,
  unitPrice: Money.fromDouble(50.0),
);

// Consultar estado
print(cart.total);           // $250.00
print(cart.itemCount);       // 3 unidades
print(cart.uniqueItemCount); // 2 productos

// Actualizar cantidad
cart = cart.updateQuantity(ProductId(1), 5);
print(cart.total);           // $550.00

// Con eventos
final result = cart.removeItemWithEvent(ProductId(2));
print(result.event);         // ItemRemovedFromCartEvent
print(result.cart.total);    // $500.00

// Vaciar carrito
final clearResult = cart.clearWithEvent();
print(clearResult.event.totalCleared); // $500.00
print(clearResult.cart.isEmpty);       // true
```

## Comandos de Ejecución

```bash
# Tests unitarios de Cart
dart test test/unit/domain/value_objects/cart/
dart test test/unit/domain/aggregates/cart/

# Tests de aceptación de Cart
dart test test/acceptance/features/cart_acceptance_test.dart

# Todos los tests
dart test
```

## Próximos Pasos

### Fase 5: CI/CD y Métricas
- GitHub Actions configurado
- Pipeline de CI automatizado
- Reportes de cobertura

### Futuras Expansiones
- UserAggregate (gestión de usuarios)
- OrderAggregate (procesamiento de pedidos)
- Integración con capas data y presentation

## Conclusión

La Fase 4 agregó un dominio completo de carrito de compras con 61 nuevos tests, elevando el total a 372 tests. El CartAggregate sigue los principios DDD con inmutabilidad, eventos de dominio y validaciones de negocio encapsuladas.
