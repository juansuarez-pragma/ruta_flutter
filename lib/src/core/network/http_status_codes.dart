/// Constantes de códigos de estado HTTP.
///
/// Referencia: https://developer.mozilla.org/es/docs/Web/HTTP/Status
///
/// Los códigos de estado HTTP se dividen en 5 categorías:
/// - 1xx: Respuestas informativas
/// - 2xx: Respuestas exitosas
/// - 3xx: Redirecciones
/// - 4xx: Errores del cliente
/// - 5xx: Errores del servidor
abstract class HttpStatusCodes {
  HttpStatusCodes._();

  // ============================================
  // 2xx - Respuestas exitosas
  // ============================================

  /// La solicitud ha tenido éxito.
  static const int ok = 200;

  /// La solicitud ha tenido éxito y se ha creado un nuevo recurso.
  static const int created = 201;

  /// La solicitud se ha recibido pero aún no se ha actuado.
  static const int accepted = 202;

  /// La solicitud ha tenido éxito pero no hay contenido que devolver.
  static const int noContent = 204;

  // ============================================
  // 4xx - Errores del cliente
  // ============================================

  /// El servidor no puede procesar la solicitud debido a un error del cliente.
  static const int badRequest = 400;

  /// El cliente debe autenticarse para obtener la respuesta solicitada.
  static const int unauthorized = 401;

  /// El cliente no tiene derechos de acceso al contenido.
  static const int forbidden = 403;

  /// El servidor no puede encontrar el recurso solicitado.
  static const int notFound = 404;

  /// El método de solicitud no está soportado para el recurso.
  static const int methodNotAllowed = 405;

  /// El servidor no puede producir una respuesta aceptable.
  static const int notAcceptable = 406;

  /// La solicitud no pudo completarse debido a un conflicto.
  static const int conflict = 409;

  /// El recurso solicitado ya no está disponible.
  static const int gone = 410;

  /// El servidor rechaza la solicitud porque el cuerpo es demasiado grande.
  static const int payloadTooLarge = 413;

  /// El cliente ha enviado demasiadas solicitudes en un tiempo determinado.
  static const int tooManyRequests = 429;

  // ============================================
  // 5xx - Errores del servidor
  // ============================================

  /// El servidor ha encontrado una situación que no sabe cómo manejar.
  static const int internalServerError = 500;

  /// El método de solicitud no está soportado por el servidor.
  static const int notImplemented = 501;

  /// El servidor actuando como gateway recibió una respuesta inválida.
  static const int badGateway = 502;

  /// El servidor no está listo para manejar la solicitud.
  static const int serviceUnavailable = 503;

  /// El servidor actuando como gateway no recibió respuesta a tiempo.
  static const int gatewayTimeout = 504;

  // ============================================
  // Rangos de códigos
  // ============================================

  /// Verifica si el código indica éxito (2xx).
  static bool isSuccess(int code) => code >= 200 && code < 300;

  /// Verifica si el código indica error del cliente (4xx).
  static bool isClientError(int code) => code >= 400 && code < 500;

  /// Verifica si el código indica error del servidor (5xx).
  static bool isServerError(int code) => code >= 500 && code < 600;
}
