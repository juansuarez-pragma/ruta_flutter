import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_cart_by_id_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetCartByIdUseCase useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = GetCartByIdUseCase(mockRepository);
  });

  group('GetCartByIdUseCase', () {
    const testId = 1;

    test(
      'retorna carrito cuando el repositorio tiene éxito',
      () async {
        // Arrange
        final testCart = createTestCartEntity(id: testId);
        when(
          mockRepository.getCartById(testId),
        ).thenAnswer((_) async => Right(testCart));

        // Act
        final result = await useCase(const GetCartByIdParams(id: testId));

        // Assert
        expect(result, Right(testCart));
        verify(mockRepository.getCartById(testId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = ServerFailure('Error del servidor');
      when(
        mockRepository.getCartById(testId),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const GetCartByIdParams(id: testId));

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getCartById(testId)).called(1);
    });

    test('retorna NotFoundFailure cuando el carrito no existe', () async {
      // Arrange
      final failure = NotFoundFailure('Carrito no encontrado');
      when(
        mockRepository.getCartById(testId),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const GetCartByIdParams(id: testId));

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('No debería retornar éxito'),
      );
    });
  });

  group('GetCartByIdParams', () {
    test('dos instancias con mismo id son iguales', () {
      // Arrange & Act
      const params1 = GetCartByIdParams(id: 1);
      const params2 = GetCartByIdParams(id: 1);

      // Assert
      expect(params1, equals(params2));
    });

    test('dos instancias con diferente id no son iguales', () {
      // Arrange & Act
      const params1 = GetCartByIdParams(id: 1);
      const params2 = GetCartByIdParams(id: 2);

      // Assert
      expect(params1, isNot(equals(params2)));
    });

    test('props contiene el id', () {
      // Arrange
      const params = GetCartByIdParams(id: 1);

      // Assert
      expect(params.props, equals([1]));
    });
  });
}
