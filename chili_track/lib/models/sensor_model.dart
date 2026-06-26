class SensorModel {
  final double soil;
  final double temp;

  SensorModel({required this.soil, required this.temp});

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      soil: (json['soilMoisture'] as num).toDouble(),
      temp: (json['temperature'] as num).toDouble(),
    );
  }
}
