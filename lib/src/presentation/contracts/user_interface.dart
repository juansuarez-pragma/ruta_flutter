import 'package:fase_2_consumo_api/src/presentation/contracts/category_output.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/message_output.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/product_output.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/user_input.dart';

/// Puerto (Port) que combina todos los contratos de UI necesarios.
///
/// Este patrón permite intercambiar la implementación de UI (consola, GUI,
/// web, móvil) sin afectar la lógica de negocio. Cada plataforma implementa
/// estos contratos según sus capacidades.
///
/// Basado en el patrón Ports and Adapters (Hexagonal Architecture)
/// aplicando Interface Segregation Principle (ISP).
abstract class UserInterface
    implements UserInput, MessageOutput, ProductOutput, CategoryOutput {}
