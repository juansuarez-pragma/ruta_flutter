import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/category/category_remote_datasource_impl.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late CategoryRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = CategoryRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('CategoryRemoteDataSourceImpl', () {
    group('getAll', () {
      test('llama a ApiClient.getPrimitiveList con endpoint correcto', () async {
        // Arrange
        final testCategories = createTestCategories();
        when(mockApiClient.getPrimitiveList<String>(
          endpoint: ApiEndpoints.categories,
        )).thenAnswer((_) async => testCategories);

        // Act
        await dataSource.getAll();

        // Assert
        verify(mockApiClient.getPrimitiveList<String>(
          endpoint: ApiEndpoints.categories,
        )).called(1);
      });

      test('retorna lista de strings desde ApiClient', () async {
        // Arrange
        final testCategories = createTestCategories();
        when(mockApiClient.getPrimitiveList<String>(
          endpoint: anyNamed('endpoint'),
        )).thenAnswer((_) async => testCategories);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result, testCategories);
        expect(result, contains('electronics'));
        expect(result, contains('jewelery'));
      });

      test('retorna lista vacía cuando no hay categorías', () async {
        // Arrange
        when(mockApiClient.getPrimitiveList<String>(
          endpoint: anyNamed('endpoint'),
        )).thenAnswer((_) async => <String>[]);

        // Act
        final result = await dataSource.getAll();

        // Assert
        expect(result, isEmpty);
      });

      test('propaga excepciones del ApiClient', () async {
        // Arrange
        when(mockApiClient.getPrimitiveList<String>(
          endpoint: anyNamed('endpoint'),
        )).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => dataSource.getAll(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
