import 'dart:io';
import 'package:fase_2_consumo_api/src/core/config/config.dart';
import 'package:fase_2_consumo_api/src/di/injection_container.dart' as di;
import 'package:fase_2_consumo_api/src/presentation/application.dart'
    show ApplicationController;

void main(List<String> arguments) async {
  // 1. Cargar variables de entorno
  try {
    await EnvConfig.instance.initialize();
  } on EnvConfigException catch (e) {
    print('Error de configuración: $e');
    print('Asegúrate de crear el archivo .env basándote en .env.example');
    exit(1);
  }

  // 2. Inicializar dependencias
  await di.init();

  // 3. Ejecutar la aplicación
  // La UI se inyecta a través del contenedor de dependencias.
  // Para cambiar de consola a otra UI (GUI, web, móvil),
  // solo se necesita registrar otra implementación de UserInterface
  // en injection_container.dart
  final app = di.serviceLocator<ApplicationController>();
  await app.run();
}
