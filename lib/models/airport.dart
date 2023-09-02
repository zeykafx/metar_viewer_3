class Airport {
  String icao;
  double latitude;
  double longitude;
  String state;
  String facility;
  String type;
  String frequency;
  double msl;
  List<String> runways;
  List<Frequency> frequencies;

  Airport(
    this.icao,
    this.latitude,
    this.longitude,
    this.state,
    this.facility,
    this.type,
    this.frequency,
    this.msl,
    this.runways,
    this.frequencies,
  );

  static fromDb(Map<String, dynamic> data) {
    List<String> runwayData = data['Runways'].split(",") ?? [];

    List<Frequency> frequencies = [];
    if (data["Freq_names"] != "") {
      List<String> freqs = data['Freq_names'].split(":");
      List<String> freqData = data['Freq_data'].split(":");

      for (int i = 0; i < data['Freq_names'].split(":").length; i++) {
        frequencies.add(Frequency(freqs[i], freqData[i]));
      }
    }

    return Airport(
      data['NavId'],
      data['Latitude'],
      data['Longitude'],
      data['State'],
      data['Facility'],
      data['Type'],
      data['Freq'],
      data['MSL'],
      runwayData,
      frequencies,
    );
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
