import 'package:flutter/material.dart';
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/models/metar.dart';

class AirportInfo extends StatefulWidget {
  final Airport airport;
  final Metar metar;
  const AirportInfo({super.key, required this.airport, required this.metar});

  @override
  State<AirportInfo> createState() => _AirportInfoState();
}

class _AirportInfoState extends State<AirportInfo> {
  String frequencies = "";
  String runways = "";

  void setupFrequenciesAndRunways() {
    for (Frequency frequency in widget.airport.frequencies) {
      frequencies += "${frequency.name} ${frequency.frequency}\n";
    }
    // trim the tailing newline
    frequencies = frequencies.trim();

    for (Runway runway in widget.airport.runways) {
      runways += "${runway.name} ${runway.length}ft x ${runway.width}ft\n";
    }
    runways = runways.trim();
  }

  @override
  void initState() {
    super.initState();

    setupFrequenciesAndRunways();
  }

  @override
  Widget build(BuildContext context) {
    // return Card(
    //   child: Column(
    //     children: [
    //       // Airport name
    //       Text("${airport.icao} - ${airport.facility}"),
    //       // Airport location
    //       Text(airport.state),
    //       // Airport type
    //       Text(airport.type),
    //       // Airport elevation
    //       Text("${airport.msl}ft MSL"),
    //       // Airport frequencies
    //       Text(frequencies),
    //       // Airport runways
    //       Text(runways),
    //     ],
    //   ),
    // );
    return Column(
      children: [
        Row(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 22.0,
                ),
                child: Column(
                  children: [
                    // Airport name, state, type
                    Text(
                        "${widget.airport.icao} - ${widget.airport.facility}, ${widget.airport.state} (${widget.airport.type})"),
                    // Airport elevation
                    Text(
                      "Elevation",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).dividerColor,
                          ),
                    ),
                    Text("${widget.airport.msl}ft MSL (elevation)"),
                    Text(
                      "Runways",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).dividerColor,
                          ),
                    ),
                    // Airport runways
                    for (Runway runway in widget.airport.runways)
                      Text(
                        "${runway.name} ${runway.length}ft x ${runway.width}ft",
                      ),
                  ],
                ),
              ),
            ),
            BestRunwayForWinds(airport: widget.airport, metar: widget.metar),
          ],
        )
      ],
    );
  }
}

class BestRunwayForWinds extends StatelessWidget {
  final Airport airport;
  final Metar metar;
  const BestRunwayForWinds(
      {super.key, required this.airport, required this.metar});

  @override
  Widget build(BuildContext context) {
    Runway bestRunwayForWinds = airport.runways[0];
    String bestRunwayName = "";
    for (Runway runway in airport.runways) {
      var (angleRunway0, angleRunway1) = runway.angle;
      var (angleCurrentBestRunway0, angleCurrentBestRunway1) =
          bestRunwayForWinds.angle;

      // find the runway that is closest to the wind direction
      // the two angles are the two ends of the runway, use that to find the best runway
      var diffRunway0 = (metar.windDirection - angleRunway0).abs();
      var diffRunway1 = (metar.windDirection - angleRunway1).abs();
      var diffCurrentBestRunway0 =
          (metar.windDirection - angleCurrentBestRunway0).abs();
      var diffCurrentBestRunway1 =
          (metar.windDirection - angleCurrentBestRunway1).abs();

      if (diffRunway0 <= diffCurrentBestRunway0) {
        bestRunwayForWinds = runway;
        RegExp runwayNameRegex = RegExp("[0]?${angleRunway0 ~/ 10}[L|R]?");
        bestRunwayName = runwayNameRegex.stringMatch(runway.name) ?? "";
      } else if (diffRunway1 <= diffCurrentBestRunway1) {
        bestRunwayForWinds = runway;

        RegExp runwayNameRegex = RegExp("[0]?${angleRunway1 ~/ 10}[L|R]?");
        bestRunwayName = runwayNameRegex.stringMatch(runway.name) ?? "";
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 28.0,
          vertical: 22.0,
        ),
        child: Column(
          children: [
            Text(
              "Best runway for winds",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).dividerColor,
                  ),
            ),
            Text(
              "$bestRunwayName ${bestRunwayForWinds.length}ft x ${bestRunwayForWinds.width}ft",
            ),
          ],
        ),
      ),
    );
  }
}
