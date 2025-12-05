import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/user/user_remote_datasource_impl.dart';
import 'package:fase_2_consumo_api/src/data/models/user_model.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late UserRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = UserRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('UserRemoteDataSourceImpl', () {
    group('getAll', () {
      test('llama a ApiClient.getList con endpoint correcto', () async {
        // Arrange
        final testUsers = createTestUserModelList(count: 2);
        when(
          mockApiClient.getList(
            endpoint: ApiEndpoints.users,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => testUsers);

        // Act
        await dataSource.getAll();

        // Assert
        verify(
          mockApiClient.getList(
            endpoint: ApiEndpoints.users,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).called(1);
      });

      test('retorna lista de UserModel cuando tiene éxito', () async {
        // Arrange
        final testUsers = createTestUserModelList(count: 3);
        when(
          mockApiClient.getList(
            endpoint: ApiEndpoints.users,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => testUsers);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result, isA<List<UserModel>>());
        expect(result.length, 3);
      });

      test('retorna lista vacía cuando no hay usuarios', () async {
        // Arrange
        when(
          mockApiClient.getList(
            endpoint: ApiEndpoints.users,
            fromJsonList: anyNamed('fromJsonList'),
          ),
        ).thenAnswer((_) async => <UserModel>[]);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getById', () {
      test('llama a ApiClient.get con endpoint correcto', () async {
        // Arrange
        const testId = 1;
        final testUser = createTestUserModel(id: testId);
        when(
          mockApiClient.get(
            endpoint: ApiEndpoints.userById(testId),
            fromJson: anyNamed('fromJson'),
          ),
        ).thenAnswer((_) async => testUser);

        // Act
        await dataSource.getById(testId);

        // Assert
        verify(
          mockApiClient.get(
            endpoint: ApiEndpoints.userById(testId),
            fromJson: anyNamed('fromJson'),
          ),
        ).called(1);
      });

      test('retorna UserModel cuando tiene éxito', () async {
        // Arrange
        const testId = 5;
        final testUser = createTestUserModel(id: testId);
        when(
          mockApiClient.get(
            endpoint: ApiEndpoints.userById(testId),
            fromJson: anyNamed('fromJson'),
          ),
        ).thenAnswer((_) async => testUser);

        // Act
        final result = await dataSource.getById(testId);

        // Assert
        expect(result, isA<UserModel>());
        expect(result.id, testId);
      });

      test('usa el ID correcto en el endpoint', () async {
        // Arrange
        const testId = 42;
        final testUser = createTestUserModel(id: testId);
        when(
          mockApiClient.get(
            endpoint: ApiEndpoints.userById(testId),
            fromJson: anyNamed('fromJson'),
          ),
        ).thenAnswer((_) async => testUser);

        // Act
        await dataSource.getById(testId);

        // Assert
        verify(
          mockApiClient.get(
            endpoint: '/users/$testId',
            fromJson: anyNamed('fromJson'),
          ),
        ).called(1);
      });
    });
  });
}
