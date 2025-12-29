import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'weather_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  WeartherRepository,
  SettingsState,
  MunroState,
  Logger,
])
void main() {
  late MockWeartherRepository mockWeatherRepository;
  late MockSettingsState mockSettingsState;
  late MockMunroState mockMunroState;
  late MockLogger mockLogger;
  late WeatherState weatherState;

  late List<Weather> sampleForecast;
  late Munro sampleMunro;

  setUp(() {
    // Sample weather data for testing
    sampleForecast = [
      Weather(
        date: DateTime(2025, 12, 24, 12, 0),
        sunrise: DateTime(2025, 12, 24, 8, 0),
        sunset: DateTime(2025, 12, 24, 16, 0),
        summary: 'Clear sky',
        temperature: 15.5,
        temperatureMin: 10.0,
        temperatureMax: 18.0,
        windSpeed: 5.5,
        humidity: 65,
        description: 'Clear sky',
        rain: 0.0,
        icon: '01d',
      ),
      Weather(
        date: DateTime(2025, 12, 25, 12, 0),
        sunrise: DateTime(2025, 12, 25, 8, 0),
        sunset: DateTime(2025, 12, 25, 16, 0),
        summary: 'Partly cloudy',
        temperature: 12.0,
        temperatureMin: 8.0,
        temperatureMax: 14.0,
        windSpeed: 8.0,
        humidity: 75,
        description: 'Few clouds',
        rain: 0.2,
        icon: '02d',
      ),
      Weather(
        date: DateTime(2025, 12, 26, 12, 0),
        sunrise: DateTime(2025, 12, 26, 8, 0),
        sunset: DateTime(2025, 12, 26, 16, 0),
        summary: 'Rainy',
        temperature: 8.0,
        temperatureMin: 5.0,
        temperatureMax: 10.0,
        windSpeed: 12.0,
        humidity: 90,
        description: 'Light rain',
        rain: 0.8,
        icon: '10d',
      ),
    ];

    // Sample munro data for testing
    sampleMunro = Munro(
      id: 1,
      name: 'Ben Nevis',
      extra: null,
      area: 'Lochaber',
      meters: 1345,
      section: 'Fort William to Loch Treig & Loch Leven',
      region: 'Western Highlands',
      feet: 4413,
      lat: 56.7969,
      lng: -5.0036,
      link: 'https://www.walkhighlands.co.uk/fortwilliam/bennevis.shtml',
      description: 'The highest mountain in the British Isles',
      pictureURL: 'https://example.com/ben-nevis.jpg',
      startingPointURL: 'https://example.com/start.jpg',
    );

    mockWeatherRepository = MockWeartherRepository();
    mockSettingsState = MockSettingsState();
    mockMunroState = MockMunroState();
    mockLogger = MockLogger();
    weatherState = WeatherState(
      mockWeatherRepository,
      mockSettingsState,
      mockMunroState,
      mockLogger,
    );

    // Default mock behavior
    when(mockSettingsState.metricTemperature).thenReturn(true);
    when(mockMunroState.selectedMunro).thenReturn(sampleMunro);
  });

  group('WeatherState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(weatherState.status, WeatherStatus.initial);
        expect(weatherState.error, isA<Error>());
        expect(weatherState.forecast, isEmpty);
      });
    });

    group('getWeather', () {
      test('should fetch weather successfully with metric units', () async {
        // Arrange
        when(mockSettingsState.metricTemperature).thenReturn(true);
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => sampleForecast);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.loaded);
        expect(weatherState.forecast, sampleForecast);
        expect(weatherState.forecast.length, 3);
        verify(mockWeatherRepository.fetchWeather(
          lat: sampleMunro.lat,
          lon: sampleMunro.lng,
          metric: 'metric',
          apiKey: anyNamed('apiKey'),
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should fetch weather successfully with imperial units', () async {
        // Arrange
        when(mockSettingsState.metricTemperature).thenReturn(false);
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => sampleForecast);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.loaded);
        expect(weatherState.forecast, sampleForecast);
        verify(mockWeatherRepository.fetchWeather(
          lat: sampleMunro.lat,
          lon: sampleMunro.lng,
          metric: 'imperial',
          apiKey: anyNamed('apiKey'),
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should return early if no munro is selected', () async {
        // Arrange
        when(mockMunroState.selectedMunro).thenReturn(null);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.initial);
        expect(weatherState.forecast, isEmpty);
        verifyNever(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        ));
      });

      test('should handle error during weather fetch', () async {
        // Arrange
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenThrow(Exception('Network error'));

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.error);
        expect(weatherState.error.message, 'There was an error fetching the weather data.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleForecast;
        });

        // Act
        final future = weatherState.getWeather();

        // Allow event loop to process
        await Future.delayed(Duration(milliseconds: 10));

        // Assert intermediate state
        expect(weatherState.status, WeatherStatus.loading);

        // Wait for completion
        await future;
        expect(weatherState.status, WeatherStatus.loaded);
      });

      test('should use correct coordinates from selected munro', () async {
        // Arrange
        final customMunro = Munro(
          id: 2,
          name: 'Ben Lomond',
          extra: null,
          area: 'Loch Lomond',
          meters: 974,
          section: 'Loch Lomond to Loch Tay',
          region: 'Southern Highlands',
          feet: 3196,
          lat: 56.1897,
          lng: -4.6340,
          link: 'https://example.com/ben-lomond.shtml',
          description: 'A popular Munro near Glasgow',
          pictureURL: 'https://example.com/ben-lomond.jpg',
          startingPointURL: 'https://example.com/start.jpg',
        );
        when(mockMunroState.selectedMunro).thenReturn(customMunro);
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => sampleForecast);

        // Act
        await weatherState.getWeather();

        // Assert
        verify(mockWeatherRepository.fetchWeather(
          lat: customMunro.lat,
          lon: customMunro.lng,
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).called(1);
      });

      test('should clear previous forecast when fetching new weather', () async {
        // Arrange - Set initial forecast
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => sampleForecast);

        await weatherState.getWeather();
        expect(weatherState.forecast.length, 3);

        // Arrange - New shorter forecast
        final newForecast = [sampleForecast.first];
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => newForecast);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.forecast.length, 1);
        expect(weatherState.forecast, newForecast);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        weatherState.setStatus = WeatherStatus.loading;
        expect(weatherState.status, WeatherStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test_code', message: 'test error');
        weatherState.setError = error;

        expect(weatherState.status, WeatherStatus.error);
        expect(weatherState.error, error);
      });
    });

    group('Edge Cases', () {
      test('should handle empty forecast list', () async {
        // Arrange
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => []);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.loaded);
        expect(weatherState.forecast, isEmpty);
      });

      test('should handle single day forecast', () async {
        // Arrange
        final singleDayForecast = [sampleForecast.first];
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => singleDayForecast);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.loaded);
        expect(weatherState.forecast.length, 1);
        expect(weatherState.forecast.first, sampleForecast.first);
      });

      test('should handle HTTP error with specific error message', () async {
        // Arrange
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenThrow(Exception('Failed to load weather data'));

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.error);
        expect(weatherState.error.message, 'There was an error fetching the weather data.');
        expect(weatherState.error.code, contains('Failed to load weather data'));
      });

      test('should handle munro with extreme coordinates', () async {
        // Arrange
        final extremeMunro = Munro(
          id: 3,
          name: 'Test Munro',
          extra: null,
          area: 'Test Area',
          meters: 1000,
          section: 'Test Section',
          region: 'Test Region',
          feet: 3280,
          lat: 90.0, // Extreme latitude
          lng: 180.0, // Extreme longitude
          link: 'https://example.com/test.shtml',
          description: 'A test munro',
          pictureURL: 'https://example.com/test.jpg',
          startingPointURL: 'https://example.com/start.jpg',
        );
        when(mockMunroState.selectedMunro).thenReturn(extremeMunro);
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => sampleForecast);

        // Act
        await weatherState.getWeather();

        // Assert
        verify(mockWeatherRepository.fetchWeather(
          lat: 90.0,
          lon: 180.0,
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).called(1);
      });

      test('should handle weather with zero values', () async {
        // Arrange
        final zeroValueWeather = [
          Weather(
            date: DateTime(2025, 12, 24, 12, 0),
            sunrise: DateTime(2025, 12, 24, 8, 0),
            sunset: DateTime(2025, 12, 24, 16, 0),
            summary: 'Calm',
            temperature: 0.0,
            temperatureMin: 0.0,
            temperatureMax: 0.0,
            windSpeed: 0.0,
            humidity: 0,
            description: 'No weather',
            rain: 0.0,
            icon: '01d',
          ),
        ];
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => zeroValueWeather);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(weatherState.status, WeatherStatus.loaded);
        expect(weatherState.forecast.first.temperature, 0.0);
        expect(weatherState.forecast.first.windSpeed, 0.0);
        expect(weatherState.forecast.first.humidity, 0);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when fetching weather', () async {
        // Arrange
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => sampleForecast);

        bool notified = false;
        weatherState.addListener(() => notified = true);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        weatherState.addListener(() => notified = true);

        weatherState.setStatus = WeatherStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        weatherState.addListener(() => notified = true);

        weatherState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners multiple times during fetch', () async {
        // Arrange
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return sampleForecast;
        });

        int notificationCount = 0;
        weatherState.addListener(() => notificationCount++);

        // Act
        await weatherState.getWeather();

        // Assert - should be notified at least twice (loading and loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when error is set', () async {
        // Arrange
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenThrow(Exception('Test error'));

        bool notified = false;
        weatherState.addListener(() => notified = true);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(notified, true);
        expect(weatherState.status, WeatherStatus.error);
      });
    });

    group('Status Transitions', () {
      test('should transition from initial to loading to loaded', () async {
        // Arrange
        final List<WeatherStatus> statusChanges = [];
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return sampleForecast;
        });

        weatherState.addListener(() {
          statusChanges.add(weatherState.status);
        });

        // Assert initial
        expect(weatherState.status, WeatherStatus.initial);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(statusChanges, contains(WeatherStatus.loading));
        expect(statusChanges, contains(WeatherStatus.loaded));
        expect(weatherState.status, WeatherStatus.loaded);
      });

      test('should transition from initial to loading to error on failure', () async {
        // Arrange
        final List<WeatherStatus> statusChanges = [];
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenThrow(Exception('Error'));

        weatherState.addListener(() {
          statusChanges.add(weatherState.status);
        });

        // Assert initial
        expect(weatherState.status, WeatherStatus.initial);

        // Act
        await weatherState.getWeather();

        // Assert
        expect(statusChanges, contains(WeatherStatus.loading));
        expect(statusChanges, contains(WeatherStatus.error));
        expect(weatherState.status, WeatherStatus.error);
      });

      test('should transition from loaded to loading when fetching again', () async {
        // Arrange - First fetch
        when(mockWeatherRepository.fetchWeather(
          lat: anyNamed('lat'),
          lon: anyNamed('lon'),
          metric: anyNamed('metric'),
          apiKey: anyNamed('apiKey'),
        )).thenAnswer((_) async => sampleForecast);

        await weatherState.getWeather();
        expect(weatherState.status, WeatherStatus.loaded);

        final List<WeatherStatus> statusChanges = [];
        weatherState.addListener(() {
          statusChanges.add(weatherState.status);
        });

        // Act - Second fetch
        await weatherState.getWeather();

        // Assert
        expect(statusChanges.first, WeatherStatus.loading);
        expect(statusChanges.last, WeatherStatus.loaded);
      });
    });
  });
}
