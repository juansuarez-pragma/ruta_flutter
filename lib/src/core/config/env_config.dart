import 'package:fase_2_consumo_api/src/core/config/dotenv_reader.dart';
import 'package:fase_2_consumo_api/src/core/config/env_config_exception.dart';
import 'package:fase_2_consumo_api/src/core/config/env_reader.dart';
import 'package:fase_2_consumo_api/src/core/config/environment.dart';

/// Clase de configuración que gestiona las variables de entorno.
///
/// Implementa el patrón Singleton para garantizar una única instancia
/// de configuración en toda la aplicación.
///
/// Utiliza [EnvReader] para desacoplar la lectura de variables de entorno
/// de la implementación concreta (dotenv, flutter_dotenv, etc.).
///
/// Ejemplo de uso:
/// ```dart
/// await EnvConfig.instance.initialize();
/// final baseUrl = EnvConfig.instance.apiBaseUrl;
/// ```
///
/// Para usar una implementación diferente de [EnvReader]:
/// ```dart
/// await EnvConfig.instance.initialize(
///   reader: MiCustomEnvReader(),
/// );
/// ```
class EnvConfig {
  // Singleton instance
  static final EnvConfig _instance = EnvConfig._internal();
  static EnvConfig get instance => _instance;

  // EnvReader instance (desacoplado de dotenv)
  EnvReader? _reader;

  // Estado de inicialización
  bool _isInitialized = false;

  // Constructor privado para Singleton
  EnvConfig._internal();

  /// Inicializa la configuración cargando las variables de entorno.
  ///
  /// [envPath] es la ruta al archivo de configuración (por defecto '.env').
  /// [reader] es la implementación de [EnvReader] a usar. Por defecto usa
  /// [DotEnvReader], pero puede cambiarse por otra implementación.
  ///
  /// Debe llamarse una vez al inicio de la aplicación antes de acceder
  /// a cualquier variable de configuración.
  ///
  /// Lanza [EnvConfigException] si las variables requeridas no están definidas.
  Future<void> initialize({String envPath = '.env', EnvReader? reader}) async {
    if (_isInitialized) return;

    _reader = reader ?? DotEnvReader();
    await _reader!.load(envPath);
    _validateRequiredVariables();
    _isInitialized = true;
  }

  /// Valida que todas las variables de entorno requeridas estén definidas.
  void _validateRequiredVariables() {
    final requiredVars = ['API_BASE_URL'];
    final missingVars = <String>[];

    for (final varName in requiredVars) {
      if (!_reader!.containsKey(varName)) {
        missingVars.add(varName);
      }
    }

    if (missingVars.isNotEmpty) {
      throw EnvConfigException(
        'Variables de entorno requeridas no encontradas: ${missingVars.join(', ')}. '
        'Asegúrate de crear el archivo .env basándote en .env.example',
      );
    }
  }

  /// Obtiene un valor de configuración con valor por defecto opcional.
  String _get(String key, {String defaultValue = ''}) {
    _ensureInitialized();
    return _reader?[key] ?? defaultValue;
  }

  /// Obtiene un valor entero de configuración.
  int _getInt(String key, {int defaultValue = 0}) {
    final value = _get(key);
    return int.tryParse(value) ?? defaultValue;
  }

  /// Verifica que la configuración esté inicializada.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw EnvConfigException(
        'EnvConfig no ha sido inicializado. '
        'Llama a EnvConfig.instance.initialize() antes de acceder a las variables.',
      );
    }
  }

  // ============================================
  // Getters para variables de configuración
  // ============================================

  /// URL base de la API.
  String get apiBaseUrl => _get('API_BASE_URL');

  /// Timeout de las peticiones HTTP en milisegundos.
  int get apiTimeout => _getInt('API_TIMEOUT', defaultValue: 30000);

  /// Ambiente actual de la aplicación.
  Environment get environment {
    final env = _get('ENVIRONMENT', defaultValue: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  /// Indica si el ambiente es de desarrollo.
  bool get isDevelopment => environment == Environment.development;

  /// Indica si el ambiente es de producción.
  bool get isProduction => environment == Environment.production;

  /// Indica si el ambiente es de staging.
  bool get isStaging => environment == Environment.staging;
}
