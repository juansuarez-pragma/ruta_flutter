import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/repositories/cart_repository_impl.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late CartRepositoryImpl repository;
  late MockCartRemoteDataSource mockCartDataSource;

  setUp(() {
    mockCartDataSource = MockCartRemoteDataSource();
    repository = CartRepositoryImpl(cartDataSource: mockCartDataSource);
  });

  group('CartRepositoryImpl', () {
    group('getAllCarts', () {
      test(
        'retorna Right con lista de carritos cuando datasource tiene éxito',
        () async {
          // Arrange
          final testModels = createTestCartModelList(count: 3);
          when(mockCartDataSource.getAll()).thenAnswer((_) async => testModels);

          // Act
          final result = await repository.getAllCarts();

          // Assert
          expect(result.isRight(), isTrue);
          result.fold((failure) => fail('No debería retornar failure'), (
            carts,
          ) {
            expect(carts.length, 3);
            expect(carts[0].id, testModels[0].id);
            expect(carts[0].userId, testModels[0].userId);
          });
          verify(mockCartDataSource.getAll()).called(1);
        },
      );

      test(
        'retorna Left ServerFailure cuando datasource lanza ServerException',
        () async {
          // Arrange
          when(mockCartDataSource.getAll()).thenThrow(ServerException());

          // Act
          final result = await repository.getAllCarts();

          // Assert
          expect(result, Left(ServerFailure(AppStrings.serverFailureMessage)));
        },
      );

      test(
        'retorna Left ConnectionFailure cuando datasource lanza ConnectionException',
        () async {
          // Arrange
          when(mockCartDataSource.getAll()).thenThrow(
            ConnectionException(
              uri: Uri.parse('https://api.test.com'),
              originalError: 'Connection refused',
            ),
          );

          // Act
          final result = await repository.getAllCarts();

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ConnectionFailure>()),
            (_) => fail('No debería retornar Right'),
          );
        },
      );

      test('convierte modelos a entidades correctamente', () async {
        // Arrange
        final testModels = createTestCartModelList(count: 2);
        when(mockCartDataSource.getAll()).thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getAllCarts();

        // Assert
        result.fold((failure) => fail('No debería retornar failure'), (carts) {
          for (var i = 0; i < carts.length; i++) {
            expect(carts[i].id, testModels[i].id);
            expect(carts[i].userId, testModels[i].userId);
            expect(carts[i].date, testModels[i].date);
          }
        });
      });
    });

    group('getCartById', () {
      const testId = 1;

      test(
        'retorna Right con carrito cuando datasource tiene éxito',
        () async {
          // Arrange
          final testModel = createTestCartModel(id: testId);
          when(
            mockCartDataSource.getById(testId),
          ).thenAnswer((_) async => testModel);

          // Act
          final result = await repository.getCartById(testId);

          // Assert
          expect(result.isRight(), isTrue);
          result.fold((failure) => fail('No debería retornar failure'), (cart) {
            expect(cart.id, testId);
            expect(cart.userId, testModel.userId);
          });
          verify(mockCartDataSource.getById(testId)).called(1);
        },
      );

      test(
        'retorna Left NotFoundFailure cuando datasource lanza NotFoundException',
        () async {
          // Arrange
          when(mockCartDataSource.getById(testId)).thenThrow(NotFoundException());

          // Act
          final result = await repository.getCartById(testId);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<NotFoundFailure>());
            expect(failure.message, AppStrings.notFoundCartFailureMessage);
          }, (_) => fail('No debería retornar Right'));
        },
      );

      test(
        'retorna Left ServerFailure cuando datasource lanza ServerException',
        () async {
          // Arrange
          when(mockCartDataSource.getById(testId)).thenThrow(ServerException());

          // Act
          final result = await repository.getCartById(testId);

          // Assert
          expect(result, Left(ServerFailure(AppStrings.serverFailureMessage)));
        },
      );

      test('pasa el ID correcto al datasource', () async {
        // Arrange
        const specificId = 42;
        final testModel = createTestCartModel(id: specificId);
        when(
          mockCartDataSource.getById(specificId),
        ).thenAnswer((_) async => testModel);

        // Act
        await repository.getCartById(specificId);

        // Assert
        verify(mockCartDataSource.getById(specificId)).called(1);
      });
    });

    group('getCartsByUser', () {
      const testUserId = 1;

      test(
        'retorna Right con lista de carritos del usuario cuando datasource tiene éxito',
        () async {
          // Arrange
          final testModels = createTestCartModelList(count: 2);
          when(
            mockCartDataSource.getByUser(testUserId),
          ).thenAnswer((_) async => testModels);

          // Act
          final result = await repository.getCartsByUser(testUserId);

          // Assert
          expect(result.isRight(), isTrue);
          result.fold((failure) => fail('No debería retornar failure'), (
            carts,
          ) {
            expect(carts.length, 2);
          });
          verify(mockCartDataSource.getByUser(testUserId)).called(1);
        },
      );

      test(
        'retorna Left ServerFailure cuando datasource lanza ServerException',
        () async {
          // Arrange
          when(
            mockCartDataSource.getByUser(testUserId),
          ).thenThrow(ServerException());

          // Act
          final result = await repository.getCartsByUser(testUserId);

          // Assert
          expect(result, Left(ServerFailure(AppStrings.serverFailureMessage)));
        },
      );

      test('retorna lista vacía cuando el usuario no tiene carritos', () async {
        // Arrange
        when(
          mockCartDataSource.getByUser(testUserId),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getCartsByUser(testUserId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (carts) => expect(carts, isEmpty),
        );
      });

      test('pasa el userId correcto al datasource', () async {
        // Arrange
        const specificUserId = 5;
        final testModels = createTestCartModelList();
        when(
          mockCartDataSource.getByUser(specificUserId),
        ).thenAnswer((_) async => testModels);

        // Act
        await repository.getCartsByUser(specificUserId);

        // Assert
        verify(mockCartDataSource.getByUser(specificUserId)).called(1);
      });
    });
  });
}
