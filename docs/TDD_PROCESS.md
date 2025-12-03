# Proceso TDD

## Ciclo Red-Green-Refactor

```
RED     → Escribir test que FALLA (código no existe)
GREEN   → Escribir código MÍNIMO para pasar
REFACTOR → Mejorar sin romper tests
```

## Orden por Capas

1. **Domain**: UseCase Test → Implementación → Repository interface
2. **Data**: DataSource Test → Repository Test → Implementaciones
3. **Presentation**: ApplicationController Test → Integración UI

## Reglas

| # | Regla |
|---|-------|
| 1 | NUNCA código sin test que falle primero |
| 2 | UN solo test fallando a la vez |
| 3 | Código MÍNIMO para pasar el test |
| 4 | Ciclo completo en < 10 minutos |

## Estructura de Test

```dart
group('[Componente]', () {
  late ComponenteAProbar sut;
  late MockDependencia mockDep;

  setUp(() {
    mockDep = MockDependencia();
    sut = ComponenteAProbar(mockDep);
  });

  test('debería [comportamiento]', () async {
    // Arrange
    when(mockDep.metodo()).thenAnswer((_) async => testData);
    // Act
    final result = await sut.ejecutar();
    // Assert
    expect(result, expectedValue);
    verify(mockDep.metodo()).called(1);
  });
});
```

## Comandos

```bash
dart test test/ruta/test.dart   # Test específico
dart test                        # Todos los tests
dart run build_runner build      # Regenerar mocks
```
