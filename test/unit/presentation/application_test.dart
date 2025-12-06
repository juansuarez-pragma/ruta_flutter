import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_products_by_category_usecase.dart';
import 'package:fase_2_consumo_api/src/presentation/application.dart'
    show ApplicationController;
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

import '../../helpers/mocks.mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late ApplicationController application;
  late MockUserInterface mockUI;
  late MockGetAllProductsUseCase mockGetAllProducts;
  late MockGetProductByIdUseCase mockGetProductById;
  late MockGetAllCategoriesUseCase mockGetAllCategories;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategory;
  late MockGetAllUsersUseCase mockGetAllUsers;
  late MockGetUserByIdUseCase mockGetUserById;
  late MockGetAllCartsUseCase mockGetAllCarts;
  late MockGetCartByIdUseCase mockGetCartById;
  late MockGetCartsByUserUseCase mockGetCartsByUser;
  late bool exitCalled;

  setUp(() {
    mockUI = MockUserInterface();
    mockGetAllProducts = MockGetAllProductsUseCase();
    mockGetProductById = MockGetProductByIdUseCase();
    mockGetAllCategories = MockGetAllCategoriesUseCase();
    mockGetProductsByCategory = MockGetProductsByCategoryUseCase();
    mockGetAllUsers = MockGetAllUsersUseCase();
    mockGetUserById = MockGetUserByIdUseCase();
    mockGetAllCarts = MockGetAllCartsUseCase();
    mockGetCartById = MockGetCartByIdUseCase();
    mockGetCartsByUser = MockGetCartsByUserUseCase();
    exitCalled = false;

    application = ApplicationController(
      ui: mockUI,
      getAllProducts: mockGetAllProducts,
      getProductById: mockGetProductById,
      getAllCategories: mockGetAllCategories,
      getProductsByCategory: mockGetProductsByCategory,
      getAllUsers: mockGetAllUsers,
      getUserById: mockGetUserById,
      getAllCarts: mockGetAllCarts,
      getCartById: mockGetCartById,
      getCartsByUser: mockGetCartsByUser,
      onExit: () => exitCalled = true,
    );
  });

  group('ApplicationController', () {
    group('run', () {
      test('muestra mensaje de bienvenida al iniciar', () async {
        // Arrange
        when(mockUI.showMainMenu()).thenAnswer((_) async => MenuOption.exit);

        // Act
        await application.run();

        // Assert
        verify(mockUI.showWelcome(AppStrings.welcomeMessage)).called(1);
      });

      test('muestra menú después del mensaje de bienvenida', () async {
        // Arrange
        when(mockUI.showMainMenu()).thenAnswer((_) async => MenuOption.exit);

        // Act
        await application.run();

        // Assert
        verify(mockUI.showMainMenu()).called(1);
      });

      test('muestra mensaje de despedida al salir', () async {
        // Arrange
        when(mockUI.showMainMenu()).thenAnswer((_) async => MenuOption.exit);

        // Act
        await application.run();

        // Assert
        verify(mockUI.showGoodbye()).called(1);
      });

      test('llama a onExit al terminar', () async {
        // Arrange
        when(mockUI.showMainMenu()).thenAnswer((_) async => MenuOption.exit);

        // Act
        await application.run();

        // Assert
        expect(exitCalled, isTrue);
      });

      test('muestra error para opción inválida', () async {
        // Arrange
        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.invalid : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.showError(AppStrings.invalidOptionError)).called(1);
      });
    });

    group('getAllProducts', () {
      test('llama al caso de uso y muestra productos en éxito', () async {
        // Arrange
        final testProducts = createTestProductEntityList(count: 3);
        when(
          mockGetAllProducts(const NoParams()),
        ).thenAnswer((_) async => Right(testProducts));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllProducts : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(
          mockUI.showOperationInfo(AppStrings.getAllProductsUseCaseTitle),
        ).called(1);
        verify(mockGetAllProducts(const NoParams())).called(1);
        verify(mockUI.showProducts(testProducts)).called(1);
      });

      test('muestra error cuando el caso de uso falla', () async {
        // Arrange
        final failure = ServerFailure('Error del servidor');
        when(
          mockGetAllProducts(const NoParams()),
        ).thenAnswer((_) async => Left(failure));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllProducts : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.showError(failure.message)).called(1);
      });
    });

    group('getProductById', () {
      test('solicita ID y muestra producto en éxito', () async {
        // Arrange
        const testId = 5;
        final testProduct = createTestProductEntity(id: testId);
        when(mockUI.promptProductId()).thenAnswer((_) async => testId);
        when(
          mockGetProductById(const GetProductByIdParams(id: testId)),
        ).thenAnswer((_) async => Right(testProduct));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getProductById : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.promptProductId()).called(1);
        verify(
          mockGetProductById(const GetProductByIdParams(id: testId)),
        ).called(1);
        verify(mockUI.showProduct(testProduct)).called(1);
      });

      test('muestra error cuando el ID es inválido (null)', () async {
        // Arrange
        when(mockUI.promptProductId()).thenAnswer((_) async => null);

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getProductById : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.showError(AppStrings.invalidIdError)).called(1);
        verifyNever(mockGetProductById(any));
      });

      test('muestra error cuando el caso de uso falla', () async {
        // Arrange
        const testId = 999;
        final failure = NotFoundFailure('Producto no encontrado');
        when(mockUI.promptProductId()).thenAnswer((_) async => testId);
        when(
          mockGetProductById(const GetProductByIdParams(id: testId)),
        ).thenAnswer((_) async => Left(failure));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getProductById : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.showError(failure.message)).called(1);
      });

      test('muestra información de la operación con el ID', () async {
        // Arrange
        const testId = 42;
        final testProduct = createTestProductEntity(id: testId);
        when(mockUI.promptProductId()).thenAnswer((_) async => testId);
        when(
          mockGetProductById(any),
        ).thenAnswer((_) async => Right(testProduct));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getProductById : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(
          mockUI.showOperationInfo(
            '${AppStrings.getProductByIdUseCaseTitle} (ID: $testId)',
          ),
        ).called(1);
      });
    });

    group('getAllCategories', () {
      test('llama al caso de uso y muestra categorías en éxito', () async {
        // Arrange
        final testCategories = createTestCategories();
        when(
          mockGetAllCategories(const NoParams()),
        ).thenAnswer((_) async => Right(testCategories));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllCategories : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(
          mockUI.showOperationInfo(AppStrings.getAllCategoriesUseCaseTitle),
        ).called(1);
        verify(mockGetAllCategories(const NoParams())).called(1);
        verify(mockUI.showCategories(testCategories)).called(1);
      });

      test('muestra error cuando el caso de uso falla', () async {
        // Arrange
        final failure = ConnectionFailure('Sin conexión');
        when(
          mockGetAllCategories(const NoParams()),
        ).thenAnswer((_) async => Left(failure));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? MenuOption.getAllCategories : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.showError(failure.message)).called(1);
      });
    });

    group('getProductsByCategory', () {
      test(
        'obtiene categorías, solicita selección y muestra productos',
        () async {
          // Arrange
          final testCategories = createTestCategories();
          final testProducts = createTestProductEntityList(count: 2);
          const selectedCategory = 'electronics';

          when(
            mockGetAllCategories(const NoParams()),
          ).thenAnswer((_) async => Right(testCategories));
          when(
            mockUI.promptCategory(testCategories),
          ).thenAnswer((_) async => selectedCategory);
          when(
            mockGetProductsByCategory(
              const CategoryParams(category: selectedCategory),
            ),
          ).thenAnswer((_) async => Right(testProducts));

          var callCount = 0;
          when(mockUI.showMainMenu()).thenAnswer((_) async {
            callCount++;
            return callCount == 1
                ? MenuOption.getProductsByCategory
                : MenuOption.exit;
          });

          // Act
          await application.run();

          // Assert
          verify(mockGetAllCategories(const NoParams())).called(1);
          verify(mockUI.promptCategory(testCategories)).called(1);
          verify(
            mockGetProductsByCategory(
              const CategoryParams(category: selectedCategory),
            ),
          ).called(1);
          verify(mockUI.showProducts(testProducts)).called(1);
        },
      );

      test(
        'muestra error cuando la selección de categoría es inválida',
        () async {
          // Arrange
          final testCategories = createTestCategories();

          when(
            mockGetAllCategories(const NoParams()),
          ).thenAnswer((_) async => Right(testCategories));
          when(
            mockUI.promptCategory(testCategories),
          ).thenAnswer((_) async => null);

          var callCount = 0;
          when(mockUI.showMainMenu()).thenAnswer((_) async {
            callCount++;
            return callCount == 1
                ? MenuOption.getProductsByCategory
                : MenuOption.exit;
          });

          // Act
          await application.run();

          // Assert
          verify(mockUI.showError(AppStrings.invalidCategoryError)).called(1);
          verifyNever(mockGetProductsByCategory(any));
        },
      );

      test('muestra error cuando falla obtener categorías', () async {
        // Arrange
        final failure = ConnectionFailure('Sin conexión');

        when(
          mockGetAllCategories(const NoParams()),
        ).thenAnswer((_) async => Left(failure));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          return callCount == 1
              ? MenuOption.getProductsByCategory
              : MenuOption.exit;
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.showError(failure.message)).called(1);
        verifyNever(mockUI.promptCategory(any));
        verifyNever(mockGetProductsByCategory(any));
      });

      test(
        'muestra error cuando falla obtener productos por categoría',
        () async {
          // Arrange
          final testCategories = createTestCategories();
          const selectedCategory = 'electronics';
          final failure = ServerFailure('Error del servidor');

          when(
            mockGetAllCategories(const NoParams()),
          ).thenAnswer((_) async => Right(testCategories));
          when(
            mockUI.promptCategory(testCategories),
          ).thenAnswer((_) async => selectedCategory);
          when(
            mockGetProductsByCategory(
              const CategoryParams(category: selectedCategory),
            ),
          ).thenAnswer((_) async => Left(failure));

          var callCount = 0;
          when(mockUI.showMainMenu()).thenAnswer((_) async {
            callCount++;
            return callCount == 1
                ? MenuOption.getProductsByCategory
                : MenuOption.exit;
          });

          // Act
          await application.run();

          // Assert
          verify(mockUI.showError(failure.message)).called(1);
        },
      );
    });

    group('ciclo del menú', () {
      test('continúa mostrando menú hasta seleccionar exit', () async {
        // Arrange
        final testProducts = createTestProductEntityList();
        final testCategories = createTestCategories();

        when(
          mockGetAllProducts(const NoParams()),
        ).thenAnswer((_) async => Right(testProducts));
        when(
          mockGetAllCategories(const NoParams()),
        ).thenAnswer((_) async => Right(testCategories));

        var callCount = 0;
        when(mockUI.showMainMenu()).thenAnswer((_) async {
          callCount++;
          switch (callCount) {
            case 1:
              return MenuOption.getAllProducts;
            case 2:
              return MenuOption.getAllCategories;
            case 3:
              return MenuOption.exit;
            default:
              return MenuOption.exit;
          }
        });

        // Act
        await application.run();

        // Assert
        verify(mockUI.showMainMenu()).called(3);
        verify(mockGetAllProducts(const NoParams())).called(1);
        verify(mockGetAllCategories(const NoParams())).called(1);
      });
    });
  });
}
