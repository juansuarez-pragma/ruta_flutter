import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/config/env_config.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/data/datasources/core/api_client_impl.dart';

import '../../../fixtures/product_fixtures.dart';
import '../../../helpers/mocks.mocks.dart';

void main() {
  late ApiClientImpl apiClient;
  late MockClient mockHttpClient;
  late MockApiResponseHandler mockResponseHandler;
  late MockEnvReader mockEnvReader;

  const testBaseUrl = 'https://api.test.com';
  const testEndpoint = '/products';

  setUp(() async {
    mockHttpClient = MockClient();
    mockResponseHandler = MockApiResponseHandler();
    mockEnvReader = MockEnvReader();

    // Configurar mock de EnvReader
    when(mockEnvReader.load(any)).thenAnswer((_) async {});
    when(mockEnvReader['API_BASE_URL']).thenReturn(testBaseUrl);
    when(mockEnvReader.containsKey('API_BASE_URL')).thenReturn(true);

    // Inicializar EnvConfig con el mock
    await EnvConfig.instance.initialize(reader: mockEnvReader);

    apiClient = ApiClientImpl(
      client: mockHttpClient,
      responseHandler: mockResponseHandler,
    );
  });

  group('ApiClientImpl', () {
    group('get', () {
      test('retorna objeto parseado cuando la respuesta es 200', () async {
        // Arrange
        final responseBody = json.encode(validProductJson);
        when(
          mockHttpClient.get(Uri.parse('$testBaseUrl$testEndpoint')),
        ).thenAnswer((_) async => http.Response(responseBody, 200));
        when(mockResponseHandler.handleResponse(any)).thenReturn(null);

        // Act
        final result = await apiClient.get<Map<String, dynamic>>(
          endpoint: testEndpoint,
          fromJson: (json) => json as Map<String, dynamic>,
        );

        // Assert
        expect(result['id'], 1);
        expect(result['title'], 'Producto de prueba');
        verify(
          mockHttpClient.get(Uri.parse('$testBaseUrl$testEndpoint')),
        ).called(1);
      });

      test('llama a handleResponse con la respuesta HTTP', () async {
        // Arrange
        final response = http.Response('{}', 200);
        when(mockHttpClient.get(any)).thenAnswer((_) async => response);
        when(mockResponseHandler.handleResponse(any)).thenReturn(null);

        // Act
        await apiClient.get<Map<String, dynamic>>(
          endpoint: testEndpoint,
          fromJson: (json) => json as Map<String, dynamic>,
        );

        // Assert
        verify(mockResponseHandler.handleResponse(any)).called(1);
      });

      test('propaga ServerException cuando handleResponse la lanza', () async {
        // Arrange
        when(
          mockHttpClient.get(any),
        ).thenAnswer((_) async => http.Response('Error', 500));
        when(
          mockResponseHandler.handleResponse(any),
        ).thenThrow(ServerException());

        // Act & Assert
        expect(
          () => apiClient.get<Map<String, dynamic>>(
            endpoint: testEndpoint,
            fromJson: (json) => json as Map<String, dynamic>,
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test(
        'propaga NotFoundException cuando handleResponse la lanza',
        () async {
          // Arrange
          when(
            mockHttpClient.get(any),
          ).thenAnswer((_) async => http.Response('Not Found', 404));
          when(
            mockResponseHandler.handleResponse(any),
          ).thenThrow(NotFoundException());

          // Act & Assert
          expect(
            () => apiClient.get<Map<String, dynamic>>(
              endpoint: testEndpoint,
              fromJson: (json) => json as Map<String, dynamic>,
            ),
            throwsA(isA<NotFoundException>()),
          );
        },
      );

      test('lanza ConnectionException cuando hay error de red', () async {
        // Arrange
        when(
          mockHttpClient.get(any),
        ).thenThrow(http.ClientException('Connection refused'));

        // Act & Assert
        expect(
          () => apiClient.get<Map<String, dynamic>>(
            endpoint: testEndpoint,
            fromJson: (json) => json as Map<String, dynamic>,
          ),
          throwsA(isA<ConnectionException>()),
        );
      });
    });

    group('getList', () {
      test(
        'retorna lista de objetos parseados cuando la respuesta es 200',
        () async {
          // Arrange
          final responseBody = json.encode(validProductListJson);
          when(
            mockHttpClient.get(Uri.parse('$testBaseUrl$testEndpoint')),
          ).thenAnswer((_) async => http.Response(responseBody, 200));
          when(mockResponseHandler.handleResponse(any)).thenReturn(null);

          // Act
          final result = await apiClient.getList<Map<String, dynamic>>(
            endpoint: testEndpoint,
            fromJsonList: (json) => json,
          );

          // Assert
          expect(result.length, 2);
          expect(result[0]['id'], 1);
          expect(result[1]['id'], 2);
        },
      );

      test(
        'retorna lista vacía cuando la respuesta es un array vacío',
        () async {
          // Arrange
          when(
            mockHttpClient.get(any),
          ).thenAnswer((_) async => http.Response('[]', 200));
          when(mockResponseHandler.handleResponse(any)).thenReturn(null);

          // Act
          final result = await apiClient.getList<Map<String, dynamic>>(
            endpoint: testEndpoint,
            fromJsonList: (json) => json,
          );

          // Assert
          expect(result, isEmpty);
        },
      );

      test('lanza ConnectionException cuando hay error de red', () async {
        // Arrange
        when(
          mockHttpClient.get(any),
        ).thenThrow(http.ClientException('Network error'));

        // Act & Assert
        expect(
          () => apiClient.getList<Map<String, dynamic>>(
            endpoint: testEndpoint,
            fromJsonList: (json) => json,
          ),
          throwsA(isA<ConnectionException>()),
        );
      });
    });

    group('getPrimitiveList', () {
      test('retorna lista de strings cuando la respuesta es 200', () async {
        // Arrange
        final responseBody = json.encode(validCategoriesList);
        when(
          mockHttpClient.get(Uri.parse('$testBaseUrl$testEndpoint')),
        ).thenAnswer((_) async => http.Response(responseBody, 200));
        when(mockResponseHandler.handleResponse(any)).thenReturn(null);

        // Act
        final result = await apiClient.getPrimitiveList<String>(
          endpoint: testEndpoint,
        );

        // Assert
        expect(result.length, 4);
        expect(result, contains('electronics'));
        expect(result, contains('jewelery'));
      });

      test(
        'retorna lista vacía cuando la respuesta es un array vacío',
        () async {
          // Arrange
          when(
            mockHttpClient.get(any),
          ).thenAnswer((_) async => http.Response('[]', 200));
          when(mockResponseHandler.handleResponse(any)).thenReturn(null);

          // Act
          final result = await apiClient.getPrimitiveList<String>(
            endpoint: testEndpoint,
          );

          // Assert
          expect(result, isEmpty);
        },
      );

      test('lanza ConnectionException cuando hay error de red', () async {
        // Arrange
        when(
          mockHttpClient.get(any),
        ).thenThrow(http.ClientException('Connection timeout'));

        // Act & Assert
        expect(
          () => apiClient.getPrimitiveList<String>(endpoint: testEndpoint),
          throwsA(isA<ConnectionException>()),
        );
      });
    });

    group('URL construction', () {
      test(
        'construye URL correctamente combinando baseUrl y endpoint',
        () async {
          // Arrange
          when(
            mockHttpClient.get(any),
          ).thenAnswer((_) async => http.Response('{}', 200));
          when(mockResponseHandler.handleResponse(any)).thenReturn(null);

          // Act
          await apiClient.get<Map<String, dynamic>>(
            endpoint: '/products/123',
            fromJson: (json) => json as Map<String, dynamic>,
          );

          // Assert
          verify(
            mockHttpClient.get(Uri.parse('$testBaseUrl/products/123')),
          ).called(1);
        },
      );
    });
  });
}
