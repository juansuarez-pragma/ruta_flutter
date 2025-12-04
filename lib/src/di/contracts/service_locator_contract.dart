abstract class ServiceLocatorContract {
  /// Registra una instancia unica (singleton) creada de forma perezosa.
  void registerLazySingleton<T extends Object>(T Function() factory);

  /// Registra una fabrica que crea nuevas instancias en cada llamada.
  ///
  /// Cada vez que se solicita [T], se ejecuta [factory] para crear
  /// una nueva instancia.
  void registerFactory<T extends Object>(T Function() factory);

  /// Obtiene una instancia del tipo [T] registrado.
  ///
  /// Permite usar el contenedor como funcion: `container<MyService>()`
  ///
  /// Lanza una excepcion si [T] no esta registrado.
  T call<T extends Object>();
}
