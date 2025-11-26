## Descripción General del Proyecto

Esta es una aplicación de línea de comandos en Dart que funciona como un cliente interactivo para la [API de Fake Store](https://fakestoreapi.com/). Permite a los usuarios obtener todos los productos, un producto por su ID o todas las categorías de productos. El proyecto está construido con un enfoque en la arquitectura limpia, separando las responsabilidades en tres capas distintas: Dominio, Datos y Núcleo (Core).

**Tecnologías y Principios Clave:**

*   **Lenguaje:** Dart
*   **Arquitectura:** Arquitectura Limpia (Clean Architecture)
*   **Inyección de Dependencias:** `get_it` (patrón de Localizador de Servicios)
*   **Cliente HTTP:** `http`
*   **Manejo de Errores:** `dartz` (para el tipo `Either`) y un `ApiResponseHandler` personalizado
*   **Patrones de Diseño:** Repositorio, Estrategia
*   **Pruebas (Testing):** El proyecto está estructurado para ser comprobable, aunque actualmente no hay pruebas implementadas.

## Compilación y Ejecución

1.  **Instalar Dependencias:**
    ```bash
    dart pub get
    ```

2.  **Ejecutar la Aplicación:**
    ```bash
    dart run
    ```

## Convenciones de Desarrollo

*   **Arquitectura Limpia:** El código está organizado en las capas `domain`, `data` y `core`.
    *   `domain`: Contiene la lógica de negocio (entidades, casos de uso, contratos de repositorio).
    *   `data`: Implementa el acceso a los datos (modelos, fuentes de datos, implementaciones de repositorio).
    *   `core`: Contiene aspectos transversales (inyección de dependencias, manejo de errores, utilidades de red).
*   **Inyección de Dependencias:** El paquete `get_it` se utiliza para gestionar las dependencias. Todas las dependencias se registran en `lib/src/core/injection_container.dart`.
*   **Patrón de Repositorio:** El `ProductRepository` define un contrato para las operaciones de datos, y `ProductRepositoryImpl` proporciona la implementación. Se utiliza un `BaseRepository` para centralizar la lógica de manejo de errores.
*   **Manejo de Errores:** La aplicación utiliza el tipo `Either` del paquete `dartz` para representar el éxito o el fracaso. Se utiliza un `ApiResponseHandler` personalizado para asignar los códigos de estado HTTP a excepciones específicas.
*   **Externalización de Cadenas de Texto:** Todas las cadenas de texto orientadas al usuario se gestionan en el archivo `util/strings.dart` para simplificar el mantenimiento y la posible internacionalización.
*   **Análisis Manual de JSON:** El JSON se analiza manualmente en las clases de modelo, evitando herramientas de generación de código.
*   **Seguridad Nula (Null Safety):** El proyecto tiene seguridad nula habilitada.
