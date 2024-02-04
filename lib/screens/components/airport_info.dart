import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/models/metar.dart';
import "package:vector_math/vector_math.dart" as vector;

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
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Column(
      children: [
        IntrinsicHeight(
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: mediaQuery.size.width > 600 ? Axis.horizontal : Axis.vertical,
            children: [
              Flexible(
                flex: mediaQuery.size.width > 600 ? 1 : 0,
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
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
                            RichText(
                                text: TextSpan(
                              children: [
                                TextSpan(
                                  text: runway.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextSpan(
                                  text: ": ",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                TextSpan(text: "${runway.length}ft", style: Theme.of(context).textTheme.bodyMedium),
                                TextSpan(
                                  text: " x ",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                TextSpan(
                                  text: "${runway.width}ft",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: BestRunwayForWinds(airport: widget.airport, metar: widget.metar),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class BestRunwayForWinds extends StatelessWidget {
  final Airport airport;
  final Metar metar;

  const BestRunwayForWinds({super.key, required this.airport, required this.metar});

  String getBestRunwayUrl(int angle) {
    // https://metar-taf.com/images/rwy/day-18.svg
    // the angle for the site goes from 0 to 18, so if we need more than 18 we use the opposite runway
    // (e.g. if we need 22, we use 4)
    int angleForSite = angle ~/ 10;
    if (angleForSite > 18) {
      angleForSite = angleForSite - 18;
    }
    return "https://metar-taf.com/images/rwy/day-$angleForSite.svg";
  }

  @override
  Widget build(BuildContext context) {
    Runway bestRunwayForWinds = airport.runways[0];
    String bestRunwayName = "";
    int bestRunwayAngle = 0;
    String bestRunwayUrl = "";

    for (Runway runway in airport.runways) {
      var (int angleRunway0, int angleRunway1) = runway.angle;
      var (int angleCurrentBestRunway0, int angleCurrentBestRunway1) = bestRunwayForWinds.angle;

      // find the runway that is closest to the wind direction
      // the two angles are the two ends of the runway, use that to find the best runway
      int diffRunway0 = (metar.windDirection - angleRunway0).abs();
      int diffRunway1 = (metar.windDirection - angleRunway1).abs();
      int diffCurrentBestRunway0 = (metar.windDirection - angleCurrentBestRunway0).abs();
      int diffCurrentBestRunway1 = (metar.windDirection - angleCurrentBestRunway1).abs();

      if (diffRunway0 <= diffCurrentBestRunway0) {
        bestRunwayForWinds = runway;
        // find the runway name in the format of 36L/18R
        // in order to find it, we have an optional 0 if there is only one digit
        // we also divide the angle by 10 to get the runway number,
        // and we can also have an optional L or R at the end
        RegExp runwayNameRegex = RegExp("[0]?${angleRunway0 ~/ 10}[L|R]?");
        bestRunwayName = runwayNameRegex.stringMatch(runway.name) ?? "";

        // set the runway angle, this is used to rotate the runway image
        bestRunwayAngle = angleRunway0;
      } else if (diffRunway1 <= diffCurrentBestRunway1) {
        bestRunwayForWinds = runway;

        RegExp runwayNameRegex = RegExp("[0]?${angleRunway1 ~/ 10}[LR]?");
        bestRunwayName = runwayNameRegex.stringMatch(runway.name) ?? "";

        bestRunwayAngle = angleRunway1;
      }
    }

    bestRunwayUrl = getBestRunwayUrl(bestRunwayAngle);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 28.0,
          vertical: 18.0,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/compass.svg",
                    width: 250,
                    alignment: Alignment.center,
                  ),
                  Transform.rotate(
                    angle: vector.radians(bestRunwayAngle.toDouble()),
                    child: SvgPicture.network(
                      bestRunwayUrl,
                      width: 250,
                      alignment: Alignment.center,
                    ),
                  ),

                  // wind direction
                  Transform.rotate(
                    angle: vector.radians(metar.windDirection.toDouble() - 180),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 100,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
