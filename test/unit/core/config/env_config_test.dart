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
