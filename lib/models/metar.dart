import 'dart:convert';

import 'airport.dart';

class Metar {
  String raw;
  String summary;
  String station;
  Airport airport;

  DateTime? observationTime;
  DateTime? time;
  String? windDirection;
  String? windSpeed;
  String? windGust;
  String? visibility;
  String? visiblityUnits;
  String? temperature;
  String? dewpoint;
  String? temperatureUnits;
  String? altimeter;
  bool? altIsInHg;
  String? flightRules;
  List<String>? cloudLayers;
  String? remarks;

  Metar({
    required this.raw,
    required this.summary,
    required this.station,
    required this.airport,
    this.observationTime,
    this.time,
    this.windDirection,
    this.windSpeed,
    this.windGust,
    this.visibility,
    this.visiblityUnits,
    this.temperature,
    this.temperatureUnits,
    this.dewpoint,
    this.altimeter,
    this.altIsInHg,
    this.flightRules,
    this.cloudLayers,
    this.remarks,
  });

  static Metar fromJson(String jsonString, Airport airport) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    String raw = json['raw'];
    String summary = json['summary'];
    String station = json['station'];
    DateTime observationTime = DateTime.parse(json['time']['dt']);
    DateTime time = DateTime.parse(json['meta']['timestamp']);
    String windDirection = json['wind_direction']['repr'] ?? "";
    String windSpeed = json['wind_speed']['repr'] ?? "0";
    String windGust =
        json['wind_gust'] != null ? json['wind_gust']['repr'] : "/";
    String visibility = json['visibility']['repr'] ?? "9999";
    String visiblityUnits = json['units']['visibility'] ?? "sm";
    String temperature = json['temperature']['repr'] ?? "?";
    String dewpoint = json['dewpoint']['repr'] ?? "?";
    String temperatureUnits = json['units']['temperature'] ?? "C";
    String altimeter = json['altimeter']['value'].toString() ?? "?";
    bool altIsInHg = json['units']['altimeter'] == 'inHg';
    String flightRules = json['flight_rules'] ?? "?";
    String remarks = json['remarks'] ?? "";

    List<String> cloudLayers = [];
    for (var layer in json['clouds']) {
      cloudLayers.add(layer['repr']);
    }

    return Metar(
      raw: raw,
      summary: summary,
      station: station,
      airport: airport,
      observationTime: observationTime,
      time: time,
      windDirection: windDirection,
      windSpeed: windSpeed,
      windGust: windGust,
      visibility: visibility,
      visiblityUnits: visiblityUnits,
      temperature: temperature,
      dewpoint: dewpoint,
      temperatureUnits: temperatureUnits,
      altimeter: altimeter,
      altIsInHg: altIsInHg,
      flightRules: flightRules,
      cloudLayers: cloudLayers,
      remarks: remarks,
    );
  }
}
