/// Base para tests de aceptación estilo Gherkin.
///
/// Proporciona una estructura BDD (Behavior-Driven Development) para
/// escribir tests de aceptación legibles y mantenibles.
///
/// IMPORTANTE: Usar gherkinWhen en lugar de when para evitar conflictos con mockito.
///
/// Ejemplo de uso:
/// ```dart
/// feature('Visualización de productos', () {
///   scenario('Usuario ve lista de productos', () {
///     given('el usuario está en la aplicación', () {
///       // Setup
///     });
///     gherkinWhen('solicita ver todos los productos', () {
///       // Action
///     });
///     then('ve una lista de productos disponibles', () {
///       // Assertion
///     });
///   });
/// });
/// ```
library;

import 'package:test/test.dart';

/// Define una característica (Feature) en formato Gherkin.
///
/// Agrupa escenarios relacionados bajo un contexto común.
void feature(String description, void Function() body) {
  group('Feature: $description', body);
}

/// Define un escenario (Scenario) dentro de una característica.
///
/// Representa un caso de uso específico con sus pasos Given-When-Then.
void scenario(String description, void Function() body) {
  group('Scenario: $description', body);
}

/// Define el contexto inicial (Given) del escenario.
///
/// Establece las precondiciones necesarias para el test.
void given(String description, dynamic Function() body) {
  test('Given $description', body);
}

/// Define la acción (When) que se ejecuta en el escenario.
///
/// Representa la acción del usuario o del sistema bajo prueba.
/// NOTA: Usar gherkinWhen en lugar de when para evitar conflictos con mockito.
void gherkinWhen(String description, dynamic Function() body) {
  test('When $description', body);
}

/// Define el resultado esperado (Then) del escenario.
///
/// Verifica que el sistema se comporta como se espera.
void then(String description, dynamic Function() body) {
  test('Then $description', body);
}

/// Define un paso adicional (And) que complementa Given, When o Then.
void and(String description, dynamic Function() body) {
  test('And $description', body);
}

/// Define un paso alternativo (But) que complementa Then.
void but(String description, dynamic Function() body) {
  test('But $description', body);
}

/// Clase para construir escenarios de aceptación de forma fluida.
///
/// Permite encadenar pasos Given-When-Then manteniendo estado compartido.
class AcceptanceScenario<TContext> {
  final TContext context;
  final List<String> _steps = [];

  AcceptanceScenario(this.context);

  /// Registra un paso Given.
  AcceptanceScenario<TContext> given(
    String description,
    void Function(TContext) action,
  ) {
    _steps.add('Given $description');
    action(context);
    return this;
  }

  /// Registra un paso When.
  AcceptanceScenario<TContext> whenStep(
    String description,
    void Function(TContext) action,
  ) {
    _steps.add('When $description');
    action(context);
    return this;
  }

  /// Registra un paso Then.
  AcceptanceScenario<TContext> then(
    String description,
    void Function(TContext) assertion,
  ) {
    _steps.add('Then $description');
    assertion(context);
    return this;
  }

  /// Registra un paso And.
  AcceptanceScenario<TContext> and(
    String description,
    void Function(TContext) action,
  ) {
    _steps.add('And $description');
    action(context);
    return this;
  }

  /// Obtiene los pasos ejecutados para depuración.
  List<String> get steps => List.unmodifiable(_steps);
}
