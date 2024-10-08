import 'dart:convert';

import 'airport.dart';

class Metar {
  String raw;
  String summary;
  String station;
  Airport airport;

  DateTime observationTime;
  DateTime time;
  int windDirection;
  String windSpeed;
  String windGust;
  String visibility;
  String visiblityUnits;
  String temperature;
  String dewpoint;
  String temperatureUnits;
  String altimeter;
  bool altIsInHg;
  String flightRules;
  List<CloudLayer> cloudLayers;
  String remarks;
  String remarksTranslations;

  Metar({
    required this.raw,
    required this.summary,
    required this.station,
    required this.airport,
    required this.observationTime,
    required this.time,
    required this.windDirection,
    required this.windSpeed,
    required this.windGust,
    required this.visibility,
    required this.visiblityUnits,
    required this.temperature,
    required this.temperatureUnits,
    required this.dewpoint,
    required this.altimeter,
    required this.altIsInHg,
    required this.flightRules,
    required this.cloudLayers,
    required this.remarks,
    required this.remarksTranslations,
  });

  static Metar fromJson(Map<String, dynamic> json, Airport airport) {
    // Map<String, dynamic> json = jsonDecode(jsonString);
    String raw = json['raw'] ?? "";
    String summary = json['summary'] ?? "";
    String station = json['station'] ?? "";
    DateTime observationTime = DateTime.parse(json['time']['dt']) ?? DateTime.now();
    DateTime time = DateTime.parse(json['meta']['timestamp']);
    int windDirection = json['wind_direction']['value'] ?? 0;
    String windSpeed = json['wind_speed']['repr'] ?? "0";
    String windGust = json['wind_gust'] != null ? json['wind_gust']['repr'] : "/";
    String visibility = json['visibility']['repr'] ?? "9999";
    String visiblityUnits = json['units']['visibility'] ?? "sm";
    String temperature = json['temperature']['repr'] ?? "?";
    String dewpoint = json['dewpoint']['repr'] ?? "?";
    String temperatureUnits = json['units']['temperature'] ?? "C";
    String altimeter = json['altimeter']['value'].toString() ?? "?";
    bool altIsInHg = json['units']['altimeter'] == 'inHg';
    String flightRules = json['flight_rules'] ?? "?";
    String remarks = json['remarks'] ?? "";

    List<CloudLayer> cloudLayers = [];
    if (json['clouds'] != null) {
      for (var layer in json['clouds']) {
        cloudLayers.add(CloudLayer(
          repr: layer['repr'],
          type: layer['type'],
          altitude: layer['altitude'] ?? 0,
          modifier: layer['modifier'],
          direction: layer['direction'],
        ));
      }
    }

    String remarksTranslations = "";
    if (json["translate"] != null) {
      for (var key in json["translate"]["remarks"].keys) {
        String value = json["translate"]["remarks"][key];
        remarksTranslations += "$key: $value, ";
      }
    }

    if (remarksTranslations.isEmpty) {
      remarksTranslations = json["remarks"];
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
      remarksTranslations: remarksTranslations,
    );
  }
}

class CloudLayer {
  //    {
  //       "repr": "OVC046",
  //       "type": "OVC",
  //       "altitude": 46,
  //       "modifier": null,
  //       "direction": null
  //     }

  String repr;
  String type;
  int altitude;
  String? modifier;
  String? direction;

  CloudLayer({
    required this.repr,
    required this.type,
    required this.altitude,
    this.modifier,
    this.direction,
  });

  String cloudTypeToReadableString(String cloudType) {
    switch (cloudType.toUpperCase()) {
      case "FEW":
        return "Few";
      case "SCT":
        return "Scattered";
      case "BKN":
        return "Broken";
      case "OVC":
        return "Overcast";
      case "SKC":
        return "Sky Clear";
      case "CLR":
        return "Clear";
      case "SKT":
        return "Scattered Clouds";
      case "VV":
        return "Vertical Visibility";
      default:
        return "Unknown";
    }
  }

  String modifierToReadableString(String modifier) {
    switch (modifier.toUpperCase()) {
      case "CB":
        return "Cumulonimbus";
      case "TCU":
        return "Towering Cumulus";
      case "CI":
        return "Cirrus";
      case "CS":
        return "Cirrostratus";
      case "SC":
        return "Stratocumulus";
      case "AC":
        return "Altocumulus";
      case "AS":
        return "Altostratus";
      case "NS":
        return "Nimbostratus";
      case "CU":
        return "Cumulus";
      case "CC":
        return "Cirrocumulus";
      case "ST":
        return "Stratus";
      default:
        return "Unknown";
    }
  }

  @override
  String toString() {
    if (altitude == 0) {
      return cloudTypeToReadableString(type) + (modifier != null ? " ${modifierToReadableString(modifier!)}" : "");
    }
    return "${cloudTypeToReadableString(type)} at ${altitude}00 feet";
  }
}
