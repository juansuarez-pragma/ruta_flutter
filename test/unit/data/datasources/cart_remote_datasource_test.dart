import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/cart/cart_remote_datasource_impl.dart';
import 'package:fase_2_consumo_api/src/data/models/cart_model.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late CartRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = CartRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('CartRemoteDataSourceImpl', () {
    group('getAll', () {
      test('llama a ApiClient.getList con endpoint correcto', () async {
        // Arrange
        final testModels = createTestCartModelList();
        when(
          mockApiClient.getList<CartModel>(
            endpoint: ApiEndpoints.carts,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => testModels);

        // Act
        await dataSource.getAll();

        // Assert
        verify(
          mockApiClient.getList<CartModel>(
            endpoint: ApiEndpoints.carts,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).called(1);
      });

      test('retorna lista de CartModel desde ApiClient', () async {
        // Arrange
        final testModels = createTestCartModelList(count: 3);
        when(
          mockApiClient.getList<CartModel>(
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
          mockApiClient.getList<CartModel>(
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
          final testModel = createTestCartModel(id: testId);
          when(
            mockApiClient.get<CartModel>(
              endpoint: ApiEndpoints.cartById(testId),
              fromJson: anyNamed('fromJson'),
            ),
          ).thenAnswer((_) async => testModel);

          // Act
          await dataSource.getById(testId);

          // Assert
          verify(
            mockApiClient.get<CartModel>(
              endpoint: '/carts/$testId',
              fromJson: anyNamed('fromJson'),
            ),
          ).called(1);
        },
      );

      test('retorna CartModel desde ApiClient', () async {
        // Arrange
        final testModel = createTestCartModel(id: testId);
        when(
          mockApiClient.get<CartModel>(
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
    });

    group('getByUser', () {
      const testUserId = 5;

      test(
        'llama a ApiClient.getList con endpoint correcto incluyendo userId',
        () async {
          // Arrange
          final testModels = createTestCartModelList();
          when(
            mockApiClient.getList<CartModel>(
              endpoint: ApiEndpoints.cartsByUser(testUserId),
              fromJsonList: anyNamed('fromJsonList'),
            ),
          ).thenAnswer((_) async => testModels);

          // Act
          await dataSource.getByUser(testUserId);

          // Assert
          verify(
            mockApiClient.getList<CartModel>(
              endpoint: '/carts/user/$testUserId',
              fromJsonList: anyNamed('fromJsonList'),
            ),
          ).called(1);
        },
      );

      test('retorna lista de CartModel desde ApiClient', () async {
        // Arrange
        final testModels = createTestCartModelList(count: 2);
        when(
          mockApiClient.getList<CartModel>(
            endpoint: anyNamed('endpoint'),
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => testModels);

        // Act
        final result = await dataSource.getByUser(testUserId);

        // Assert
        expect(result, testModels);
        expect(result.length, 2);
      });
    });
  });
}
