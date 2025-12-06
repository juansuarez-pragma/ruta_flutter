import 'package:fase_2_consumo_api/src/domain/entities/cart_product_entity.dart';

/// Modelo de datos para un producto dentro de un carrito.
///
/// Maneja la serialización/deserialización de JSON y la conversión
/// a la entidad de dominio [CartProductEntity].
class CartProductModel {
  final int productId;
  final int quantity;

  const CartProductModel({
    required this.productId,
    required this.quantity,
  });

  /// Crea un [CartProductModel] a partir de un mapa JSON.
  ///
  /// Implementa validación defensiva según recomendaciones de seguridad:
  /// - Valida que productId existe y es un entero positivo
  /// - Valida que quantity existe y es un entero positivo
  ///
  /// Lanza [FormatException] si los datos son inválidos.
  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    final productId = json['productId'];
    final quantity = json['quantity'];

    if (productId == null || productId is! int || productId <= 0) {
      throw FormatException('productId inválido o faltante: $productId');
    }

    if (quantity == null || quantity is! int || quantity <= 0) {
      throw FormatException('quantity inválido o faltante: $quantity');
    }

    return CartProductModel(
      productId: productId,
      quantity: quantity,
    );
  }

  /// Convierte este modelo a una entidad de dominio.
  CartProductEntity toEntity() {
    return CartProductEntity(
      productId: productId,
      quantity: quantity,
    );
  }

  /// Convierte este modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
