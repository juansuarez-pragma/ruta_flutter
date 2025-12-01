# Plan de Implementación: TDD, ATDD y DDD

## Resumen Ejecutivo

Este documento detalla el plan de implementación por fases para adoptar TDD (Test-Driven Development), ATDD (Acceptance Test-Driven Development) y DDD (Domain-Driven Design) en el proyecto Fake Store API CLI.

### Estado Actual vs Estado Objetivo

| Aspecto | Estado Actual | Estado Objetivo |
|---------|---------------|-----------------|
| Arquitectura | Clean Architecture | Clean Architecture + DDD Táctico |
| Testing | 168 tests (post-implementación) | TDD (test-first) + ATDD |
| Cobertura | 92.17% | 95%+ |
| Value Objects | 0 | 8+ |
| Agregados | 1 (ProductEntity) | 3+ (Product, Cart, User) |
| Domain Events | 0 | 5+ |
| Endpoints consumidos | 3/11 | 11/11 |
| Tests de Aceptación | Parciales | Completos (Gherkin-style) |

---

## Fase 1: Fundamentos TDD (Semana 1-2)

### Objetivo
Establecer la disciplina y procesos de TDD antes de escribir código nuevo.

### 1.1 Crear Estructura de Tests TDD

```
test/
├── unit/                    # Tests unitarios (existente)
├── integration/             # Tests de integración (existente)
├── acceptance/              # NUEVO: Tests de aceptación
│   ├── features/           # Archivos .feature (Gherkin-style)
│   └── steps/              # Implementación de steps
├── specifications/          # NUEVO: Especificaciones formales
│   ├── domain/
│   ├── data/
│   └── presentation/
└── contracts/               # NUEVO: Tests de contrato
```

### 1.2 Crear Plantilla TDD

**Archivo: `test/templates/tdd_template.dart`**

```dart
/// PLANTILLA TDD - CICLO RED-GREEN-REFACTOR
///
/// PASO 1: ESPECIFICACIÓN (antes del test)
/// ========================================
/// Nombre: [Nombre del componente]
/// Responsabilidad: [Una sola responsabilidad]
///
/// Entrada:
///   - [param1]: [tipo] - [descripción]
///   - [param2]: [tipo] - [descripción]
///
/// Salida esperada (éxito):
///   - [tipo de retorno]
///   - [condiciones de éxito]
///
/// Salida esperada (error):
///   - [tipo de error 1]: [cuándo ocurre]
///   - [tipo de error 2]: [cuándo ocurre]
///
/// Precondiciones:
///   - [condición 1]
///   - [condición 2]
///
/// Postcondiciones:
///   - [efecto 1]
///   - [efecto 2]
///
/// PASO 2: TEST (RED - debe fallar)
/// ================================
///
/// PASO 3: IMPLEMENTACIÓN (GREEN - mínimo para pasar)
/// ==================================================
///
/// PASO 4: REFACTOR (sin romper tests)
/// ===================================

import 'package:test/test.dart';

void main() {
  group('[NombreComponente]', () {
    // Arrange global
    late ComponenteAProbar sut; // System Under Test

    setUp(() {
      // Configuración antes de cada test
    });

    tearDown(() {
      // Limpieza después de cada test
    });

    group('cuando [contexto/estado]', () {
      test('debería [comportamiento esperado]', () {
        // Arrange - Preparar datos específicos

        // Act - Ejecutar acción

        // Assert - Verificar resultado
      });
    });
  });
}
```

### 1.3 Proceso TDD Obligatorio

**Documento de proceso: `docs/TDD_PROCESS.md`**

```markdown
# Proceso TDD Obligatorio

## Ciclo Red-Green-Refactor

### 1. RED (Test que falla)
- [ ] Escribir especificación formal en comentarios
- [ ] Escribir test ANTES del código
- [ ] Ejecutar test → DEBE FALLAR
- [ ] Commit: "test: add failing test for [feature]"

### 2. GREEN (Implementación mínima)
- [ ] Escribir código MÍNIMO para pasar el test
- [ ] NO agregar funcionalidad extra
- [ ] Ejecutar test → DEBE PASAR
- [ ] Commit: "feat: implement [feature] to pass test"

### 3. REFACTOR (Mejorar sin romper)
- [ ] Mejorar código manteniendo tests verdes
- [ ] Eliminar duplicación
- [ ] Mejorar nombres
- [ ] Ejecutar TODOS los tests → DEBEN PASAR
- [ ] Commit: "refactor: improve [feature] implementation"

## Orden de Implementación TDD

1. **Domain Layer** (primero)
   - Value Objects
   - Entities/Aggregates
   - Domain Events
   - Use Cases
   - Repository Interfaces

2. **Data Layer** (segundo)
   - Models
   - DataSources
   - Repository Implementations

3. **Presentation Layer** (tercero)
   - Contracts
   - Adapters
   - Application

## Reglas de Oro

1. NUNCA escribir código de producción sin un test que falle
2. NUNCA escribir más de un test que falle a la vez
3. NUNCA escribir más código del necesario para pasar el test
4. Cada ciclo TDD debe completarse en < 10 minutos
```

### 1.4 Implementar Primer Ejemplo TDD

**Caso: GetProductsByCategoryUseCase**

#### Paso 1: Especificación

```dart
// test/specifications/domain/get_products_by_category_spec.dart

/// ESPECIFICACIÓN: GetProductsByCategoryUseCase
///
/// Responsabilidad: Obtener productos filtrados por categoría
///
/// Entrada:
///   - params: CategoryParams
///     - category: String - nombre de la categoría (no vacío)
///
/// Salida esperada (éxito):
///   - Either<Failure, List<ProductEntity>>
///   - Right(lista de productos de esa categoría)
///   - Lista puede estar vacía si no hay productos
///
/// Salida esperada (error):
///   - Left(ServerFailure): API retorna 5xx
///   - Left(ConnectionFailure): Error de red
///   - Left(NotFoundFailure): Categoría no existe (404)
///   - Left(ClientFailure): Otros errores 4xx
///
/// Precondiciones:
///   - Repository disponible
///   - Categoría es string no vacío
///
/// Postcondiciones:
///   - Repository.getProductsByCategory() llamado exactamente 1 vez
///   - Sin efectos secundarios
```

#### Paso 2: Test RED

```dart
// test/unit/domain/usecases/get_products_by_category_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// Imports del proyecto (aún no existen - RED)
import 'package:fase_2_consumo_api/src/domain/usecases/product/get_products_by_category_usecase.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetProductsByCategoryUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsByCategoryUseCase(mockRepository);
  });

  group('GetProductsByCategoryUseCase', () {
    const testCategory = 'electronics';

    test('retorna lista de productos cuando el repositorio tiene éxito', () async {
      // Arrange
      final testProducts = createTestProductEntityList(count: 3)
          .map((p) => p.copyWith(category: testCategory))
          .toList();
      when(mockRepository.getProductsByCategory(testCategory))
          .thenAnswer((_) async => Right(testProducts));

      // Act
      final result = await useCase(CategoryParams(category: testCategory));

      // Assert
      expect(result, Right(testProducts));
      verify(mockRepository.getProductsByCategory(testCategory)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      const failure = ServerFailure('Error del servidor');
      when(mockRepository.getProductsByCategory(testCategory))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(CategoryParams(category: testCategory));

      // Assert
      expect(result, const Left(failure));
    });

    test('retorna lista vacía cuando no hay productos en la categoría', () async {
      // Arrange
      when(mockRepository.getProductsByCategory(testCategory))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(CategoryParams(category: testCategory));

      // Assert
      result.fold(
        (failure) => fail('No debería retornar failure'),
        (products) => expect(products, isEmpty),
      );
    });
  });
}
```

#### Paso 3: Implementación GREEN

```dart
// lib/src/domain/usecases/product/get_products_by_category_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

/// Caso de uso para obtener productos filtrados por categoría.
///
/// Retorna [Either] con [Failure] en caso de error o lista de [ProductEntity]
/// que pertenecen a la categoría especificada.
class GetProductsByCategoryUseCase
    implements UseCase<List<ProductEntity>, CategoryParams> {
  final ProductRepository _repository;

  GetProductsByCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(CategoryParams params) {
    return _repository.getProductsByCategory(params.category);
  }
}

/// Parámetros para [GetProductsByCategoryUseCase].
class CategoryParams extends Equatable {
  final String category;

  const CategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
```

### 1.5 Checklist Fase 1

- [ ] Crear estructura de carpetas para TDD
- [ ] Crear plantilla TDD
- [ ] Documentar proceso TDD
- [ ] Implementar GetProductsByCategoryUseCase con TDD
- [ ] Actualizar repositorio con nuevo método
- [ ] Actualizar datasource con nuevo endpoint
- [ ] Todos los tests pasan
- [ ] Cobertura mantiene 92%+

---

## Fase 2: DDD Táctico (Semana 3-4)

### Objetivo
Implementar patrones tácticos de DDD: Value Objects, Aggregates y Domain Events.

### 2.1 Value Objects

**Estructura:**
```
lib/src/domain/
└── value_objects/
    ├── value_objects.dart          # Barrel file
    ├── value_object.dart           # Clase base abstracta
    ├── product/
    │   ├── product_value_objects.dart  # Barrel file
    │   ├── product_id.dart
    │   ├── product_title.dart
    │   ├── product_description.dart
    │   └── product_image.dart
    └── shared/
        ├── shared_value_objects.dart   # Barrel file
        ├── money.dart
        └── positive_integer.dart
```

#### 2.1.1 Value Object Base (TDD)

**Test RED:**
```dart
// test/unit/domain/value_objects/value_object_test.dart

void main() {
  group('ValueObject', () {
    test('dos value objects con mismo valor son iguales', () {
      final vo1 = TestValueObject('test');
      final vo2 = TestValueObject('test');

      expect(vo1, equals(vo2));
      expect(vo1.hashCode, equals(vo2.hashCode));
    });

    test('dos value objects con diferente valor no son iguales', () {
      final vo1 = TestValueObject('test1');
      final vo2 = TestValueObject('test2');

      expect(vo1, isNot(equals(vo2)));
    });
  });
}

class TestValueObject extends ValueObject<String> {
  TestValueObject(String value) : super(value);
}
```

**Implementación GREEN:**
```dart
// lib/src/domain/value_objects/value_object.dart

import 'package:equatable/equatable.dart';

/// Clase base abstracta para Value Objects.
///
/// Un Value Object es inmutable y se compara por valor, no por identidad.
/// Extiende [Equatable] para comparación automática.
abstract class ValueObject<T> extends Equatable {
  final T value;

  const ValueObject(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '$runtimeType($value)';
}
```

#### 2.1.2 Money Value Object (TDD)

**Especificación:**
```dart
/// ESPECIFICACIÓN: Money
///
/// Responsabilidad: Representar un valor monetario no negativo
///
/// Invariantes:
///   - Valor debe ser >= 0
///   - Precisión de 2 decimales
///
/// Operaciones:
///   - add(Money): Suma dos valores
///   - subtract(Money): Resta (no puede ser negativo)
///   - multiply(int): Multiplica por cantidad
///   - compareTo(Money): Comparación
///
/// Factory:
///   - Money.fromDouble(double): Crea desde double
///   - Money.zero: Valor cero
///
/// Errores:
///   - ArgumentError si valor < 0
```

**Test RED:**
```dart
// test/unit/domain/value_objects/shared/money_test.dart

import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/shared/money.dart';

void main() {
  group('Money', () {
    group('creación', () {
      test('crea Money con valor válido', () {
        final money = Money.fromDouble(99.99);

        expect(money.value, equals(99.99));
      });

      test('lanza ArgumentError con valor negativo', () {
        expect(
          () => Money.fromDouble(-1.0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Money.zero retorna valor cero', () {
        expect(Money.zero.value, equals(0.0));
      });
    });

    group('operaciones', () {
      test('add suma dos valores correctamente', () {
        final m1 = Money.fromDouble(10.50);
        final m2 = Money.fromDouble(5.25);

        final result = m1.add(m2);

        expect(result.value, equals(15.75));
      });

      test('subtract resta correctamente', () {
        final m1 = Money.fromDouble(10.00);
        final m2 = Money.fromDouble(3.50);

        final result = m1.subtract(m2);

        expect(result.value, equals(6.50));
      });

      test('subtract lanza error si resultado sería negativo', () {
        final m1 = Money.fromDouble(5.00);
        final m2 = Money.fromDouble(10.00);

        expect(
          () => m1.subtract(m2),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('multiply multiplica correctamente', () {
        final money = Money.fromDouble(10.00);

        final result = money.multiply(3);

        expect(result.value, equals(30.00));
      });
    });

    group('comparación', () {
      test('dos Money con mismo valor son iguales', () {
        final m1 = Money.fromDouble(99.99);
        final m2 = Money.fromDouble(99.99);

        expect(m1, equals(m2));
      });

      test('compareTo ordena correctamente', () {
        final m1 = Money.fromDouble(10.00);
        final m2 = Money.fromDouble(20.00);

        expect(m1.compareTo(m2), lessThan(0));
        expect(m2.compareTo(m1), greaterThan(0));
        expect(m1.compareTo(m1), equals(0));
      });
    });

    group('formato', () {
      test('toString muestra formato de moneda', () {
        final money = Money.fromDouble(99.99);

        expect(money.toString(), equals('\$99.99'));
      });
    });
  });
}
```

**Implementación GREEN:**
```dart
// lib/src/domain/value_objects/shared/money.dart

import '../value_object.dart';

/// Value Object que representa un valor monetario.
///
/// Es inmutable y garantiza que el valor nunca sea negativo.
/// Proporciona operaciones aritméticas seguras.
class Money extends ValueObject<double> implements Comparable<Money> {
  /// Crea un [Money] desde un valor double.
  ///
  /// Lanza [ArgumentError] si [amount] es negativo.
  Money.fromDouble(double amount) : super(_validate(amount));

  /// Valor cero.
  static final Money zero = Money.fromDouble(0.0);

  static double _validate(double amount) {
    if (amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'El valor monetario no puede ser negativo',
      );
    }
    return double.parse(amount.toStringAsFixed(2));
  }

  /// Suma este valor con [other].
  Money add(Money other) => Money.fromDouble(value + other.value);

  /// Resta [other] de este valor.
  ///
  /// Lanza [ArgumentError] si el resultado sería negativo.
  Money subtract(Money other) => Money.fromDouble(value - other.value);

  /// Multiplica este valor por [quantity].
  Money multiply(int quantity) => Money.fromDouble(value * quantity);

  @override
  int compareTo(Money other) => value.compareTo(other.value);

  /// Operadores de comparación.
  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  String toString() => '\$${value.toStringAsFixed(2)}';
}
```

#### 2.1.3 ProductId Value Object (TDD)

**Test RED:**
```dart
// test/unit/domain/value_objects/product/product_id_test.dart

void main() {
  group('ProductId', () {
    test('crea ProductId con valor válido', () {
      final id = ProductId(1);
      expect(id.value, equals(1));
    });

    test('lanza ArgumentError con valor <= 0', () {
      expect(() => ProductId(0), throwsA(isA<ArgumentError>()));
      expect(() => ProductId(-1), throwsA(isA<ArgumentError>()));
    });

    test('dos ProductId con mismo valor son iguales', () {
      expect(ProductId(5), equals(ProductId(5)));
    });
  });
}
```

**Implementación GREEN:**
```dart
// lib/src/domain/value_objects/product/product_id.dart

import '../value_object.dart';

/// Value Object que representa el identificador único de un producto.
///
/// Garantiza que el ID sea un entero positivo mayor que cero.
class ProductId extends ValueObject<int> {
  /// Crea un [ProductId] con el valor especificado.
  ///
  /// Lanza [ArgumentError] si [value] es menor o igual a cero.
  ProductId(int value) : super(_validate(value));

  static int _validate(int value) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        'value',
        'El ID del producto debe ser un entero positivo',
      );
    }
    return value;
  }
}
```

### 2.2 Product Aggregate

**Estructura:**
```
lib/src/domain/
└── aggregates/
    ├── aggregates.dart             # Barrel file
    └── product/
        ├── product.dart            # Barrel file
        ├── product_aggregate.dart  # Aggregate Root
        └── product_factory.dart    # Factory para crear productos
```

#### 2.2.1 Product Aggregate (TDD)

**Especificación:**
```dart
/// ESPECIFICACIÓN: Product (Aggregate Root)
///
/// Responsabilidad: Representar un producto con todas sus invariantes
///
/// Componentes:
///   - id: ProductId
///   - title: ProductTitle
///   - price: Money
///   - description: ProductDescription
///   - category: ProductCategory
///   - image: ProductImage
///
/// Comportamientos:
///   - isAffordable(budget: Money): bool
///   - isInCategory(category: ProductCategory): bool
///   - matchesSearch(term: String): bool
///   - applyDiscount(percentage: int): Product
///
/// Invariantes:
///   - Todos los campos son requeridos
///   - Descuento máximo 50%
```

**Test RED:**
```dart
// test/unit/domain/aggregates/product/product_aggregate_test.dart

import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/domain/aggregates/product/product_aggregate.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/value_objects.dart';

void main() {
  group('Product Aggregate', () {
    late Product product;

    setUp(() {
      product = Product(
        id: ProductId(1),
        title: ProductTitle('Laptop Gaming'),
        price: Money.fromDouble(999.99),
        description: ProductDescription('Laptop de alta gama para gaming'),
        category: ProductCategory.electronics,
        image: ProductImage(Uri.parse('https://example.com/laptop.jpg')),
      );
    });

    group('isAffordable', () {
      test('retorna true cuando el presupuesto es suficiente', () {
        final budget = Money.fromDouble(1000.00);

        expect(product.isAffordable(budget), isTrue);
      });

      test('retorna false cuando el presupuesto es insuficiente', () {
        final budget = Money.fromDouble(500.00);

        expect(product.isAffordable(budget), isFalse);
      });

      test('retorna true cuando el presupuesto es exacto', () {
        final budget = Money.fromDouble(999.99);

        expect(product.isAffordable(budget), isTrue);
      });
    });

    group('isInCategory', () {
      test('retorna true para la categoría correcta', () {
        expect(product.isInCategory(ProductCategory.electronics), isTrue);
      });

      test('retorna false para categoría diferente', () {
        expect(product.isInCategory(ProductCategory.jewelery), isFalse);
      });
    });

    group('matchesSearch', () {
      test('retorna true si el término está en el título', () {
        expect(product.matchesSearch('Laptop'), isTrue);
        expect(product.matchesSearch('laptop'), isTrue); // Case insensitive
      });

      test('retorna true si el término está en la descripción', () {
        expect(product.matchesSearch('gaming'), isTrue);
      });

      test('retorna false si el término no coincide', () {
        expect(product.matchesSearch('smartphone'), isFalse);
      });
    });

    group('applyDiscount', () {
      test('aplica descuento correctamente', () {
        final discounted = product.applyDiscount(10);

        expect(discounted.price.value, closeTo(899.99, 0.01));
      });

      test('lanza error si descuento > 50%', () {
        expect(
          () => product.applyDiscount(51),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('lanza error si descuento < 0', () {
        expect(
          () => product.applyDiscount(-5),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('igualdad', () {
      test('dos productos con mismo ID son iguales', () {
        final product2 = Product(
          id: ProductId(1),
          title: ProductTitle('Otro título'),
          price: Money.fromDouble(500.00),
          description: ProductDescription('Otra descripción'),
          category: ProductCategory.jewelery,
          image: ProductImage(Uri.parse('https://other.com/img.jpg')),
        );

        // Aggregates se comparan por ID
        expect(product.id, equals(product2.id));
      });
    });
  });
}
```

**Implementación GREEN:**
```dart
// lib/src/domain/aggregates/product/product_aggregate.dart

import 'package:equatable/equatable.dart';

import '../../value_objects/value_objects.dart';

/// Aggregate Root que representa un Producto.
///
/// El Product es el aggregate root del bounded context de Catálogo.
/// Encapsula todas las invariantes de negocio relacionadas con productos.
class Product extends Equatable {
  final ProductId id;
  final ProductTitle title;
  final Money price;
  final ProductDescription description;
  final ProductCategory category;
  final ProductImage image;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  /// Verifica si el producto está dentro del presupuesto dado.
  bool isAffordable(Money budget) => price <= budget;

  /// Verifica si el producto pertenece a la categoría especificada.
  bool isInCategory(ProductCategory cat) => category == cat;

  /// Verifica si el producto coincide con el término de búsqueda.
  ///
  /// Busca en título y descripción (case insensitive).
  bool matchesSearch(String term) {
    final lowerTerm = term.toLowerCase();
    return title.value.toLowerCase().contains(lowerTerm) ||
        description.value.toLowerCase().contains(lowerTerm);
  }

  /// Aplica un descuento porcentual al producto.
  ///
  /// Retorna una nueva instancia con el precio reducido.
  /// Lanza [ArgumentError] si el porcentaje no está entre 0 y 50.
  Product applyDiscount(int percentage) {
    if (percentage < 0 || percentage > 50) {
      throw ArgumentError.value(
        percentage,
        'percentage',
        'El descuento debe estar entre 0% y 50%',
      );
    }

    final discount = price.value * (percentage / 100);
    final newPrice = Money.fromDouble(price.value - discount);

    return Product(
      id: id,
      title: title,
      price: newPrice,
      description: description,
      category: category,
      image: image,
    );
  }

  /// Crea una copia con los campos especificados modificados.
  Product copyWith({
    ProductId? id,
    ProductTitle? title,
    Money? price,
    ProductDescription? description,
    ProductCategory? category,
    ProductImage? image,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [id]; // Aggregates se comparan por ID
}
```

### 2.3 Domain Events

**Estructura:**
```
lib/src/domain/
└── events/
    ├── events.dart                 # Barrel file
    ├── domain_event.dart           # Clase base
    ├── event_dispatcher.dart       # Dispatcher de eventos
    └── product/
        ├── product_events.dart     # Barrel file
        ├── product_viewed_event.dart
        └── product_searched_event.dart
```

#### 2.3.1 Domain Event Base (TDD)

**Test RED:**
```dart
// test/unit/domain/events/domain_event_test.dart

void main() {
  group('DomainEvent', () {
    test('registra timestamp de ocurrencia', () {
      final before = DateTime.now();
      final event = TestDomainEvent();
      final after = DateTime.now();

      expect(event.occurredAt.isAfter(before.subtract(Duration(seconds: 1))), isTrue);
      expect(event.occurredAt.isBefore(after.add(Duration(seconds: 1))), isTrue);
    });

    test('genera ID único', () {
      final event1 = TestDomainEvent();
      final event2 = TestDomainEvent();

      expect(event1.eventId, isNot(equals(event2.eventId)));
    });
  });
}
```

**Implementación GREEN:**
```dart
// lib/src/domain/events/domain_event.dart

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Clase base abstracta para todos los eventos de dominio.
///
/// Un evento de dominio representa algo significativo que ocurrió
/// en el dominio de negocio.
abstract class DomainEvent extends Equatable {
  /// Identificador único del evento.
  final String eventId;

  /// Momento en que ocurrió el evento.
  final DateTime occurredAt;

  DomainEvent()
      : eventId = const Uuid().v4(),
        occurredAt = DateTime.now();

  @override
  List<Object?> get props => [eventId];
}
```

#### 2.3.2 ProductViewedEvent (TDD)

**Test RED:**
```dart
// test/unit/domain/events/product/product_viewed_event_test.dart

void main() {
  group('ProductViewedEvent', () {
    test('contiene el ID del producto visto', () {
      final productId = ProductId(42);
      final event = ProductViewedEvent(productId: productId);

      expect(event.productId, equals(productId));
    });

    test('es un DomainEvent válido', () {
      final event = ProductViewedEvent(productId: ProductId(1));

      expect(event, isA<DomainEvent>());
      expect(event.eventId, isNotEmpty);
      expect(event.occurredAt, isNotNull);
    });
  });
}
```

**Implementación GREEN:**
```dart
// lib/src/domain/events/product/product_viewed_event.dart

import '../../value_objects/product/product_id.dart';
import '../domain_event.dart';

/// Evento emitido cuando un usuario visualiza un producto.
class ProductViewedEvent extends DomainEvent {
  /// ID del producto que fue visualizado.
  final ProductId productId;

  ProductViewedEvent({required this.productId});

  @override
  List<Object?> get props => [super.props, productId];
}
```

### 2.4 Checklist Fase 2

- [ ] Crear estructura de Value Objects
- [ ] Implementar ValueObject base con TDD
- [ ] Implementar Money VO con TDD
- [ ] Implementar ProductId VO con TDD
- [ ] Implementar ProductTitle VO con TDD
- [ ] Implementar ProductDescription VO con TDD
- [ ] Implementar ProductImage VO con TDD
- [ ] Implementar ProductCategory enum
- [ ] Crear Product Aggregate con TDD
- [ ] Implementar DomainEvent base
- [ ] Implementar ProductViewedEvent
- [ ] Implementar ProductSearchedEvent
- [ ] Integrar VOs en ProductEntity existente
- [ ] Actualizar tests existentes
- [ ] Todos los tests pasan
- [ ] Cobertura >= 95%

---

## Fase 3: ATDD - Acceptance Test Driven Development (Semana 5-6)

### Objetivo
Implementar tests de aceptación que definan el comportamiento del sistema desde la perspectiva del usuario.

### 3.1 Estructura ATDD

```
test/
└── acceptance/
    ├── features/                   # Especificaciones Gherkin-style
    │   ├── catalog/
    │   │   ├── browse_products.feature.dart
    │   │   ├── search_products.feature.dart
    │   │   └── filter_by_category.feature.dart
    │   └── error_handling/
    │       └── handle_api_errors.feature.dart
    ├── steps/                      # Implementación de steps
    │   ├── given_steps.dart
    │   ├── when_steps.dart
    │   └── then_steps.dart
    ├── fixtures/
    │   └── acceptance_fixtures.dart
    └── acceptance_test_runner.dart
```

### 3.2 Feature: Browse Products

```dart
// test/acceptance/features/catalog/browse_products.feature.dart

import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';

import 'package:fase_2_consumo_api/src/presentation/application.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

/// Feature: Navegar Productos
///
/// Como usuario de la aplicación CLI
/// Quiero poder ver todos los productos disponibles
/// Para explorar el catálogo de la tienda
void main() {
  group('Feature: Navegar Productos', () {
    // Dependencias
    late Application application;
    late MockUserInterface mockUI;
    late MockGetAllProductsUseCase mockGetAllProducts;
    late MockGetProductByIdUseCase mockGetProductById;
    late MockGetAllCategoriesUseCase mockGetCategories;

    setUp(() {
      mockUI = MockUserInterface();
      mockGetAllProducts = MockGetAllProductsUseCase();
      mockGetProductById = MockGetProductByIdUseCase();
      mockGetCategories = MockGetAllCategoriesUseCase();

      application = Application(
        userInterface: mockUI,
        getAllProductsUseCase: mockGetAllProducts,
        getProductByIdUseCase: mockGetProductById,
        getAllCategoriesUseCase: mockGetCategories,
      );
    });

    group('Scenario: Ver lista completa de productos', () {
      /// Given: hay productos disponibles en el catálogo
      /// When: el usuario selecciona "Ver todos los productos"
      /// Then: se muestra la lista de todos los productos
      /// And: cada producto muestra id, título, precio y categoría

      test('muestra todos los productos cuando hay datos disponibles', () async {
        // GIVEN: hay productos disponibles en el catálogo
        final productos = createTestProductEntityList(count: 5);
        when(mockGetAllProducts(any)).thenAnswer((_) async => Right(productos));
        when(mockUI.showMainMenu()).thenAnswer((_) async => MenuOption.getAllProducts);
        when(mockUI.showProducts(any)).thenReturn(null);

        // Configurar para salir después de mostrar productos
        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllProducts : MenuOption.exit;
        });

        // WHEN: el usuario selecciona "Ver todos los productos"
        await application.run();

        // THEN: se muestra la lista de todos los productos
        verify(mockUI.showProducts(productos)).called(1);

        // AND: la aplicación llamó al caso de uso correcto
        verify(mockGetAllProducts(any)).called(1);
      });
    });

    group('Scenario: Lista de productos vacía', () {
      /// Given: no hay productos en el catálogo
      /// When: el usuario solicita ver todos los productos
      /// Then: se muestra un mensaje indicando que no hay productos

      test('muestra mensaje cuando no hay productos', () async {
        // GIVEN: no hay productos en el catálogo
        when(mockGetAllProducts(any)).thenAnswer((_) async => const Right([]));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllProducts : MenuOption.exit;
        });

        // WHEN: el usuario solicita ver todos los productos
        await application.run();

        // THEN: se muestra lista vacía (UI maneja el mensaje)
        verify(mockUI.showProducts([])).called(1);
      });
    });

    group('Scenario: Error de conexión al obtener productos', () {
      /// Given: hay un problema de conexión con la API
      /// When: el usuario intenta ver los productos
      /// Then: se muestra un mensaje de error de conexión
      /// And: el usuario puede intentar de nuevo

      test('muestra error de conexión cuando la API no responde', () async {
        // GIVEN: hay un problema de conexión con la API
        const connectionFailure = ConnectionFailure('No se pudo conectar al servidor');
        when(mockGetAllProducts(any)).thenAnswer((_) async => const Left(connectionFailure));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllProducts : MenuOption.exit;
        });

        // WHEN: el usuario intenta ver los productos
        await application.run();

        // THEN: se muestra un mensaje de error
        verify(mockUI.showError(any)).called(1);
      });
    });

    group('Scenario: Error del servidor al obtener productos', () {
      /// Given: el servidor retorna un error 500
      /// When: el usuario solicita los productos
      /// Then: se muestra un mensaje de error del servidor

      test('muestra error del servidor cuando API retorna 500', () async {
        // GIVEN: el servidor retorna un error 500
        const serverFailure = ServerFailure('Error interno del servidor');
        when(mockGetAllProducts(any)).thenAnswer((_) async => const Left(serverFailure));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllProducts : MenuOption.exit;
        });

        // WHEN: el usuario solicita los productos
        await application.run();

        // THEN: se muestra un mensaje de error
        verify(mockUI.showError(any)).called(1);
      });
    });
  });
}
```

### 3.3 Feature: Search Product by ID

```dart
// test/acceptance/features/catalog/search_product_by_id.feature.dart

/// Feature: Buscar Producto por ID
///
/// Como usuario de la aplicación CLI
/// Quiero poder buscar un producto por su ID
/// Para ver los detalles completos de un producto específico
void main() {
  group('Feature: Buscar Producto por ID', () {
    late Application application;
    late MockUserInterface mockUI;
    late MockGetAllProductsUseCase mockGetAllProducts;
    late MockGetProductByIdUseCase mockGetProductById;
    late MockGetAllCategoriesUseCase mockGetCategories;

    setUp(() {
      // ... setup igual que anterior
    });

    group('Scenario: Buscar producto existente', () {
      /// Given: existe un producto con ID 5 en el catálogo
      /// When: el usuario busca el producto con ID 5
      /// Then: se muestran los detalles completos del producto

      test('muestra detalles cuando el producto existe', () async {
        // GIVEN: existe un producto con ID 5
        final producto = createTestProductEntity(id: 5, title: 'Laptop Gaming');
        when(mockGetProductById(any)).thenAnswer((_) async => Right(producto));
        when(mockUI.promptProductId()).thenAnswer((_) async => 5);

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getProductById : MenuOption.exit;
        });

        // WHEN: el usuario busca el producto con ID 5
        await application.run();

        // THEN: se muestran los detalles del producto
        verify(mockUI.showProduct(producto)).called(1);
      });
    });

    group('Scenario: Buscar producto inexistente', () {
      /// Given: no existe un producto con ID 999
      /// When: el usuario busca el producto con ID 999
      /// Then: se muestra un mensaje de "producto no encontrado"

      test('muestra error cuando el producto no existe', () async {
        // GIVEN: no existe un producto con ID 999
        const notFoundFailure = NotFoundFailure('Producto no encontrado');
        when(mockGetProductById(any)).thenAnswer((_) async => const Left(notFoundFailure));
        when(mockUI.promptProductId()).thenAnswer((_) async => 999);

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getProductById : MenuOption.exit;
        });

        // WHEN: el usuario busca el producto con ID 999
        await application.run();

        // THEN: se muestra mensaje de error
        verify(mockUI.showError(any)).called(1);
      });
    });

    group('Scenario: ID inválido', () {
      /// Given: el usuario está en la pantalla de búsqueda
      /// When: el usuario ingresa un ID no numérico o inválido
      /// Then: se muestra un mensaje de validación
      /// And: se solicita un ID válido nuevamente

      test('maneja entrada inválida del usuario', () async {
        // Este escenario requiere validación en la UI
        // La implementación depende de cómo ConsoleUserInterface maneja el input
      });
    });
  });
}
```

### 3.4 Criterios de Aceptación Documentados

```dart
// test/acceptance/acceptance_criteria.dart

/// # CRITERIOS DE ACEPTACIÓN
///
/// Este archivo documenta los criterios de aceptación para cada feature
/// del sistema. Cada criterio debe tener al menos un test que lo verifique.

/// ## Feature: Catálogo de Productos
///
/// ### AC-001: Ver todos los productos
/// - [ ] El sistema muestra una lista de todos los productos
/// - [ ] Cada producto muestra: ID, título, precio, categoría
/// - [ ] Los productos se muestran ordenados por ID
/// - [ ] Si no hay productos, se muestra mensaje informativo
///
/// ### AC-002: Buscar producto por ID
/// - [ ] El usuario puede ingresar un ID numérico
/// - [ ] Si el producto existe, se muestran todos sus detalles
/// - [ ] Si el producto no existe, se muestra error 404
/// - [ ] IDs inválidos muestran mensaje de validación
///
/// ### AC-003: Ver categorías
/// - [ ] El sistema muestra todas las categorías disponibles
/// - [ ] Las categorías se muestran como lista
/// - [ ] Si no hay categorías, se muestra mensaje informativo
///
/// ### AC-004: Filtrar por categoría (PENDIENTE)
/// - [ ] El usuario puede seleccionar una categoría
/// - [ ] Se muestran solo productos de esa categoría
/// - [ ] Si la categoría está vacía, se muestra mensaje
///
/// ## Feature: Manejo de Errores
///
/// ### AC-005: Errores de conexión
/// - [ ] Si no hay conexión, se muestra mensaje amigable
/// - [ ] El usuario puede reintentar la operación
/// - [ ] No se muestra stack trace al usuario
///
/// ### AC-006: Errores del servidor
/// - [ ] Errores 5xx muestran mensaje de error del servidor
/// - [ ] El usuario puede reintentar
/// - [ ] Se registra el error para diagnóstico
///
/// ### AC-007: Recursos no encontrados
/// - [ ] Errores 404 muestran mensaje específico
/// - [ ] Se indica qué recurso no se encontró
/// - [ ] El usuario puede buscar otro recurso

class AcceptanceCriteria {
  static const Map<String, List<String>> criteria = {
    'AC-001': [
      'El sistema muestra una lista de todos los productos',
      'Cada producto muestra: ID, título, precio, categoría',
      'Los productos se muestran ordenados por ID',
      'Si no hay productos, se muestra mensaje informativo',
    ],
    'AC-002': [
      'El usuario puede ingresar un ID numérico',
      'Si el producto existe, se muestran todos sus detalles',
      'Si el producto no existe, se muestra error 404',
      'IDs inválidos muestran mensaje de validación',
    ],
    // ... más criterios
  };
}
```

### 3.5 Checklist Fase 3

- [ ] Crear estructura de carpetas para ATDD
- [ ] Implementar Feature: Browse Products
- [ ] Implementar Feature: Search Product by ID
- [ ] Implementar Feature: View Categories
- [ ] Implementar Feature: Filter by Category
- [ ] Implementar Feature: Handle API Errors
- [ ] Documentar criterios de aceptación
- [ ] Crear steps reutilizables
- [ ] Todos los tests de aceptación pasan
- [ ] Documentar cobertura de criterios

---

## Fase 4: Expansión del Dominio (Semana 7-10)

### Objetivo
Expandir el sistema para consumir todos los endpoints de Fake Store API, aplicando TDD, ATDD y DDD.

### 4.1 Nuevos Bounded Contexts

```
lib/src/domain/
├── catalog/                    # Contexto existente (productos, categorías)
│   ├── aggregates/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   └── value_objects/
├── cart/                       # NUEVO: Carrito de compras
│   ├── aggregates/
│   │   └── cart/
│   │       ├── cart_aggregate.dart
│   │       └── cart_item.dart
│   ├── repositories/
│   │   └── cart_repository.dart
│   ├── usecases/
│   │   ├── get_cart_usecase.dart
│   │   ├── add_to_cart_usecase.dart
│   │   └── remove_from_cart_usecase.dart
│   └── value_objects/
│       └── cart_id.dart
├── user/                       # NUEVO: Gestión de usuarios
│   ├── aggregates/
│   │   └── user/
│   │       └── user_aggregate.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   ├── usecases/
│   │   ├── get_user_usecase.dart
│   │   └── get_all_users_usecase.dart
│   └── value_objects/
│       ├── user_id.dart
│       ├── email.dart
│       └── username.dart
└── shared/                     # Elementos compartidos
    ├── events/
    ├── specifications/
    └── value_objects/
```

### 4.2 Cart Aggregate (TDD)

**Especificación:**
```dart
/// ESPECIFICACIÓN: Cart (Aggregate Root)
///
/// Responsabilidad: Gestionar un carrito de compras con sus items
///
/// Componentes:
///   - id: CartId
///   - userId: UserId
///   - items: List<CartItem>
///   - createdAt: DateTime
///
/// Comportamientos:
///   - addItem(product, quantity): Cart
///   - removeItem(productId): Cart
///   - updateQuantity(productId, quantity): Cart
///   - clear(): Cart
///   - total: Money (calculado)
///   - itemCount: int (calculado)
///
/// Invariantes:
///   - Quantity de cada item >= 1
///   - No puede haber items duplicados (mismo productId)
///   - Total es la suma de (price * quantity) de todos los items
```

**Tests (extracto):**
```dart
// test/unit/domain/cart/aggregates/cart_aggregate_test.dart

void main() {
  group('Cart Aggregate', () {
    late Cart cart;

    setUp(() {
      cart = Cart.empty(userId: UserId(1));
    });

    group('addItem', () {
      test('agrega item al carrito vacío', () {
        final product = createTestProduct();

        final updatedCart = cart.addItem(product, quantity: 2);

        expect(updatedCart.itemCount, equals(1));
        expect(updatedCart.items.first.quantity, equals(2));
      });

      test('incrementa cantidad si el producto ya existe', () {
        final product = createTestProduct();

        final cart1 = cart.addItem(product, quantity: 2);
        final cart2 = cart1.addItem(product, quantity: 3);

        expect(cart2.itemCount, equals(1)); // Sigue siendo 1 item
        expect(cart2.items.first.quantity, equals(5)); // Pero cantidad = 5
      });

      test('lanza error si quantity <= 0', () {
        final product = createTestProduct();

        expect(
          () => cart.addItem(product, quantity: 0),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('total', () {
      test('calcula total correctamente', () {
        final p1 = createTestProduct(price: 10.00);
        final p2 = createTestProduct(id: 2, price: 25.00);

        final updatedCart = cart
            .addItem(p1, quantity: 2)  // 20.00
            .addItem(p2, quantity: 1); // 25.00

        expect(updatedCart.total.value, equals(45.00));
      });

      test('total de carrito vacío es cero', () {
        expect(cart.total, equals(Money.zero));
      });
    });

    group('removeItem', () {
      test('elimina item del carrito', () {
        final product = createTestProduct();
        final cartWithItem = cart.addItem(product, quantity: 1);

        final emptyCart = cartWithItem.removeItem(product.id);

        expect(emptyCart.itemCount, equals(0));
      });

      test('no hace nada si el item no existe', () {
        final nonExistentId = ProductId(999);

        final sameCart = cart.removeItem(nonExistentId);

        expect(sameCart, equals(cart));
      });
    });
  });
}
```

### 4.3 Nuevos Endpoints

```dart
// lib/src/core/constants/api_endpoints.dart (actualizado)

abstract class ApiEndpoints {
  ApiEndpoints._();

  // ============================================
  // Productos (existentes)
  // ============================================
  static const String products = '/products';
  static String productById(int id) => '/products/$id';

  // NUEVO: Productos por categoría
  static String productsByCategory(String category) => '/products/category/$category';

  // ============================================
  // Categorías (existente)
  // ============================================
  static const String categories = '/products/categories';

  // ============================================
  // Carritos (NUEVO)
  // ============================================

  /// Obtener todos los carritos.
  /// GET /carts
  static const String carts = '/carts';

  /// Obtener carrito por ID.
  /// GET /carts/{id}
  static String cartById(int id) => '/carts/$id';

  /// Obtener carritos de un usuario.
  /// GET /carts/user/{userId}
  static String cartsByUser(int userId) => '/carts/user/$userId';

  // ============================================
  // Usuarios (NUEVO)
  // ============================================

  /// Obtener todos los usuarios.
  /// GET /users
  static const String users = '/users';

  /// Obtener usuario por ID.
  /// GET /users/{id}
  static String userById(int id) => '/users/$id';
}
```

### 4.4 Orden de Implementación TDD

```
1. Cart Domain (TDD)
   ├── CartId Value Object
   ├── CartItem Value Object
   ├── Cart Aggregate
   ├── CartRepository Interface
   └── Use Cases:
       ├── GetCartByIdUseCase
       ├── GetCartsByUserUseCase
       └── CreateCartUseCase

2. Cart Data (TDD)
   ├── CartModel
   ├── CartItemModel
   ├── CartRemoteDataSource
   └── CartRepositoryImpl

3. User Domain (TDD)
   ├── UserId Value Object
   ├── Email Value Object
   ├── Username Value Object
   ├── User Aggregate
   ├── UserRepository Interface
   └── Use Cases:
       ├── GetAllUsersUseCase
       └── GetUserByIdUseCase

4. User Data (TDD)
   ├── UserModel
   ├── UserRemoteDataSource
   └── UserRepositoryImpl

5. Presentation Updates
   ├── UserInterface updates
   ├── ConsoleUserInterface updates
   ├── Application updates
   └── MenuOption updates

6. ATDD Features
   ├── Feature: Manage Cart
   ├── Feature: View Users
   └── Feature: User Cart History
```

### 4.5 Checklist Fase 4

- [ ] Implementar CartId VO con TDD
- [ ] Implementar Cart Aggregate con TDD
- [ ] Implementar CartRepository interface
- [ ] Implementar Cart Use Cases con TDD
- [ ] Implementar CartModel con TDD
- [ ] Implementar CartRemoteDataSource con TDD
- [ ] Implementar CartRepositoryImpl con TDD
- [ ] Implementar User VOs con TDD
- [ ] Implementar User Aggregate con TDD
- [ ] Implementar User Use Cases con TDD
- [ ] Implementar User Data layer con TDD
- [ ] Actualizar UI para Cart y Users
- [ ] Crear tests de aceptación para Cart
- [ ] Crear tests de aceptación para Users
- [ ] Integrar DI container
- [ ] Todos los tests pasan
- [ ] Cobertura >= 95%

---

## Fase 5: Integración Continua y Métricas (Semana 11-12)

### Objetivo
Establecer métricas, CI/CD y prácticas sostenibles.

### 5.1 Métricas de Calidad

```yaml
# .github/workflows/quality.yml

name: Quality Gates

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: 3.9.2

      - name: Install dependencies
        run: dart pub get

      - name: Analyze code
        run: dart analyze --fatal-infos

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Run tests with coverage
        run: |
          dart test --coverage=coverage
          dart pub global activate coverage
          format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 95" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 95% threshold"
            exit 1
          fi

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

### 5.2 Pre-commit Hooks

```yaml
# .pre-commit-config.yaml

repos:
  - repo: local
    hooks:
      - id: dart-analyze
        name: Dart Analyze
        entry: dart analyze
        language: system
        types: [dart]

      - id: dart-format
        name: Dart Format
        entry: dart format --set-exit-if-changed
        language: system
        types: [dart]

      - id: dart-test
        name: Dart Test
        entry: dart test
        language: system
        pass_filenames: false
```

### 5.3 Dashboard de Métricas

```markdown
# METRICS_DASHBOARD.md

## Métricas del Proyecto

### Cobertura de Código
| Capa | Objetivo | Actual |
|------|----------|--------|
| Domain | 100% | - |
| Data | 95% | - |
| Core | 90% | - |
| Presentation | 85% | - |
| **Total** | **95%** | **-** |

### Tests por Tipo
| Tipo | Cantidad | Estado |
|------|----------|--------|
| Unitarios | - | ✅ |
| Integración | - | ✅ |
| Aceptación | - | ✅ |
| **Total** | **-** | **✅** |

### Complejidad Ciclomática
| Componente | Máximo Permitido | Actual |
|------------|------------------|--------|
| Use Cases | 5 | - |
| Repositories | 10 | - |
| Aggregates | 15 | - |

### Criterios de Aceptación
| Feature | Total | Cubiertos | % |
|---------|-------|-----------|---|
| Catalog | - | - | - |
| Cart | - | - | - |
| Users | - | - | - |

### Últimas Actualizaciones
- **Fecha**: -
- **Tests agregados**: -
- **Cobertura delta**: -
```

### 5.4 Checklist Fase 5

- [ ] Configurar GitHub Actions
- [ ] Implementar pre-commit hooks
- [ ] Crear dashboard de métricas
- [ ] Documentar proceso de contribución
- [ ] Crear templates para PRs
- [ ] Establecer code review checklist
- [ ] Configurar alertas de cobertura
- [ ] Documentar arquitectura final
- [ ] Crear guía de onboarding

---

## Resumen del Plan

| Fase | Duración | Entregables Clave |
|------|----------|-------------------|
| **Fase 1** | 2 semanas | TDD establecido, GetProductsByCategoryUseCase |
| **Fase 2** | 2 semanas | 8+ Value Objects, Product Aggregate, Domain Events |
| **Fase 3** | 2 semanas | Tests ATDD completos, Criterios documentados |
| **Fase 4** | 4 semanas | Cart y User contexts, 11/11 endpoints |
| **Fase 5** | 2 semanas | CI/CD, Métricas, Documentación |

### Métricas Objetivo Final

| Métrica | Actual | Objetivo |
|---------|--------|----------|
| Cobertura | 92.17% | 95%+ |
| Tests | 168 | 300+ |
| Value Objects | 0 | 10+ |
| Aggregates | 1 | 3+ |
| Domain Events | 0 | 5+ |
| Endpoints | 3/11 | 11/11 |
| Bounded Contexts | 1 | 3 |

---

## Próximos Pasos Inmediatos

1. **Hoy**: Crear estructura de carpetas para TDD
2. **Esta semana**: Implementar GetProductsByCategoryUseCase con TDD
3. **Próxima semana**: Comenzar Value Objects (Money, ProductId)

¿Deseas que comience con la implementación de la Fase 1?
