# Fase 2: Consumo de API con Dart

Este proyecto es una aplicación de consola interactiva desarrollada en Dart como parte de la Fase 2 de la Ruta de Crecimiento Práctica. La aplicación consume datos de la [Fake Store API](https://fakestoreapi.com/) y los presenta en la terminal.

## Características

- **Interfaz de Consola Interactiva (CLI):** Permite al usuario elegir qué acción realizar a través de un menú en la terminal.
- **Consumo de API:** Realiza peticiones a 3 endpoints diferentes:
  - Obtener todos los productos.
  - Obtener un producto específico por su ID.
  - Obtener todas las categorías de productos.
- **Manejo de Errores:** Implementa un sistema robusto para manejar errores de conexión o de la API.

## Arquitectura y Diseño

El proyecto está construido siguiendo principios de software de alta calidad para garantizar que sea escalable, mantenible y testeable.

- **Clean Architecture:** La lógica está separada en tres capas principales:
  - **Domain:** Contiene la lógica de negocio pura (entidades, casos de uso, contratos de repositorios).
  - **Data:** Implementa la lógica de acceso a datos (modelos, datasource para la API, implementación de repositorios).
  - **Core:** Lógica transversal como el contenedor de dependencias y patrones reutilizables.
- **Inyección de Dependencias:** Se utiliza el Service Locator `get_it` para desacoplar las capas y gestionar las dependencias de forma centralizada.
- **Patrones de Diseño:**
  - **Repository Pattern:** Para abstraer la fuente de datos.
  - **Strategy Pattern:** Utilizado en el `ApiResponseHandler` para gestionar diferentes respuestas HTTP de una manera limpia y escalable.
  - **Singleton Pattern:** Utilizado en `EnvConfig` para gestión centralizada de variables de entorno.
  - **Adapter Pattern:** Desacopla dependencias externas (dotenv, http) mediante interfaces abstractas.
  - **Ports & Adapters Pattern:** Desacopla la UI de la lógica de negocio mediante interfaces abstractas.
  - **Clase Base para Repositorios:** Se usa una clase `BaseRepository` para centralizar y reutilizar la lógica de manejo de excepciones en todos los repositorios.
  - **Parseo Manual de JSON:** Los modelos de datos se parsean de JSON a objetos Dart de forma manual, eliminando la necesidad de herramientas de generación de código como `json_serializable`.
- **Variables de Entorno:** La configuración sensible (URLs, timeouts) se gestiona mediante archivos `.env` usando el paquete `dotenv`, evitando URLs hardcodeadas en el código.
- **Externalización de Textos:** Todos los textos de la aplicación (mensajes, títulos, etc.) se gestionan en una clase `AppStrings` para facilitar el mantenimiento y futuras internacionalizaciones.

## Configuración del Proyecto

Asegúrate de tener el [SDK de Dart](https://dart.dev/get-dart) instalado.

1. Clona el repositorio (si aplica).
2. Navega al directorio del proyecto:
   ```bash
   cd fase_2_consumo_api
   ```
3. Instala las dependencias:
   ```bash
   dart pub get
   ```
4. Configura las variables de entorno:
   ```bash
   cp .env.example .env
   ```
   Edita el archivo `.env` según tus necesidades.

## Variables de Entorno

El proyecto utiliza variables de entorno para configuración. Copia `.env.example` a `.env` y ajusta los valores:

| Variable | Descripción | Requerida | Valor por defecto |
|----------|-------------|-----------|-------------------|
| `API_BASE_URL` | URL base para la API de Fake Store | Sí | `https://fakestoreapi.com` |

> **Nota:** El archivo `.env` está excluido del control de versiones por seguridad. Solo `.env.example` se versiona como plantilla.

## Cómo Ejecutar la Aplicación

Desde el directorio `fase_2_consumo_api`, ejecuta el siguiente comando:

```bash
dart run
```

## Cómo Usar

Una vez que la aplicación se inicie, verás un mensaje de bienvenida y un menú de opciones:

```
--- Bienvenido al Cliente Interactivo de Fake Store API ---

Por favor, elige una opción:
1. Obtener todos los productos
2. Obtener un producto por ID
3. Obtener todas las categorías
4. Salir
Opción: 
```

- Escribe el número de la opción que deseas (ej. `1`) y presiona `Enter`.
- Si eliges la opción `2`, la aplicación te pedirá que ingreses un ID de producto.
- Para cerrar la aplicación, elige la opción `4`.
