class Taf {
  final String raw;
  final String sanitized;
  final String station;
  final DateTime time;
  final String remarks;
  final List<TafForecast> forecast;
  final DateTime startTime;
  final DateTime endTime;
  final String maxTemp;
  final String minTemp;

  Taf(
    this.raw,
    this.sanitized,
    this.station,
    this.time,
    this.remarks,
    this.forecast,
    this.startTime,
    this.endTime,
    this.maxTemp,
    this.minTemp,
  );

  static Taf fromJson(Map<String, dynamic> json) {
    return Taf(
      json['raw'] ?? "",
      json['sanitized'] ?? "",
      json['station'] ?? "",
      DateTime.parse(json['time']['dt']),
      json['remarks'] ?? "",
      json['forecast'].map<TafForecast>((forecast) => TafForecast.fromJson(forecast)).toList(),
      DateTime.parse(json['start_time']['dt']),
      DateTime.parse(json['end_time']['dt']),
      json['max_temp'] ?? "",
      json['min_temp'] ?? "",
    );
  }
}

class TafForecast {
  final String altimeter;
  // final List<CloudLayer> clouds;
  final String flightRules;
  final String sanitized;
  // final Visibility? visibility;
  // final Wind? windDirection;
  // final Wind? windGust;
  // final Wind? windSpeed;
  final List<WxCode>? wxCodes;
  final DateTime endTime;
  // final dynamic probability;
  final String raw;
  final DateTime startTime;
  // final List<dynamic> turbulence;
  final String type;
  // final dynamic windShear;
  final String summary;

  TafForecast(
    this.altimeter,
    // this.clouds,
    this.flightRules,
    this.sanitized,
    // this.visibility,
    // this.windDirection,
    // this.windGust,
    // this.windSpeed,
    this.wxCodes,
    this.endTime,
    // this.probability,
    this.raw,
    this.startTime,
    // this.turbulence,
    this.type,
    // this.windShear,
    this.summary,
  );

  static TafForecast fromJson(Map<String, dynamic> json) {
    // List<CloudLayer> clouds = [];
    // if (json['clouds'] != null) {
    //   for (var cloud in json['clouds']) {
    //     clouds.add(CloudLayer(
    //       cloud['repr'],
    //       cloud['type'],
    //       cloud['altitude'],
    //       cloud['modifier'],
    //     ));
    //   }
    // }
    List<WxCode> wxCodes = [];
    if (json['wx_codes'] != null) {
      for (var wxCode in json['wx_codes']) {
        wxCodes.add(WxCode(
          wxCode['repr'],
          wxCode['value'],
        ));
      }
    }
    return TafForecast(
      json['altimeter'] ?? "",
      // clouds,
      json['flight_rules'] ?? "",
      json['sanitized'] ?? "",
      // json['visibility'] != null
      //     ? Visibility(
      //         json['visibility']['repr'],
      //         json['visibility']['value'],
      //         json['visibility']['spoken'],
      //       )
      //     : null,
      // json['wind_direction'] != null
      //     ? Wind(
      //         json['wind_direction']['repr'],
      //         json['wind_direction']['value'],
      //         json['wind_direction']['spoken'],
      //       )
      //     : null,
      // json["wind_gust"] != null
      //     ? Wind(
      //         json['wind_gust']['repr'],
      //         json['wind_gust']['value'],
      //         json['wind_gust']['spoken'],
      //       )
      //     : null,
      // json['wind_speed'] != null
      //     ? Wind(
      //         json['wind_speed']['repr'],
      //         json['wind_speed']['value'],
      //         json['wind_speed']['spoken'],
      //       )
      //     : null,
      wxCodes,
      // DateTime.parse(json['end_time']['dt']),
      DateTime.parse(json['end_time']['dt']),
      json['raw'] ?? "",
      // DateTime.parse(json['start_time']['dt']),
      // json['turbulence'] ?? "",
      DateTime.parse(json['start_time']['dt']),
      json['type'] ?? "",
      json['summary'] ?? "",
    );
  }
}

class WxCode {
  final String repr;
  final String value;

  WxCode(
    this.repr,
    this.value,
  );
}
