import 'package:dotenv/dotenv.dart';

/// Enumeración de los ambientes disponibles en la aplicación.
enum Environment { development, staging, production }

/// Clase de configuración que gestiona las variables de entorno.
///
/// Implementa el patrón Singleton para garantizar una única instancia
/// de configuración en toda la aplicación.
///
/// Ejemplo de uso:
/// ```dart
/// await EnvConfig.instance.initialize();
/// final baseUrl = EnvConfig.instance.apiBaseUrl;
/// ```
class EnvConfig {
  // Singleton instance
  static final EnvConfig _instance = EnvConfig._internal();
  static EnvConfig get instance => _instance;

  // DotEnv instance
  DotEnv? _dotEnv;

  // Estado de inicialización
  bool _isInitialized = false;

  // Constructor privado para Singleton
  EnvConfig._internal();

  /// Inicializa la configuración cargando las variables de entorno.
  ///
  /// Debe llamarse una vez al inicio de la aplicación antes de acceder
  /// a cualquier variable de configuración.
  ///
  /// Lanza [EnvConfigException] si las variables requeridas no están definidas.
  Future<void> initialize({String envPath = '.env'}) async {
    if (_isInitialized) return;

    _dotEnv = DotEnv(includePlatformEnvironment: true)..load([envPath]);
    _validateRequiredVariables();
    _isInitialized = true;
  }

  /// Valida que todas las variables de entorno requeridas estén definidas.
  void _validateRequiredVariables() {
    final requiredVars = ['API_BASE_URL'];
    final missingVars = <String>[];

    for (final varName in requiredVars) {
      if (_dotEnv?[varName] == null || _dotEnv![varName]!.isEmpty) {
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
    return _dotEnv?[key] ?? defaultValue;
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

/// Excepción lanzada cuando hay errores de configuración de entorno.
class EnvConfigException implements Exception {
  final String message;

  EnvConfigException(this.message);

  @override
  String toString() => 'EnvConfigException: $message';
}
