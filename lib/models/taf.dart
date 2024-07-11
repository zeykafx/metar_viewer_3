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
  final Map<String, String> units;

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
    this.units,
  );
}

class TafForecast {
  final String altimeter;
  final List<CloudLayer> clouds;
  final String flightRules;
  final String sanitized;
  final Visibility visibility;
  final Wind windDirection;
  final Wind windGust;
  final Wind windSpeed;
  final List<WxCode> wxCodes;
  final DateTime endTime;
  final List<dynamic> icing;
  final dynamic probability;
  final String raw;
  final DateTime startTime;
  final List<dynamic> turbulence;
  final String type;
  final dynamic windShear;
  final String summary;

  TafForecast(
    this.altimeter,
    this.clouds,
    this.flightRules,
    this.sanitized,
    this.visibility,
    this.windDirection,
    this.windGust,
    this.windSpeed,
    this.wxCodes,
    this.endTime,
    this.icing,
    this.probability,
    this.raw,
    this.startTime,
    this.turbulence,
    this.type,
    this.windShear,
    this.summary,
  );
}

class CloudLayer {
  final String repr;
  final String type;
  final int altitude;
  final String? modifier;
  final String? direction;

  CloudLayer(
    this.repr,
    this.type,
    this.altitude,
    this.modifier,
    this.direction,
  );
}

class Visibility {
  final String repr;
  final int? value;
  final String spoken;

  Visibility(
    this.repr,
    this.value,
    this.spoken,
  );
}

class Wind {
  final String repr;
  final int value;
  final String spoken;

  Wind(
    this.repr,
    this.value,
    this.spoken,
  );
}

class WxCode {
  final String repr;
  final String value;

  WxCode(
    this.repr,
    this.value,
  );
}
