class AppConfig {
  static const String version = '1.0.1'; // Define the app version here

  final String apiUrl;
  final String environment;

  AppConfig({
    required this.apiUrl,
    required this.environment,
  });
}
