/// Tests para el método getByCategory de [ProductRemoteDataSource].
///
/// ESPECIFICACIÓN: ProductRemoteDataSource.getByCategory
///
/// Responsabilidad: Obtener productos de una categoría desde la API.
///
/// Entrada:
///   - category: String - nombre de la categoría
///
/// Salida esperada (éxito):
///   - `List<ProductModel>` - lista de productos de esa categoría
///
/// Salida esperada (error):
///   - ServerException: API retorna 5xx
///   - ConnectionException: Error de red
///   - NotFoundException: Categoría no existe (404)
///   - ClientException: Otros errores 4xx
///
/// Precondiciones:
///   - ApiClient disponible e inyectado
///
/// Postcondiciones:
///   - ApiClient.getList() llamado con endpoint correcto
library;

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/data/datasources/product/product_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/datasources/product/product_remote_datasource_impl.dart';
import 'package:fase_2_consumo_api/src/data/models/product_model.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late ProductRemoteDataSource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProductRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('ProductRemoteDataSource.getByCategory', () {
    const testCategory = 'electronics';
    final expectedEndpoint = ApiEndpoints.productsByCategory(testCategory);

    group('cuando la API retorna éxito', () {
      test('retorna lista de ProductModel de la categoría', () async {
        // Arrange
        final testModels = createTestProductModelList(count: 3);
        when(
          mockApiClient.getList(
            endpoint: expectedEndpoint,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => testModels);

        // Act
        final result = await dataSource.getByCategory(testCategory);

        // Assert
        expect(result, equals(testModels));
        expect(result.length, equals(3));
        verify(
          mockApiClient.getList(
            endpoint: expectedEndpoint,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).called(1);
      });

      test('retorna lista vacía cuando no hay productos', () async {
        // Arrange
        when(
          mockApiClient.getList(
            endpoint: expectedEndpoint,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => <ProductModel>[]);

        // Act
        final result = await dataSource.getByCategory(testCategory);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('cuando la API retorna error', () {
      test('propaga ServerException cuando el servidor falla', () async {
        // Arrange
        when(
          mockApiClient.getList(
            endpoint: expectedEndpoint,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenThrow(const ServerException());

        // Act & Assert
        expect(
          () => dataSource.getByCategory(testCategory),
          throwsA(isA<ServerException>()),
        );
      });

      test('propaga ConnectionException cuando hay error de red', () async {
        // Arrange
        when(
          mockApiClient.getList(
            endpoint: expectedEndpoint,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenThrow(
          ConnectionException(uri: Uri.parse('https://api.test.com')),
        );

        // Act & Assert
        expect(
          () => dataSource.getByCategory(testCategory),
          throwsA(isA<ConnectionException>()),
        );
      });

      test('propaga NotFoundException cuando la categoría no existe', () async {
        // Arrange
        when(
          mockApiClient.getList(
            endpoint: ApiEndpoints.productsByCategory('invalid_category'),
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenThrow(const NotFoundException());

        // Act & Assert
        expect(
          () => dataSource.getByCategory('invalid_category'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    test('usa el endpoint correcto para la categoría', () async {
      // Arrange
      const category = "men's clothing";
      final endpoint = ApiEndpoints.productsByCategory(category);

      when(
        mockApiClient.getList(
          endpoint: endpoint,
          fromJsonList: anyNamed('fromJsonList'),
        ),
      ).thenAnswer((_) async => <ProductModel>[]);

      // Act
      await dataSource.getByCategory(category);

      // Assert
      verify(
        mockApiClient.getList(
          endpoint: endpoint,
          fromJsonList: anyNamed('fromJsonList'),
        ),
      ).called(1);
    });
  });
}
