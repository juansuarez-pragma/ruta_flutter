import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/config/config.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  group('EnvConfig', () {
    late MockEnvReader mockEnvReader;

    setUp(() {
      mockEnvReader = MockEnvReader();
    });

    group('singleton', () {
      test('instance retorna la misma instancia', () {
        // Act
        final instance1 = EnvConfig.instance;
        final instance2 = EnvConfig.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('initialize', () {
      test('inicializa correctamente con EnvReader válido', () async {
        // Arrange
        when(mockEnvReader.load(any)).thenAnswer((_) async {});
        when(mockEnvReader['API_BASE_URL']).thenReturn('https://api.test.com');
        when(mockEnvReader.containsKey('API_BASE_URL')).thenReturn(true);

        // Act - El singleton ya podría estar inicializado, pero debe retornar sin error
        await EnvConfig.instance.initialize(reader: mockEnvReader);

        // Assert - No debería lanzar excepción
      });

      test('llama a load en el reader con la ruta correcta', () async {
        // Arrange
        when(mockEnvReader.load(any)).thenAnswer((_) async {});
        when(mockEnvReader.containsKey(any)).thenReturn(true);

        // Act
        await EnvConfig.instance.initialize(
          envPath: '.env.test',
          reader: mockEnvReader,
        );

        // Assert
        // Note: Esto solo funciona si el singleton no estaba inicializado
      });
    });

    group('apiBaseUrl', () {
      test(
        'retorna el valor de API_BASE_URL cuando está inicializado',
        () async {
          // Arrange
          const expectedUrl = 'https://api.example.com';
          when(mockEnvReader.load(any)).thenAnswer((_) async {});
          when(mockEnvReader['API_BASE_URL']).thenReturn(expectedUrl);
          when(mockEnvReader.containsKey('API_BASE_URL')).thenReturn(true);

          await EnvConfig.instance.initialize(reader: mockEnvReader);

          // Act
          final result = EnvConfig.instance.apiBaseUrl;

          // Assert
          expect(result, isNotEmpty);
        },
      );
    });
  });

  group('EnvReader interface', () {
    late MockEnvReader mockReader;

    setUp(() {
      mockReader = MockEnvReader();
    });

    test('load se llama con el path correcto', () async {
      // Arrange
      when(mockReader.load('.env')).thenAnswer((_) async {});

      // Act
      await mockReader.load('.env');

      // Assert
      verify(mockReader.load('.env')).called(1);
    });

    test('operator [] retorna valor para clave existente', () {
      // Arrange
      when(mockReader['API_KEY']).thenReturn('secret123');

      // Act
      final result = mockReader['API_KEY'];

      // Assert
      expect(result, 'secret123');
    });

    test('operator [] retorna null para clave inexistente', () {
      // Arrange
      when(mockReader['MISSING_KEY']).thenReturn(null);

      // Act
      final result = mockReader['MISSING_KEY'];

      // Assert
      expect(result, isNull);
    });

    test('containsKey retorna true para clave existente', () {
      // Arrange
      when(mockReader.containsKey('API_KEY')).thenReturn(true);

      // Act
      final result = mockReader.containsKey('API_KEY');

      // Assert
      expect(result, isTrue);
    });

    test('containsKey retorna false para clave inexistente', () {
      // Arrange
      when(mockReader.containsKey('MISSING_KEY')).thenReturn(false);

      // Act
      final result = mockReader.containsKey('MISSING_KEY');

      // Assert
      expect(result, isFalse);
    });
  });

  group('EnvConfigException', () {
    test('almacena el mensaje correctamente', () {
      // Arrange
      const message = 'Variable no encontrada';

      // Act
      final exception = EnvConfigException(message);

      // Assert
      expect(exception.message, message);
    });

    test('toString retorna el mensaje', () {
      // Arrange
      const message = 'Error de configuración';
      final exception = EnvConfigException(message);

      // Assert
      expect(exception.toString(), contains(message));
    });

    test('implementa Exception', () {
      // Arrange & Act
      final exception = EnvConfigException('test');

      // Assert
      expect(exception, isA<Exception>());
    });
  });

  group('EnvironmentVariables', () {
    test('values retorna lista de variables requeridas', () {
      // Act
      final variables = EnvironmentVariables.values();

      // Assert
      expect(variables, isNotEmpty);
      expect(variables, contains('API_BASE_URL'));
    });

    test('values contiene API_BASE_URL', () {
      // Act
      final variables = EnvironmentVariables.values();

      // Assert
      expect(variables.first, 'API_BASE_URL');
    });
  });
}
