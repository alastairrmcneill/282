enum AppEnvironment { dev, prod }

class AppConfig {
  final AppEnvironment env;

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String mapboxToken;
  final String sentryDsn;
  final String mixpanelToken;
  final String weatherApiKey;

  const AppConfig({
    required this.env,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.mapboxToken,
    required this.sentryDsn,
    required this.mixpanelToken,
    required this.weatherApiKey,
  });

  static AppConfig fromEnvironment() {
    const envStr = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final env = envStr == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON');
    const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const mixpanelToken = String.fromEnvironment('MIXPANEL_TOKEN');
    const weatherApiKey = String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');

    return AppConfig(
      env: env,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      mapboxToken: mapboxToken,
      sentryDsn: sentryDsn,
      mixpanelToken: mixpanelToken,
      weatherApiKey: weatherApiKey,
    );
  }

  @override
  String toString() {
    return '''AppConfig(env: $env, 
                        supabaseUrl: $supabaseUrl, 
                        supabaseAnonKey: $supabaseAnonKey, 
                        mapboxToken: $mapboxToken, 
                        sentryDsn: $sentryDsn, 
                        mixpanelToken: $mixpanelToken, 
                        weatherApiKey: $weatherApiKey)''';
  }
}
