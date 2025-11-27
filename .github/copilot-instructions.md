## How to be productive in this repo

This project is a Dart console app that follows a Clean Architecture (presentation/domain/data/core). Use these focused instructions to make code changes, add features, or refactor safely.

- **Big picture:** The app is a CLI that consumes the Fake Store API. Data flows: UseCase -> Repository (interface in `lib/src/domain/repositories`) -> Repository Impl (`lib/src/data/repositories`) -> DataSources (`lib/src/data/datasources`) -> `ApiClient` -> HTTP.
- **Dependency injection:** `lib/src/di/injection_container.dart` uses `get_it` (service-locator). Register or replace bindings here. `EnvConfig` must be initialized before calling `init()`. Use `serviceLocator` variable (not abbreviated `sl`).
- **Environment/config:** Environment is read via `lib/src/core/config/dotenv_reader.dart` and `EnvConfig`. Copy `.env.example` -> `.env` and set `API_BASE_URL` and `API_TIMEOUT` as needed.
- **Network & errors:** Centralized HTTP handling via `ApiResponseHandler` (`lib/src/core/network/api_response_handler.dart`) and an `ApiClient` implementation. DataSources delegate HTTP calls to `ApiClient`; exceptions are converted into `Failure` types by repositories (see `lib/src/core/errors` and `lib/src/data/repositories/base` patterns).
- **Presentation:** The entry point coordinates `Application` (`lib/src/presentation/application.dart`) and a `UserInterface` adapter (`lib/src/presentation/adapters/console_user_interface.dart`). To add a new UI, implement `UserInterface` and register it in the DI container.
- **Naming & structure conventions (observable):**
  - Files: `snake_case`
  - Classes: `PascalCase`
  - Variables/methods: `camelCase`
  - Models are immutable and provide `fromJson` and `toEntity` methods (see `lib/src/data/models/product_model.dart`).
- **Error handling style to follow:** Use the Either<Failure, T> pattern from `dartz` across repositories and usecases. Convert exceptions to `Failure` at repository boundary.
- **Where to add logic:** Business rules belong in `lib/src/domain/usecases`. IO and mapping belongs in `lib/src/data/*`.
- **Common change patterns:**
  - Add new endpoint: implement DataSource method -> expose through RepositoryImpl -> add method to Repository interface -> add UseCase -> wire into DI -> call from `Application` or UI.
  - Replace HTTP behavior: update `ApiClientImpl` or `ApiResponseHandler` (they centralize headers, timeouts, and error mapping).
- **Commands / workflows:**
  - Install deps: `dart pub get`
  - Run app: `dart run` (from project root)
  - Static analysis: `dart analyze` (project contains `analysis_options.yaml`)
  - Format: `dart format .`
  - Tests: run `dart test` (tests live under `test/` if present)
- **Key files to inspect for context:**
  - `lib/src/di/injection_container.dart`
  - `lib/src/core/config/*` (dotenv reader, env config)
  - `lib/src/core/network/api_response_handler.dart`
  - `lib/src/presentation/application.dart`
  - `lib/src/presentation/adapters/console_user_interface.dart`
  - `lib/src/domain/usecases/*` and `lib/src/domain/repositories/*`
  - `lib/src/data/datasources/*` and `lib/src/data/repositories/*`
- **Style / linting:** The repo uses `lints` and an `analysis_options.yaml` file. Follow existing code style and patterns when adding new code. The project README and `ARQUITECTURA.md` document conventions and the expected flow.

If anything below is unclear or you want examples (e.g. adding a new endpoint or a new UI adapter), tell me which area and I will expand with a short code snippet and exact edit steps.
