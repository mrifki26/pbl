class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "http://34.231.237.42:8085",
  );

  static const requestTimeout = Duration(seconds: 10);

  static const authUrl = "$baseUrl/api/auth";
  static const soilUrl = "$baseUrl/api/soil";
  static const temperatureUrl = "$baseUrl/api/temperature";
  static const controlUrl = "$baseUrl/api/control";
}
