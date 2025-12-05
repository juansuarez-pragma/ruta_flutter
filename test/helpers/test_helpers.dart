/// Helpers y utilidades compartidas para testing.
///
/// Proporciona funciones de fábrica para crear entidades y modelos
/// de prueba de manera consistente.
library;

import 'package:fase_2_consumo_api/src/data/models/address_model.dart';
import 'package:fase_2_consumo_api/src/data/models/geolocation_model.dart';
import 'package:fase_2_consumo_api/src/data/models/name_model.dart';
import 'package:fase_2_consumo_api/src/data/models/product_model.dart';
import 'package:fase_2_consumo_api/src/data/models/user_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/address_entity.dart';
import 'package:fase_2_consumo_api/src/domain/entities/geolocation_entity.dart';
import 'package:fase_2_consumo_api/src/domain/entities/name_entity.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';

/// Crea una [ProductEntity] de prueba con valores por defecto.
///
/// Permite sobrescribir cualquier campo para casos de prueba específicos.
ProductEntity createTestProductEntity({
  int id = 1,
  String title = 'Producto de prueba',
  double price = 99.99,
  String description = 'Descripción del producto de prueba',
  String category = 'electronics',
  String image = 'https://example.com/image.jpg',
}) {
  return ProductEntity(
    id: id,
    title: title,
    price: price,
    description: description,
    category: category,
    image: image,
  );
}

/// Crea un [ProductModel] de prueba con valores por defecto.
///
/// Permite sobrescribir cualquier campo para casos de prueba específicos.
ProductModel createTestProductModel({
  int id = 1,
  String title = 'Producto de prueba',
  double price = 99.99,
  String description = 'Descripción del producto de prueba',
  String category = 'electronics',
  String image = 'https://example.com/image.jpg',
}) {
  return ProductModel(
    id: id,
    title: title,
    price: price,
    description: description,
    category: category,
    image: image,
  );
}

/// Crea una lista de [ProductEntity] de prueba.
List<ProductEntity> createTestProductEntityList({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestProductEntity(
      id: index + 1,
      title: 'Producto ${index + 1}',
      price: (index + 1) * 10.0,
    ),
  );
}

/// Crea una lista de [ProductModel] de prueba.
List<ProductModel> createTestProductModelList({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestProductModel(
      id: index + 1,
      title: 'Producto ${index + 1}',
      price: (index + 1) * 10.0,
    ),
  );
}

/// Lista de categorías de prueba.
List<String> createTestCategories() {
  return ['electronics', 'jewelery', "men's clothing", "women's clothing"];
}

/// Crea un [GeolocationEntity] de prueba con valores por defecto.
GeolocationEntity createTestGeolocationEntity({
  String lat = '-37.3159',
  String long = '81.1496',
}) {
  return GeolocationEntity(lat: lat, long: long);
}

/// Crea un [NameEntity] de prueba con valores por defecto.
NameEntity createTestNameEntity({
  String firstname = 'John',
  String lastname = 'Doe',
}) {
  return NameEntity(firstname: firstname, lastname: lastname);
}

/// Crea un [AddressEntity] de prueba con valores por defecto.
AddressEntity createTestAddressEntity({
  String city = 'Kilcoole',
  String street = 'New Road',
  int number = 7682,
  String zipcode = '12926-3874',
  GeolocationEntity? geolocation,
}) {
  return AddressEntity(
    city: city,
    street: street,
    number: number,
    zipcode: zipcode,
    geolocation: geolocation ?? createTestGeolocationEntity(),
  );
}

/// Crea un [UserEntity] de prueba con valores por defecto.
UserEntity createTestUserEntity({
  int id = 1,
  String email = 'john@gmail.com',
  String username = 'johnd',
  NameEntity? name,
  AddressEntity? address,
  String phone = '1-570-236-7033',
}) {
  return UserEntity(
    id: id,
    email: email,
    username: username,
    name: name ?? createTestNameEntity(),
    address: address ?? createTestAddressEntity(),
    phone: phone,
  );
}

/// Crea una lista de [UserEntity] de prueba.
List<UserEntity> createTestUserEntityList({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestUserEntity(
      id: index + 1,
      email: 'user${index + 1}@test.com',
      username: 'user${index + 1}',
    ),
  );
}

/// Crea un [GeolocationModel] de prueba con valores por defecto.
GeolocationModel createTestGeolocationModel({
  String lat = '-37.3159',
  String long = '81.1496',
}) {
  return GeolocationModel(lat: lat, long: long);
}

/// Crea un [NameModel] de prueba con valores por defecto.
NameModel createTestNameModel({
  String firstname = 'John',
  String lastname = 'Doe',
}) {
  return NameModel(firstname: firstname, lastname: lastname);
}

/// Crea un [AddressModel] de prueba con valores por defecto.
AddressModel createTestAddressModel({
  String city = 'Kilcoole',
  String street = 'New Road',
  int number = 7682,
  String zipcode = '12926-3874',
  GeolocationModel? geolocation,
}) {
  return AddressModel(
    city: city,
    street: street,
    number: number,
    zipcode: zipcode,
    geolocation: geolocation ?? createTestGeolocationModel(),
  );
}

/// Crea un [UserModel] de prueba con valores por defecto.
UserModel createTestUserModel({
  int id = 1,
  String email = 'john@gmail.com',
  String username = 'johnd',
  String password = 'm38rmF\$',
  NameModel? name,
  AddressModel? address,
  String phone = '1-570-236-7033',
}) {
  return UserModel(
    id: id,
    email: email,
    username: username,
    password: password,
    name: name ?? createTestNameModel(),
    address: address ?? createTestAddressModel(),
    phone: phone,
  );
}

/// Crea una lista de [UserModel] de prueba.
List<UserModel> createTestUserModelList({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestUserModel(
      id: index + 1,
      email: 'user${index + 1}@test.com',
      username: 'user${index + 1}',
    ),
  );
}
