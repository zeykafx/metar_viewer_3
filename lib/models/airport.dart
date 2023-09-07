class Airport {
  String icao;
  double latitude;
  double longitude;
  String state;
  String facility;
  String type;
  String asosFreq; // Automated Surface Observing Systems
  String ctafFreq;
  String gndFreq;
  String towerFreq;
  double msl;
  List<Runway> runways;
  List<Frequency> frequencies;

  Airport(
    this.icao,
    this.latitude,
    this.longitude,
    this.state,
    this.facility,
    this.type,
    this.asosFreq,
    this.ctafFreq,
    this.gndFreq,
    this.towerFreq,
    this.msl,
    this.runways,
    this.frequencies,
  );

  static fromDb(Map<String, dynamic> data) {
    int numRunways = data['NumRunways'] ?? 0;
    List<Runway> runways = [];
    if (data["Runways"] != "") {
      List<String> runwayPair = data['Runways'].split(",");
      for (int i = 0; i < numRunways; i++) {
        // format for data["field"]: NumRunways = 2, Runways = "18/36,H1/H1", Lengths = "2536,40", Widths = "250,40", Surfaces = "TURF,GRASS"
        List<String> runwayName = runwayPair[i].split("/"); // ["18", "36"]
        String runwayLengths = data['Lengths'].split(",")[i]; // "2536"
        String runwayWidths = data['Widths'].split(",")[i]; // "250"
        String runwaySurfaces = data['Surfaces'].split(",")[i]; // "TURF"

        int runwayAngle1 = 0;
        int runwayAngle2 = 0;

        if (runwayName
                .map((e) => e.contains(RegExp(r"^[RL]+$")))
                .contains(true) ||
            runwayName
                .map((e) => e.contains(RegExp(r'^[0-9]+$')))
                .contains(true)) {
          // remove any letter from the runway name to get the runway angle
          int runwayAngle1 =
              int.parse(runwayName[0].replaceAll(RegExp(r"[A-Z]"), "")) *
                  10; // 180
          int runwayAngle2 =
              int.parse(runwayName[1].replaceAll(RegExp(r"[A-Z]"), "")) *
                  10; // 360
        }

        String name = "";
        if (runwayName.length > 1) {
          name = "${runwayName[0]}/${runwayName[1]}";
        } else {
          name = runwayName[0];
        }

        runways.add(Runway(
          name,
          (runwayAngle1, runwayAngle2),
          runwayLengths,
          runwayWidths,
          runwaySurfaces,
        ));
      }
    }

    List<Frequency> frequencies = [];
    if (data["Freq_names"] != "") {
      List<String> freqs = data['Freq_names'].split(":");
      List<String> freqData = data['Freq_data'].split(":");

      for (int i = 0; i < freqs.length; i++) {
        frequencies.add(Frequency(freqs[i], freqData[i]));
      }
    }

    return Airport(
      data['NavId'] ?? "",
      data['Latitude'] ?? 0.0,
      data['Longitude'] ?? 0.0,
      data['State'] ?? "",
      data['Facility'] ?? "",
      data['Type'] ?? "",
      data['Freq'].trim() ?? "",
      data['CTAF'].trim() ?? "",
      data['TWR'].trim() ?? "",
      data['GND'].trim() ?? "",
      data['MSL'] ?? 0.0,
      runways,
      frequencies,
    );
  }

  @override
  String toString() {
    return "$icao: ($latitude, $longitude), $state, $facility, $type, $asosFreq, $ctafFreq, $gndFreq, $towerFreq, $msl, $runways, $frequencies";
  }
}

class Runway {
  String name;
  (int, int) angle;
  String length;
  String width;
  String surface;

  Runway(this.name, this.angle, this.length, this.width, this.surface);

  @override
  String toString() {
    return "$name: $angle, $length, $width, $surface";
  }
}

class Frequency {
  String name;
  String frequency;

  Frequency(this.name, this.frequency);

  @override
  String toString() {
    return "$name: $frequency";
  }
}
