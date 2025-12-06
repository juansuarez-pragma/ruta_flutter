/// Fixtures de carritos para testing.
///
/// Proporciona datos de prueba consistentes para todos los tests
/// relacionados con carritos.
library;

/// JSON válido de un producto en carrito.
const Map<String, dynamic> validCartProductJson = {
  'productId': 1,
  'quantity': 4,
};

/// JSON de un segundo producto en carrito.
const Map<String, dynamic> validCartProductJson2 = {
  'productId': 2,
  'quantity': 1,
};

/// JSON válido de un carrito.
const Map<String, dynamic> validCartJson = {
  'id': 1,
  'userId': 1,
  'date': '2020-03-02T00:00:00.000Z',
  'products': [
    {'productId': 1, 'quantity': 4},
    {'productId': 2, 'quantity': 1},
  ],
};

/// JSON de un segundo carrito para listas.
const Map<String, dynamic> validCartJson2 = {
  'id': 2,
  'userId': 1,
  'date': '2020-01-02T00:00:00.000Z',
  'products': [
    {'productId': 3, 'quantity': 2},
  ],
};

/// JSON de carrito vacío (sin productos).
const Map<String, dynamic> emptyCartJson = {
  'id': 3,
  'userId': 2,
  'date': '2020-05-15T00:00:00.000Z',
  'products': <Map<String, dynamic>>[],
};

/// JSON incompleto de producto en carrito (falta productId).
const Map<String, dynamic> incompleteCartProductJson = {
  'quantity': 4,
};

/// JSON incompleto de carrito (falta userId).
const Map<String, dynamic> incompleteCartJson = {
  'id': 1,
  'date': '2020-03-02T00:00:00.000Z',
  'products': [],
};

/// JSON con tipo incorrecto para productId.
const Map<String, dynamic> wrongTypeCartProductJson = {
  'productId': 'no-es-un-numero',
  'quantity': 4,
};

/// JSON con tipo incorrecto para id de carrito.
const Map<String, dynamic> wrongTypeCartJson = {
  'id': 'no-es-un-numero',
  'userId': 1,
  'date': '2020-03-02T00:00:00.000Z',
  'products': [],
};

/// JSON con fecha en formato inválido.
const Map<String, dynamic> invalidDateCartJson = {
  'id': 1,
  'userId': 1,
  'date': 'fecha-invalida',
  'products': [],
};

/// JSON con products que no es una lista.
const Map<String, dynamic> invalidProductsCartJson = {
  'id': 1,
  'userId': 1,
  'date': '2020-03-02T00:00:00.000Z',
  'products': 'no-es-una-lista',
};

/// JSON con quantity negativa (inválido según seguridad).
const Map<String, dynamic> negativeQuantityCartProductJson = {
  'productId': 1,
  'quantity': -1,
};

/// JSON con productId cero (inválido según seguridad).
const Map<String, dynamic> zeroProductIdCartProductJson = {
  'productId': 0,
  'quantity': 4,
};

/// Lista de JSONs de carritos válidos.
const List<Map<String, dynamic>> validCartListJson = [
  validCartJson,
  validCartJson2,
];
