import 'package:dotenv/dotenv.dart';
import 'package:fase_2_consumo_api/src/core/config/env_reader.dart';

/// Implementación de [EnvReader] usando el paquete `dotenv`.
///
/// Este adaptador encapsula la dependencia de `dotenv`, permitiendo
/// cambiar a otra librería (como `flutter_dotenv`) sin afectar
/// el resto de la aplicación.
class DotEnvReader implements EnvReader {
  DotEnv? _dotEnv;

  @override
  Future<void> load(String path) async {
    _dotEnv = DotEnv(includePlatformEnvironment: true)..load([path]);
  }

  @override
  String? operator [](String key) {
    return _dotEnv?[key];
  }

  @override
  bool containsKey(String key) {
    final value = _dotEnv?[key];
    return value != null && value.isNotEmpty;
  }
}
