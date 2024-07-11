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
                            "${widget.airport.icao} - ${widget.airport.facility}, ${widget.airport.state} (${widget.airport.type})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  TextSpan(
                                    text: ": ",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                  ),
                                  TextSpan(
                                    text: "${runway.length}ft",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  TextSpan(
                                    text: " x ",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                  ),
                                  TextSpan(
                                    text: "${runway.width}ft",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
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
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 22.0,
              ),
              child: Column(
                children: [
                  Text(
                    "Frequencies",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).dividerColor,
                        ),
                  ),
                  // ground
                  if (widget.airport.gndFreq.isNotEmpty)
                    Text(
                      'Ground: ${widget.airport.gndFreq} MHz',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  // tower
                  if (widget.airport.towerFreq.isNotEmpty)
                    Text(
                      'Tower: ${widget.airport.towerFreq} MHz',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  // ctaf
                  if (widget.airport.ctafFreq.isNotEmpty)
                    Text(
                      'CTAF: ${widget.airport.ctafFreq} MHz',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  // asos
                  if (widget.airport.asosFreq.isNotEmpty)
                    Text(
                      'ASOS: ${widget.airport.asosFreq} MHz',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                  for (Frequency frequency in widget.airport.frequencies)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: frequency.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: ": ",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).dividerColor,
                                ),
                          ),
                          TextSpan(
                            text: "${frequency.frequency} MHz",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
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

    int oppositeWindDirection = (180 - metar.windDirection).abs();

    for (Runway runway in airport.runways) {
      var (int angleRunway0, int angleRunway1) = runway.angle;
      var (int angleCurrentBestRunway0, int angleCurrentBestRunway1) = bestRunwayForWinds.angle;

      // find the runway that is at the opposite of the wind direction, e.g. if the wind comes from
      // 180, we want to find the runway that is at 360

      int diffRunway0 = (oppositeWindDirection - angleRunway0).abs();
      int diffRunway1 = (oppositeWindDirection - angleRunway1).abs();
      int diffCurrentBestRunway0 = (oppositeWindDirection - angleCurrentBestRunway0).abs();
      int diffCurrentBestRunway1 = (oppositeWindDirection - angleCurrentBestRunway1).abs();

      if (diffRunway0 <= diffCurrentBestRunway0) {
        bestRunwayForWinds = runway;
        // find the runway name in the format of 36L/18R
        // in order to find it, we have an optional 0 if there is only one digit
        // we also divide the angle by 10 to get the runway number,
        // and we can also have an optional L or R at the end
        RegExp runwayNameRegex = RegExp("[0]?${angleRunway1 ~/ 10}[L|R]?");
        // NOTE: I use angleRunway1 here because runway 22 is pointing towards 220°
        bestRunwayName = runwayNameRegex.stringMatch(runway.name) ?? "";

        // set the runway angle, this is used to rotate the runway image
        bestRunwayAngle = angleRunway0;
      } else if (diffRunway1 <= diffCurrentBestRunway1) {
        bestRunwayForWinds = runway;

        RegExp runwayNameRegex = RegExp("[0]?${angleRunway0 ~/ 10}[LR]?");
        bestRunwayName = runwayNameRegex.stringMatch(runway.name) ?? "";

        bestRunwayAngle = angleRunway1;
      }
    }

    bestRunwayUrl = getBestRunwayUrl(bestRunwayAngle);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: Column(
          children: [
            const Text(
              "Best runway for winds",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "$bestRunwayName - ${bestRunwayForWinds.length}ft x ${bestRunwayForWinds.width}ft",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
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
                    angle: vector.radians(metar.windDirection.toDouble() + 90),
                    child: Icon(
                      Icons.arrow_right_alt_rounded,
                      size: 100,
                      color: Theme.of(context).dividerColor.withOpacity(1),
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
