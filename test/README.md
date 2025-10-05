# Test Suite for Hymnes SDA FR

This directory contains comprehensive tests for the Hymnes SDA FR Flutter application.

## Test Structure

### Unit Tests (`test/unit/`)

- **Models** (`test/unit/models/`): Tests for data models

  - `hymn_test.dart` - Tests for Hymn model
  - `user_model_test.dart` - Tests for UserModel
  - `favorite_hymn_test.dart` - Tests for FavoriteHymn model

- **Services** (`test/unit/services/`): Tests for service classes

  - `hymn_data_service_test.dart` - Tests for HymnDataService

- **Repositories** (`test/unit/repositories/`): Tests for repository classes

  - `hymn_repository_test.dart` - Tests for HymnRepository

- **BLoCs** (`test/unit/blocs/`): Tests for state management
  - `auth_bloc_test.dart` - Tests for AuthBloc
  - `favorites_bloc_test.dart` - Tests for FavoritesBloc
  - `audio_bloc_test.dart` - Tests for AudioBloc

### Widget Tests (`test/widget/`)

- **Widgets** (`test/widget/widgets/`): Tests for UI components

  - `hymn_card_test.dart` - Tests for HymnCard widget
  - `audio_player_widget_test.dart` - Tests for AudioPlayerWidget

- **Screens** (`test/widget/screens/`): Tests for screen widgets
  - `home_screen_test.dart` - Tests for HomeScreen

### Integration Tests (`integration_test/`)

- `app_test.dart` - General app integration tests
- `auth_flow_test.dart` - Authentication flow tests
- `hymn_flow_test.dart` - Hymn browsing and playback tests

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Unit Tests Only

```bash
flutter test test/unit/
```

### Run Widget Tests Only

```bash
flutter test test/widget/
```

### Run Integration Tests

```bash
flutter test integration_test/
```

### Run Specific Test File

```bash
flutter test test/unit/models/hymn_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Generate Coverage Report

```bash
genhtml coverage/lcov.info -o coverage/html
```

## Test Dependencies

The following packages are used for testing:

- `flutter_test` - Core Flutter testing framework
- `bloc_test` - Testing utilities for BLoC pattern
- `mockito` - Mocking framework for unit tests
- `integration_test` - Integration testing framework

## Test Coverage

The test suite aims to achieve:

- **Unit Tests**: 90%+ coverage for models, services, repositories, and BLoCs
- **Widget Tests**: 80%+ coverage for UI components
- **Integration Tests**: Complete user flow coverage

## Writing New Tests

### Unit Tests

1. Create test file in appropriate directory under `test/unit/`
2. Import necessary dependencies
3. Use `setUp()` and `tearDown()` for test preparation
4. Group related tests using `group()`
5. Use descriptive test names

### Widget Tests

1. Create test file in appropriate directory under `test/widget/`
2. Use `testWidgets()` for widget testing
3. Mock BLoCs and services as needed
4. Test user interactions and state changes

### Integration Tests

1. Create test file in `integration_test/` directory
2. Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
3. Test complete user flows
4. Verify app behavior across different scenarios

## Best Practices

1. **Test Isolation**: Each test should be independent
2. **Descriptive Names**: Use clear, descriptive test names
3. **Arrange-Act-Assert**: Structure tests with clear sections
4. **Mock External Dependencies**: Use mocks for external services
5. **Test Edge Cases**: Include tests for error conditions
6. **Maintain Test Data**: Keep test data consistent and realistic

## Continuous Integration

Tests are automatically run in CI/CD pipeline:

- Unit tests run on every commit
- Widget tests run on every PR
- Integration tests run on release builds

## Troubleshooting

### Common Issues

1. **Mock Generation**: Run `flutter packages pub run build_runner build` to generate mocks
2. **Test Timeouts**: Increase timeout for slow tests
3. **Platform Channels**: Mock platform channels for unit tests
4. **Firebase**: Use Firebase emulators for integration tests

### Debugging Tests

1. Use `debugPrint()` for debugging output
2. Use `tester.pumpAndSettle()` to wait for animations
3. Use `tester.pump()` for controlled timing
4. Use `expect()` with custom matchers for complex assertions
