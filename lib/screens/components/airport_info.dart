import 'package:flutter/material.dart';
import 'package:metar_viewer_3/models/airport.dart';

class AirportInfo extends StatelessWidget {
  final Airport airport;
  const AirportInfo({super.key, required this.airport});

  @override
  Widget build(BuildContext context) {
    String frequencies = "";
    for (Frequency frequency in airport.frequencies) {
      frequencies += "${frequency.name} ${frequency.frequency}\n";
    }
    // trim the tailing newline
    frequencies = frequencies.trim();

    String runways = "";
    for (Runway runway in airport.runways) {
      runways += "${runway.name} ${runway.length}ft x ${runway.width}ft\n";
    }
    runways = runways.trim();

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
                        "${airport.icao} - ${airport.facility}, ${airport.state} (${airport.type})"),
                    // Airport elevation
                    Text(
                      "Elevation",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).dividerColor,
                          ),
                    ),
                    Text("${airport.msl}ft MSL (elevation)"),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
