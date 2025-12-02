# Fake Store CLI

Aplicación de consola interactiva en Dart que consume la [Fake Store API](https://fakestoreapi.com/).

## Desarrollo Asistido por IA

Proyecto desarrollado con asistencia de Claude y Gemini para validar velocidad de desarrollo.

## Características

- Interfaz de consola interactiva (CLI)
- Consumo de 4 endpoints de la API
- Manejo robusto de errores de conexión y API
- Arquitectura limpia y testeable

## Ejecución

### Con Docker (recomendado)

```bash
docker run -it juancarlos05/fake-store-cli
```

### Con Dart SDK

```bash
# Instalar dependencias
dart pub get

# Configurar variables de entorno
cp .env.example .env

# Ejecutar
dart run
```

## Uso

```
1. Obtener todos los productos
2. Obtener un producto por ID
3. Obtener todas las categorías
4. Obtener productos por categoría
5. Salir
```

## Documentación Técnica

Ver [CLAUDE.md](CLAUDE.md) para detalles de arquitectura, patrones y guías de desarrollo.
