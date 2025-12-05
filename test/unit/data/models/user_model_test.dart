import 'dart:convert';

import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/data/models/user_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';

void main() {
  group('UserModel', () {
    const testUserJson = '''
    {
      "id": 1,
      "email": "john@gmail.com",
      "username": "johnd",
      "password": "m38rmF\$",
      "name": {
        "firstname": "john",
        "lastname": "doe"
      },
      "address": {
        "city": "kilcoole",
        "street": "new road",
        "number": 7682,
        "zipcode": "12926-3874",
        "geolocation": {
          "lat": "-37.3159",
          "long": "81.1496"
        }
      },
      "phone": "1-570-236-7033"
    }
    ''';

    group('fromJson', () {
      test('retorna UserModel válido desde JSON', () {
        // Arrange
        final jsonMap = json.decode(testUserJson) as Map<String, dynamic>;

        // Act
        final result = UserModel.fromJson(jsonMap);

        // Assert
        expect(result.id, 1);
        expect(result.email, 'john@gmail.com');
        expect(result.username, 'johnd');
        expect(result.password, 'm38rmF\$');
        expect(result.name.firstname, 'john');
        expect(result.name.lastname, 'doe');
        expect(result.address.city, 'kilcoole');
        expect(result.address.street, 'new road');
        expect(result.address.number, 7682);
        expect(result.address.zipcode, '12926-3874');
        expect(result.address.geolocation.lat, '-37.3159');
        expect(result.address.geolocation.long, '81.1496');
        expect(result.phone, '1-570-236-7033');
      });

      test('parsea correctamente objetos anidados', () {
        // Arrange
        final jsonMap = json.decode(testUserJson) as Map<String, dynamic>;

        // Act
        final result = UserModel.fromJson(jsonMap);

        // Assert
        expect(result.name, isNotNull);
        expect(result.address, isNotNull);
        expect(result.address.geolocation, isNotNull);
      });
    });

    group('toEntity', () {
      test('convierte UserModel a UserEntity correctamente', () {
        // Arrange
        final jsonMap = json.decode(testUserJson) as Map<String, dynamic>;
        final model = UserModel.fromJson(jsonMap);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<UserEntity>());
        expect(entity.id, model.id);
        expect(entity.email, model.email);
        expect(entity.username, model.username);
        expect(entity.name.firstname, model.name.firstname);
        expect(entity.name.lastname, model.name.lastname);
        expect(entity.address.city, model.address.city);
        expect(entity.phone, model.phone);
      });

      test('preserva todos los campos en la conversión', () {
        // Arrange
        final jsonMap = json.decode(testUserJson) as Map<String, dynamic>;
        final model = UserModel.fromJson(jsonMap);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.address.geolocation.lat, model.address.geolocation.lat);
        expect(entity.address.geolocation.long, model.address.geolocation.long);
      });
    });

    group('fromJson con lista', () {
      test('parsea lista de usuarios correctamente', () {
        // Arrange
        final jsonList = '[$testUserJson, $testUserJson]';
        final list = json.decode(jsonList) as List;

        // Act
        final users = list
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Assert
        expect(users.length, 2);
        expect(users[0].id, 1);
        expect(users[1].id, 1);
      });
    });
  });

  group('NameModel', () {
    test('fromJson parsea nombre correctamente', () {
      // Arrange
      final json = {'firstname': 'John', 'lastname': 'Doe'};

      // Act
      final userJson = {
        'id': 1,
        'email': 'test@test.com',
        'username': 'test',
        'password': 'test',
        'name': json,
        'address': {
          'city': 'city',
          'street': 'street',
          'number': 1,
          'zipcode': '12345',
          'geolocation': {'lat': '0', 'long': '0'},
        },
        'phone': '123',
      };
      final result = UserModel.fromJson(userJson);

      // Assert
      expect(result.name.firstname, 'John');
      expect(result.name.lastname, 'Doe');
    });
  });

  group('AddressModel', () {
    test('fromJson parsea dirección correctamente', () {
      // Arrange
      final addressJson = {
        'city': 'Test City',
        'street': 'Test Street',
        'number': 123,
        'zipcode': '12345-678',
        'geolocation': {'lat': '40.7128', 'long': '-74.0060'},
      };

      final userJson = {
        'id': 1,
        'email': 'test@test.com',
        'username': 'test',
        'password': 'test',
        'name': {'firstname': 'Test', 'lastname': 'User'},
        'address': addressJson,
        'phone': '123',
      };

      // Act
      final result = UserModel.fromJson(userJson);

      // Assert
      expect(result.address.city, 'Test City');
      expect(result.address.street, 'Test Street');
      expect(result.address.number, 123);
      expect(result.address.zipcode, '12345-678');
    });
  });

  group('GeolocationModel', () {
    test('fromJson parsea coordenadas correctamente', () {
      // Arrange
      final userJson = {
        'id': 1,
        'email': 'test@test.com',
        'username': 'test',
        'password': 'test',
        'name': {'firstname': 'Test', 'lastname': 'User'},
        'address': {
          'city': 'city',
          'street': 'street',
          'number': 1,
          'zipcode': '12345',
          'geolocation': {'lat': '40.7128', 'long': '-74.0060'},
        },
        'phone': '123',
      };

      // Act
      final result = UserModel.fromJson(userJson);

      // Assert
      expect(result.address.geolocation.lat, '40.7128');
      expect(result.address.geolocation.long, '-74.0060');
    });
  });
}
