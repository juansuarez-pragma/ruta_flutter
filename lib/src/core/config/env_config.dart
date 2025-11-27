import 'package:fase_2_consumo_api/src/core/config/config.dart';

/// Clase de configuración que gestiona las variables de entorno.
///
/// Implementa el patrón Singleton para garantizar una única instancia
/// de configuración en toda la aplicación.
///
/// Utiliza [EnvReader] para desacoplar la lectura de variables de entorno
/// de la implementación concreta (dotenv).
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
    final requiredVars = EnvironmentVariables.values();
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

  /// Obtiene un valor de configuración requerido.
  ///
  /// Lanza [EnvConfigException] si la variable no existe o está vacía.
  String _getRequired(String key) {
    _ensureInitialized();
    final value = _reader?[key];
    if (value == null || value.isEmpty) {
      throw EnvConfigException(
        'Variable de entorno requerida no encontrada: $key',
      );
    }
    return value;
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

  /// URL base de la API (requerida).
  String get apiBaseUrl => _getRequired('API_BASE_URL');
}
