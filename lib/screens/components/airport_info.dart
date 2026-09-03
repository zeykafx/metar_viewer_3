import 'package:material_ui/material_ui.dart';
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
  int minWidth = 500;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Column(
      children: [
        IntrinsicHeight(
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: mediaQuery.size.width > minWidth ? Axis.horizontal : Axis.vertical,
            children: [
              Flexible(
                flex: mediaQuery.size.width > minWidth ? 1 : 0,
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Airport name, state, type
                          Text(
                            "${widget.airport.icao} - ${widget.airport.facility}, ${widget.airport.state} (${widget.airport.type})",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                          ),
                          // Airport elevation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Elevation", style: Theme.of(context).textTheme.bodyLarge),
                              Text("${widget.airport.msl}ft MSL"),
                            ],
                          ),

                          Divider(),

                          Text("Runways", style: Theme.of(context).textTheme.bodyLarge),
                          // Airport runways
                          for (Runway runway in widget.airport.runways) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: runway.name, style: Theme.of(context).textTheme.bodySmall),
                                      TextSpan(
                                        text: ": ",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).dividerColor),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: "${runway.length}ft", style: Theme.of(context).textTheme.bodySmall),
                                      TextSpan(
                                        text: " x ",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).dividerColor),
                                      ),
                                      TextSpan(text: "${runway.width}ft", style: Theme.of(context).textTheme.bodySmall),
                                      // surface
                                      TextSpan(
                                        text: " - ${runway.surface}",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).dividerColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                          ],
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
            color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Frequencies",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).dividerColor),
                    ),
                  ),
                  // ground
                  if (widget.airport.gndFreq.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Ground:"),
                        Text(
                          '${widget.airport.gndFreq} MHz',
                          // style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),

                    Divider(),
                  ],
                  // tower
                  if (widget.airport.towerFreq.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tower:"),
                        Text(
                          '${widget.airport.towerFreq} MHz',
                          // style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),

                    Divider(),
                  ],
                  // ctaf
                  if (widget.airport.ctafFreq.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("CTAF:"),
                        Text(
                          '${widget.airport.ctafFreq} MHz',
                          // style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Divider(),
                  ],

                  // asos
                  if (widget.airport.asosFreq.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ASOS:"),
                        Text(
                          '${widget.airport.asosFreq} MHz',
                          // style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                  for (Frequency frequency in widget.airport.frequencies) ...[
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${frequency.name}: "), Text("${frequency.frequency} MHz")]),
                    Divider(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BestRunwayForWinds extends StatefulWidget {
  final Airport airport;
  final Metar metar;

  const BestRunwayForWinds({super.key, required this.airport, required this.metar});

  @override
  State<BestRunwayForWinds> createState() => _BestRunwayForWindsState();
}

class _BestRunwayForWindsState extends State<BestRunwayForWinds> {
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
    Runway bestRunwayForWinds = widget.airport.runways[0];
    String bestRunwayName = "";
    int bestRunwayAngle = 0;
    String bestRunwayUrl = "";

    int oppositeWindDirection = (180 - widget.metar.windDirection).abs();

    for (Runway runway in widget.airport.runways) {
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
      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Suggested runway",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                ),
                Text("$bestRunwayName - ${bestRunwayForWinds.length}ft x ${bestRunwayForWinds.width}ft"),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/compass.svg",
                    width: 250,
                    colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white, BlendMode.srcIn),
                    alignment: Alignment.center,
                  ),
                  Transform.rotate(
                    angle: vector.radians(bestRunwayAngle.toDouble()),
                    child: SvgPicture.network(bestRunwayUrl, width: 250, alignment: Alignment.center),
                  ),

                  // wind direction
                  Transform.rotate(
                    angle: vector.radians(widget.metar.windDirection.toDouble() + 90),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // filled arrow
                        Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 99,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 15)],
                        ),
                      ],
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
