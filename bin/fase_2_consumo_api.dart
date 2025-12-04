import 'dart:io';

import 'package:fase_2_consumo_api/src/core/config/config.dart';
import 'package:fase_2_consumo_api/src/di/injection_container.dart' as di;

void main(List<String> arguments) async {
  // 1. Cargar variables de entorno
  try {
    await EnvConfig.instance.initialize();
  } on EnvConfigException catch (e) {
    print('Error de configuración: $e');
    print('Asegúrate de crear el archivo .env basándote en .env.example');
    exit(1);
  }

  // 2. Inicializar dependencias y obtener la aplicacion
  // El contenedor DI esta completamente encapsulado.
  // Solo recibimos el objeto raiz con todas sus dependencias inyectadas.
  final app = await di.init();

  // 3. Ejecutar la aplicacion
  await app.run();
}
