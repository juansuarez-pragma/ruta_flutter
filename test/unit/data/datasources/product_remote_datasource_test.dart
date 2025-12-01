import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/product/product_remote_datasource_impl.dart';
import 'package:fase_2_consumo_api/src/data/models/product_model.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProductRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('ProductRemoteDataSourceImpl', () {
    group('getAll', () {
      test('llama a ApiClient.getList con endpoint correcto', () async {
        // Arrange
        final testModels = createTestProductModelList();
        when(
          mockApiClient.getList<ProductModel>(
            endpoint: ApiEndpoints.products,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => testModels);

        // Act
        await dataSource.getAll();

        // Assert
        verify(
          mockApiClient.getList<ProductModel>(
            endpoint: ApiEndpoints.products,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).called(1);
      });

      test('retorna lista de ProductModel desde ApiClient', () async {
        // Arrange
        final testModels = createTestProductModelList(count: 3);
        when(
          mockApiClient.getList<ProductModel>(
            endpoint: anyNamed('endpoint'),
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => testModels);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result, testModels);
        expect(result.length, 3);
      });

      test('propaga excepciones del ApiClient', () async {
        // Arrange
        when(
          mockApiClient.getList<ProductModel>(
            endpoint: anyNamed('endpoint'),
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(() => dataSource.getAll(), throwsA(isA<Exception>()));
      });
    });

    group('getById', () {
      const testId = 42;

      test(
        'llama a ApiClient.get con endpoint correcto incluyendo ID',
        () async {
          // Arrange
          final testModel = createTestProductModel(id: testId);
          when(
            mockApiClient.get<ProductModel>(
              endpoint: ApiEndpoints.productById(testId),
              fromJson: anyNamed('fromJson'),
            ),
          ).thenAnswer((_) async => testModel);

          // Act
          await dataSource.getById(testId);

          // Assert
          verify(
            mockApiClient.get<ProductModel>(
              endpoint: '/products/$testId',
              fromJson: anyNamed('fromJson'),
            ),
          ).called(1);
        },
      );

      test('retorna ProductModel desde ApiClient', () async {
        // Arrange
        final testModel = createTestProductModel(id: testId);
        when(
          mockApiClient.get<ProductModel>(
            endpoint: anyNamed('endpoint'),
            fromJson: anyNamed('fromJson'),
          ),
        ).thenAnswer((_) async => testModel);

        // Act
        final result = await dataSource.getById(testId);

        // Assert
        expect(result, testModel);
        expect(result.id, testId);
      });

      test(
        'construye endpoint dinámico correctamente para diferentes IDs',
        () async {
          // Arrange
          const id1 = 1;
          const id2 = 999;
          final model1 = createTestProductModel(id: id1);
          final model2 = createTestProductModel(id: id2);

          when(
            mockApiClient.get<ProductModel>(
              endpoint: '/products/$id1',
              fromJson: anyNamed('fromJson'),
            ),
          ).thenAnswer((_) async => model1);

          when(
            mockApiClient.get<ProductModel>(
              endpoint: '/products/$id2',
              fromJson: anyNamed('fromJson'),
            ),
          ).thenAnswer((_) async => model2);

          // Act
          await dataSource.getById(id1);
          await dataSource.getById(id2);

          // Assert
          verify(
            mockApiClient.get<ProductModel>(
              endpoint: '/products/$id1',
              fromJson: anyNamed('fromJson'),
            ),
          ).called(1);
          verify(
            mockApiClient.get<ProductModel>(
              endpoint: '/products/$id2',
              fromJson: anyNamed('fromJson'),
            ),
          ).called(1);
        },
      );
    });
  });
}
