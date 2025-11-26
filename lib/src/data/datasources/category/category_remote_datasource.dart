/// Interface para el origen de datos remoto de categorías.
abstract class CategoryRemoteDataSource {
  /// Obtiene todas las categorías desde la API.
  Future<List<String>> getAll();
}
