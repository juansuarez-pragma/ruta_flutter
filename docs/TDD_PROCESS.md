# Proceso TDD Obligatorio

Este documento define el proceso de Test-Driven Development (TDD) para el proyecto.

## Ciclo Red-Green-Refactor

### 1. RED (Test que falla)

```
□ Escribir especificación formal en comentarios
□ Escribir test ANTES del código de producción
□ Ejecutar test → DEBE FALLAR (compilación o aserción)
□ Commit: "test: add failing test for [feature]"
```

### 2. GREEN (Implementación mínima)

```
□ Escribir código MÍNIMO para pasar el test
□ NO agregar funcionalidad extra
□ NO optimizar prematuramente
□ Ejecutar test → DEBE PASAR
□ Commit: "feat: implement [feature] to pass test"
```

### 3. REFACTOR (Mejorar sin romper)

```
□ Mejorar código manteniendo tests verdes
□ Eliminar duplicación
□ Mejorar nombres y legibilidad
□ Ejecutar TODOS los tests → DEBEN PASAR
□ Commit: "refactor: improve [feature] implementation"
```

## Orden de Implementación TDD por Capas

### 1. Domain Layer (primero - lógica de negocio pura)

```
1.1 Use Case Test    → Use Case Implementation
1.2 Repository Test  → Repository Interface (si es nuevo)
```

### 2. Data Layer (segundo - implementación de contratos)

```
2.1 DataSource Test  → DataSource Implementation
2.2 Repository Test  → Repository Implementation
2.3 Model Test       → Model (fromJson, toEntity)
```

### 3. Presentation Layer (tercero - UI y coordinación)

```
3.1 Application Test → Application updates
3.2 UI Contract Test → UI Implementation
```

## Reglas de Oro TDD

| Regla | Descripción |
|-------|-------------|
| **1** | NUNCA escribir código de producción sin un test que falle |
| **2** | NUNCA escribir más de un test que falle a la vez |
| **3** | NUNCA escribir más código del necesario para pasar el test |
| **4** | Cada ciclo TDD debe completarse en < 10 minutos |
| **5** | Los tests son documentación ejecutable del comportamiento |

## Estructura de un Test TDD

```dart
/// ESPECIFICACIÓN: [NombreComponente]
///
/// Responsabilidad: [Una sola responsabilidad]
///
/// Entrada:
///   - [param1]: [tipo] - [descripción]
///
/// Salida esperada (éxito):
///   - [tipo de retorno y condiciones]
///
/// Salida esperada (error):
///   - [tipos de error y cuándo ocurren]
///
/// Precondiciones:
///   - [condiciones que deben cumplirse antes]
///
/// Postcondiciones:
///   - [efectos después de la ejecución]

void main() {
  group('[NombreComponente]', () {
    // Arrange global
    late ComponenteAProbar sut; // System Under Test
    late MockDependencia mockDep;

    setUp(() {
      mockDep = MockDependencia();
      sut = ComponenteAProbar(mockDep);
    });

    group('cuando [contexto/estado]', () {
      test('debería [comportamiento esperado]', () async {
        // Arrange - Preparar datos específicos
        final testData = createTestData();
        when(mockDep.metodo()).thenAnswer((_) async => testData);

        // Act - Ejecutar acción
        final result = await sut.ejecutar();

        // Assert - Verificar resultado
        expect(result, expectedValue);
        verify(mockDep.metodo()).called(1);
      });
    });
  });
}
```

## Comandos de Desarrollo TDD

```bash
# Ejecutar un test específico (durante desarrollo)
dart test test/unit/domain/usecases/mi_test.dart

# Ejecutar todos los tests
dart test

# Ejecutar tests con verbose
dart test --reporter=expanded

# Ejecutar tests y ver cobertura
dart test --coverage=coverage

# Regenerar mocks después de cambiar interfaces
dart run build_runner build --delete-conflicting-outputs
```

## Checklist Pre-Commit

```
□ dart analyze → 0 errores
□ dart format . → código formateado
□ dart test → todos los tests pasan
□ Cobertura >= 92%
□ Documentación en español agregada
```

## Ejemplo Completo de Ciclo TDD

### Objetivo: Implementar GetProductsByCategoryUseCase

#### Fase RED

```dart
// test/unit/domain/usecases/get_products_by_category_usecase_test.dart

// 1. Escribir test que FALLARÁ (la clase no existe)
test('retorna productos filtrados por categoría', () async {
  // Arrange
  when(mockRepository.getProductsByCategory('electronics'))
      .thenAnswer((_) async => Right(testProducts));

  // Act
  final result = await useCase(CategoryParams(category: 'electronics'));

  // Assert
  expect(result, Right(testProducts));
});
```

Ejecutar: `dart test` → FALLA (clase no existe)

#### Fase GREEN

```dart
// lib/src/domain/usecases/get_products_by_category_usecase.dart

// 2. Implementar código MÍNIMO para pasar
class GetProductsByCategoryUseCase
    implements UseCase<List<ProductEntity>, CategoryParams> {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(CategoryParams params) {
    return repository.getProductsByCategory(params.category);
  }
}
```

Ejecutar: `dart test` → PASA

#### Fase REFACTOR

```dart
// 3. Mejorar sin romper tests
// - Agregar documentación
// - Mejorar nombres si es necesario
// - Verificar que sigue principios SOLID
```

Ejecutar: `dart test` → SIGUE PASANDO
