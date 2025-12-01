# Reporte de Fase 5: Integración Continua (CI/CD)

## Resumen Ejecutivo

La Fase 5 implementó un pipeline de integración continua con GitHub Actions para automatizar análisis estático, ejecución de tests y reportes de cobertura.

## Pipeline de CI

### Archivo de Configuración

```
.github/workflows/ci.yml
```

### Triggers

El pipeline se ejecuta en:
- Push a ramas: `main`, `test`, `develop`
- Pull requests hacia: `main`, `test`, `develop`

### Jobs del Pipeline

```
┌─────────────┐
│   analyze   │ Análisis estático y formato
└─────┬───────┘
      │
      ├───────────────┬──────────────────┐
      ▼               ▼                  ▼
┌─────────────┐ ┌─────────────────┐ ┌─────────────┐
│    test     │ │ test-acceptance │ │             │
│  (unitarios │ │    (ATDD)       │ │             │
│  e integ.)  │ └────────┬────────┘ │             │
└──────┬──────┘          │          │             │
       │                 │          │             │
       └─────────────────┴──────────┘             │
                         │                        │
                         ▼                        │
                  ┌──────────────┐                │
                  │ quality-gate │◄───────────────┘
                  └──────────────┘
```

## Descripción de Jobs

### 1. Analyze (Análisis Estático)

**Propósito:** Verificar calidad del código antes de ejecutar tests.

**Pasos:**
1. Checkout del código
2. Configurar Dart SDK 3.5.4
3. Instalar dependencias (`dart pub get`)
4. Verificar formato (`dart format --set-exit-if-changed`)
5. Análisis estático (`dart analyze --fatal-infos`)

**Criterios de éxito:**
- Código correctamente formateado
- Sin errores ni warnings de análisis

### 2. Test (Tests Unitarios e Integración)

**Propósito:** Ejecutar suite completa de tests con cobertura.

**Pasos:**
1. Ejecutar tests (`dart test --reporter=github`)
2. Generar cobertura (`dart test --coverage=coverage`)
3. Instalar herramienta de cobertura
4. Generar reporte LCOV
5. Subir a Codecov (opcional)

**Dependencias:** Requiere que `analyze` pase primero.

### 3. Test-Acceptance (Tests ATDD)

**Propósito:** Ejecutar tests de aceptación por separado.

**Pasos:**
1. Ejecutar tests de aceptación (`dart test test/acceptance/`)

**Dependencias:** Requiere que `analyze` pase primero.

### 4. Quality Gate

**Propósito:** Verificación final de calidad del proyecto.

**Pasos:**
1. Ejecutar todos los tests
2. Verificar mínimo de tests (advertencia si < 300)
3. Confirmar Quality Gate pasado

**Dependencias:** Requiere que `analyze`, `test` y `test-acceptance` pasen.

## Configuración del SDK

```yaml
env:
  DART_SDK_VERSION: "3.5.4"
```

Se usa una versión fija para garantizar reproducibilidad.

## Integración con Codecov

El pipeline está preparado para subir reportes de cobertura a Codecov:

```yaml
- name: Subir cobertura a Codecov
  uses: codecov/codecov-action@v4
  with:
    files: coverage/lcov.info
    fail_ci_if_error: false
```

**Nota:** Para habilitar Codecov:
1. Conectar repositorio en codecov.io
2. Agregar `CODECOV_TOKEN` a los secrets del repositorio

## Métricas del Proyecto

### Estado Actual

| Métrica | Valor |
|---------|-------|
| Tests totales | 372 |
| Tests unitarios | ~305 |
| Tests de aceptación | 50 |
| Tests de integración | ~17 |
| Cobertura objetivo | ≥90% |

### Quality Gates

| Verificación | Criterio |
|--------------|----------|
| Formato | `dart format --set-exit-if-changed` |
| Análisis | `dart analyze --fatal-infos` |
| Tests | Todos deben pasar |
| Mínimo tests | ≥300 (advertencia) |

## Ejecución Local

### Simular el Pipeline

```bash
# 1. Análisis estático
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos

# 2. Tests unitarios e integración
dart test

# 3. Tests de aceptación
dart test test/acceptance/

# 4. Generar cobertura
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage \
  --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### Ver Cobertura Localmente

```bash
# Instalar lcov (macOS)
brew install lcov

# Generar HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador
open coverage/html/index.html
```

## Badges para README

Una vez configurado el repositorio, agregar estos badges:

```markdown
![CI](https://github.com/USUARIO/REPO/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/USUARIO/REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/USUARIO/REPO)
```

## Flujo de Trabajo Recomendado

### Para Desarrolladores

1. **Antes de commit:**
   ```bash
   dart format .
   dart analyze
   dart test
   ```

2. **Crear Pull Request:**
   - El pipeline se ejecuta automáticamente
   - Revisar resultados en la pestaña "Actions"
   - No hacer merge si hay errores

3. **Merge a main:**
   - Solo después de que el pipeline pase
   - Quality Gate debe estar en verde

### Para Revisores

1. Verificar que el pipeline pasó
2. Revisar cobertura de código
3. Verificar que los tests de aceptación pasan

## Próximas Mejoras

### Fase 6 (Potencial)
- [ ] Agregar job de build para release
- [ ] Implementar deploy automático
- [ ] Agregar notificaciones (Slack, Email)
- [ ] Implementar semantic versioning

### Optimizaciones
- [ ] Cache de dependencias de Dart
- [ ] Paralelización de tests
- [ ] Matrix de versiones de Dart

## Conclusión

La Fase 5 estableció un pipeline de CI robusto que:
- Garantiza calidad del código con análisis estático
- Ejecuta 372 tests automáticamente
- Separa tests unitarios de tests de aceptación
- Proporciona reportes de cobertura
- Implementa Quality Gates para proteger las ramas principales
