import 'dart:convert';

class Metar {
  String? raw;
  String? station;
  DateTime? observationTime;
  DateTime? time;
  String? windDirection;
  String? windSpeed;
  String? windGust;
  String? visibility;
  String? temperature;
  String? dewpoint;
  String? altimeter;
  bool? altIsInHg;
  String? flightRules;
  List<String>? cloudLayers;
  String? remarks;

  Metar({
    required this.raw,
    required this.station,
    this.observationTime,
    this.time,
    this.windDirection,
    this.windSpeed,
    this.windGust,
    this.visibility,
    this.temperature,
    this.dewpoint,
    this.altimeter,
    this.altIsInHg,
    this.flightRules,
    this.cloudLayers,
    this.remarks,
  });

  static Metar fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    String raw = json['raw'];
    String station = json['station'];
    DateTime observationTime = DateTime.parse(json['time']['dt']);
    DateTime time = DateTime.parse(json['meta']['timestamp']);
    String windDirection = json['wind_direction']['repr'] ?? "";
    String windSpeed = json['wind_speed']['repr'] ?? "0";
    String windGust =
        json['wind_gust'] != null ? json['wind_gust']['repr'] : "/";
    String visibility = json['visibility']['repr'] ?? "9999";
    String temperature = json['temperature']['repr'] ?? "?";
    String dewpoint = json['dewpoint']['repr'] ?? "?";
    String altimeter = json['altimeter']['repr'] ?? "?";
    bool altIsInHg = json['units']['altimeter'] == 'inHg';
    String flightRules = json['flight_rules'] ?? "?";
    String remarks = json['remarks'] ?? "";

    List<String> cloudLayers = [];
    for (var layer in json['clouds']) {
      cloudLayers.add(layer['repr']);
    }

    return Metar(
      raw: raw,
      station: station,
      observationTime: observationTime,
      time: time,
      windDirection: windDirection,
      windSpeed: windSpeed,
      windGust: windGust,
      visibility: visibility,
      temperature: temperature,
      dewpoint: dewpoint,
      altimeter: altimeter,
      altIsInHg: altIsInHg,
      flightRules: flightRules,
      cloudLayers: cloudLayers,
      remarks: remarks,
    );
  }
}
