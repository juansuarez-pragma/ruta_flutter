import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/repositories/user_repository_impl.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late UserRepositoryImpl repository;
  late MockUserRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockUserRemoteDataSource();
    repository = UserRepositoryImpl(userDataSource: mockDataSource);
  });

  group('UserRepositoryImpl', () {
    group('getAllUsers', () {
      test('retorna lista de UserEntity cuando el datasource tiene éxito', () async {
        // Arrange
        final testModels = createTestUserModelList(count: 3);
        when(mockDataSource.getAll()).thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getAllUsers();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (users) {
            expect(users, isA<List<UserEntity>>());
            expect(users.length, 3);
          },
        );
        verify(mockDataSource.getAll()).called(1);
      });

      test('retorna ServerFailure cuando el datasource lanza ServerException', () async {
        // Arrange
        when(mockDataSource.getAll()).thenThrow(ServerException());

        // Act
        final result = await repository.getAllUsers();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('No debería retornar éxito'),
        );
      });

      test('retorna ConnectionFailure cuando el datasource lanza ConnectionException', () async {
        // Arrange
        when(mockDataSource.getAll()).thenThrow(ConnectionException());

        // Act
        final result = await repository.getAllUsers();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('No debería retornar éxito'),
        );
      });

      test('retorna lista vacía cuando el datasource retorna lista vacía', () async {
        // Arrange
        when(mockDataSource.getAll()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllUsers();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (users) => expect(users, isEmpty),
        );
      });

      test('convierte correctamente modelos a entidades', () async {
        // Arrange
        final testModels = createTestUserModelList(count: 2);
        when(mockDataSource.getAll()).thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getAllUsers();

        // Assert
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (users) {
            expect(users[0].id, testModels[0].id);
            expect(users[0].email, testModels[0].email);
            expect(users[0].username, testModels[0].username);
          },
        );
      });
    });

    group('getUserById', () {
      test('retorna UserEntity cuando el datasource tiene éxito', () async {
        // Arrange
        const testId = 1;
        final testModel = createTestUserModel(id: testId);
        when(mockDataSource.getById(testId)).thenAnswer((_) async => testModel);

        // Act
        final result = await repository.getUserById(testId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (user) {
            expect(user, isA<UserEntity>());
            expect(user.id, testId);
          },
        );
        verify(mockDataSource.getById(testId)).called(1);
      });

      test('retorna NotFoundFailure cuando el datasource lanza NotFoundException', () async {
        // Arrange
        const testId = 999;
        when(mockDataSource.getById(testId)).thenThrow(NotFoundException());

        // Act
        final result = await repository.getUserById(testId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (_) => fail('No debería retornar éxito'),
        );
      });

      test('retorna ServerFailure cuando el datasource lanza ServerException', () async {
        // Arrange
        const testId = 1;
        when(mockDataSource.getById(testId)).thenThrow(ServerException());

        // Act
        final result = await repository.getUserById(testId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('No debería retornar éxito'),
        );
      });

      test('retorna ConnectionFailure cuando el datasource lanza ConnectionException', () async {
        // Arrange
        const testId = 1;
        when(mockDataSource.getById(testId)).thenThrow(ConnectionException());

        // Act
        final result = await repository.getUserById(testId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('No debería retornar éxito'),
        );
      });

      test('pasa el ID correcto al datasource', () async {
        // Arrange
        const testId = 42;
        final testModel = createTestUserModel(id: testId);
        when(mockDataSource.getById(testId)).thenAnswer((_) async => testModel);

        // Act
        await repository.getUserById(testId);

        // Assert
        verify(mockDataSource.getById(testId)).called(1);
      });

      test('convierte correctamente modelo a entidad', () async {
        // Arrange
        const testId = 5;
        final testModel = createTestUserModel(
          id: testId,
          email: 'test@example.com',
          username: 'testuser',
        );
        when(mockDataSource.getById(testId)).thenAnswer((_) async => testModel);

        // Act
        final result = await repository.getUserById(testId);

        // Assert
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (user) {
            expect(user.id, testModel.id);
            expect(user.email, testModel.email);
            expect(user.username, testModel.username);
            expect(user.name.firstname, testModel.name.firstname);
            expect(user.address.city, testModel.address.city);
          },
        );
      });
    });
  });
}
