import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';
import 'cart_product_model.dart';

/// Modelo de datos para un carrito.
///
/// Maneja la serialización/deserialización de JSON y la conversión
/// a la entidad de dominio [CartEntity].
class CartModel {
  final int id;
  final int userId;
  final DateTime date;
  final List<CartProductModel> products;

  const CartModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  /// Crea un [CartModel] a partir de un mapa JSON.
  ///
  /// Implementa validación defensiva según recomendaciones de seguridad:
  /// - Valida que id existe y es un entero positivo
  /// - Valida que userId existe y es un entero positivo
  /// - Valida que date tiene formato ISO 8601 válido
  /// - Valida que products es una lista
  ///
  /// Lanza [FormatException] si los datos son inválidos.
  factory CartModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final userId = json['userId'];
    final dateStr = json['date'];
    final productsJson = json['products'];

    if (id == null || id is! int || id <= 0) {
      throw FormatException('id inválido o faltante: $id');
    }

    if (userId == null || userId is! int || userId <= 0) {
      throw FormatException('userId inválido o faltante: $userId');
    }

    if (productsJson == null || productsJson is! List) {
      throw FormatException('products debe ser una lista');
    }

    DateTime date;
    try {
      date = DateTime.parse(dateStr as String);
    } catch (_) {
      throw FormatException('Formato de fecha inválido: $dateStr');
    }

    return CartModel(
      id: id,
      userId: userId,
      date: date,
      products: productsJson
          .map((p) => CartProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convierte este modelo a una entidad de dominio.
  CartEntity toEntity() {
    return CartEntity(
      id: id,
      userId: userId,
      date: date,
      products: products.map((p) => p.toEntity()).toList(),
    );
  }

  /// Convierte este modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}
