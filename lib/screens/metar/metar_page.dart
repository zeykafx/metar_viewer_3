import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/models/metar.dart';
import 'package:metar_viewer_3/screens/components/airport_info.dart';
import 'package:metar_viewer_3/screens/metar/metar_store.dart';
import 'package:metar_viewer_3/screens/settings/settings_store.dart';
import 'package:metar_viewer_3/screens/taf/components/current_time.dart';
import 'package:mobx/mobx.dart';
import 'package:time_formatter/time_formatter.dart';
import "package:vector_math/vector_math.dart" as vector;

class MetarPage extends StatefulWidget {
  const MetarPage({super.key});

  @override
  State<MetarPage> createState() => _MetarPageState();
}

class _MetarPageState extends State<MetarPage> {
  MetarStore metarStore = MetarStore();
  SettingsStore settingsStore = SettingsStore();

  SearchController searchController = SearchController();

  static const int minWidth = 350;
  static const int smallWidth = 500;

  @override
  void initState() {
    super.initState();
    final _ = reaction((_) => metarStore.hasAlert, (bool hasAlert) {
      // if there is an alert to show, show it in a snackbar
      if (hasAlert) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(metarStore.alertMessage)));
        metarStore.hasAlert = false;
        metarStore.alertMessage = "";
      }
    });

    metarStore.getSearchHistoryFromPrefs();
    init();
  }

  Future<void> init() async {
    while (!settingsStore.initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (settingsStore.fetchMetarOnStartup) {
      Airport? apt = await metarStore.getAirportFromIcao(settingsStore.defaultMetarAirport!);
      if (kDebugMode) {
        print("Fetching default airport metar");
      }
      if (apt != null) {
        metarStore.fetchMetar(apt);
      }
    }
  }

  String formatUtcClock(DateTime time) {
    String pad(int n) => n.toString().padLeft(2, '0');
    DateTime utc = time.toUtc();
    return '${pad(utc.hour)}:${pad(utc.minute)} UTC';
  }

  Widget buildCard(Widget content, MediaQueryData mediaQuery) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width > smallWidth ? 28 : 10, vertical: 18.0),
        child: content,
      ),
    );
  }

  Widget buildCloudLayer(CloudLayer layer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.cloud_outlined, size: 15, color: Theme.of(context).dividerColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(layer.coverageLabel, style: Theme.of(context).textTheme.bodyLarge)),
                    if (layer.altitude > 0)
                      Text(layer.altitudeLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor)),
                  ],
                ),
                if (layer.modifierLabel != null)
                  Text(layer.modifierLabel!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).dividerColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatCards(MediaQueryData mediaQuery) {
    return <Widget>[
      // Temperature
      buildCard(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Icon(Icons.device_thermostat_rounded, size: 16, color: Theme.of(context).dividerColor),
                Text(
                  mediaQuery.size.width < 600 ? "Temp" : "Temperature",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor),
                ),
              ],
            ),

            Flexible(child: Text(metarStore.metar != null ? "${metarStore.metar!.temperature}°${metarStore.metar!.temperatureUnits}" : "temp°C")),
          ],
        ),
        mediaQuery,
      ),

      // Altimeter
      buildCard(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 3,
              children: [
                Icon(Icons.speed_rounded, size: 16, color: Theme.of(context).dividerColor),
                Text(
                  mediaQuery.size.width < 600 ? "Alt." : "Altimeter",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor),
                ),
              ],
            ),
            Flexible(child: Text(metarStore.metar != null ? "${metarStore.metar!.altimeter} ${metarStore.metar!.altIsInHg ? "inHg" : "hPa"}" : "Altimeter")),
          ],
        ),
        mediaQuery,
      ),

      // Winds
      buildCard(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Icon(Icons.air_rounded, size: 16, color: Theme.of(context).dividerColor),
                Text("Winds", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor)),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (metarStore.metar != null)
                  Transform.rotate(
                    angle: vector.radians(metarStore.metar!.windDirection.toDouble() + 90),
                    child: Icon(Icons.arrow_right_alt_rounded, color: Theme.of(context).dividerColor, size: 17.0, weight: 1.0),
                  ),
                Flexible(
                  child: Text(
                    metarStore.metar != null
                        ? "${metarStore.metar!.windDirection}° @ ${metarStore.metar!.windSpeed}kt${metarStore.metar!.windGust != "/" ? " gusting ${metarStore.metar!.windGust}kt" : ""}"
                        : "Winds",
                  ),
                ),
              ],
            ),
          ],
        ),
        mediaQuery,
      ),

      // Visibility
      buildCard(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 3,
              children: [
                Icon(Icons.remove_red_eye_rounded, size: 15, color: Theme.of(context).dividerColor),
                Text(
                  mediaQuery.size.width < 600 ? "Vis." : "Visibility",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor),
                ),
              ],
            ),

            Flexible(
              child: Text(
                metarStore.metar != null
                    ? "${metarStore.metar!.visibility} ${metarStore.metar!.visibility != "CAVOK" ? metarStore.metar!.visiblityUnits : ""}"
                    : "Visibility",
              ),
            ),
          ],
        ),
        mediaQuery,
      ),

      // Dew point
      buildCard(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Icon(Icons.water_drop_rounded, size: 16, color: Theme.of(context).dividerColor),
                Flexible(
                  child: Text(
                    mediaQuery.size.width < 600 ? "Dew" : "Dewpoint",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor),
                  ),
                ),
              ],
            ),

            Text(metarStore.metar != null ? "${metarStore.metar!.dewpoint}°${metarStore.metar!.temperatureUnits}" : "dew°C"),
          ],
        ),
        mediaQuery,
      ),

      // Condition
      buildCard(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Icon(Icons.flight_rounded, size: 16, color: Theme.of(context).dividerColor),
                Text(
                  mediaQuery.size.width < 600 ? "Cond." : "Conditions",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor),
                ),
              ],
            ),
            Text(
              metarStore.metar != null ? metarStore.metar!.flightRules : "Condition",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: metarStore.getFlightRulesColor(context), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        mediaQuery,
      ),
    ];
  }

  Widget _buildStats(MediaQueryData mediaQuery) {
    final List<Widget> cards = _buildStatCards(mediaQuery);

    if (mediaQuery.size.width < 350) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: cards);
    }

    return Column(
      children: [
        for (int i = 0; i < cards.length; i += 3)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (int j = i; j < i + 3 && j < cards.length; j++) Expanded(child: cards[j])],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return SelectableRegion(
      focusNode: FocusNode(),
      selectionControls: MaterialTextSelectionControls(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width > smallWidth ? 42 : 22, vertical: 0.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                // controller: ScrollController(),
                child: Observer(
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (metarStore.isLoading) ...[const LinearProgressIndicator()],

                        // Search bar
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 5,
                                child: SearchAnchor.bar(
                                  searchController: searchController,
                                  isFullScreen: MediaQuery.of(context).size.width < 700,
                                  suggestionsBuilder: (BuildContext context, SearchController controller) {
                                    if (controller.text.isEmpty || controller.text == "" || controller.text == " ") {
                                      if (metarStore.searchHistory.isNotEmpty && mounted) {
                                        return metarStore.getHistoryList(controller, context, mounted);
                                      }
                                      return [const Center(child: Text("No history"))];
                                    }
                                    return metarStore.getSuggestions(controller, context, mounted);
                                  },
                                  barTrailing: [
                                    if (metarStore.hasMetar && metarStore.metar != null) ...[
                                      IconButton(
                                        icon: const Icon(Icons.refresh, size: 20),
                                        onPressed: () {
                                          if (metarStore.hasMetar && metarStore.metar != null) {
                                            metarStore.fetchMetar(metarStore.metar!.airport);
                                          }
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ICAO code, station name, last update time
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //STATION
                              Text(metarStore.metar != null ? metarStore.metar!.station : "Station", style: Theme.of(context).textTheme.headlineMedium),
                              Text(
                                metarStore.metar != null
                                    ? "${metarStore.metar!.airport.facility.split('-').map((word) => word.toUpperCase().substring(0, 1) + word.toLowerCase().substring(1)).join(' ')}, ${metarStore.metar!.airport.state}" // the facility string is something like "BRUSSELS-NATIONAL", so we split
                                    // on "-", then capitalize the first letter of each word only and join with spaces -> result = "Brussels National"
                                    : "Airport Name",
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),

                              CurrentTime(),

                              Row(
                                spacing: 3.0,
                                children: [
                                  Icon(Icons.access_time_rounded, size: 17, color: Theme.of(context).dividerColor),
                                  Text(
                                    metarStore.metar != null
                                        ? "${formatTime(metarStore.metar!.time.millisecondsSinceEpoch)} - ${formatUtcClock(metarStore.metar!.time)}"
                                        : "Never updated",
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              // Row(
                              //   spacing: 3.0,
                              //   children: [
                              //     Icon(Icons.access_time_rounded, size: 17, color: Theme.of(context).dividerColor),
                              //     Text(
                              //       metarStore.metar != null ? formatTime(metarStore.metar!.observationTime.millisecondsSinceEpoch) : "Never updated",
                              //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).dividerColor),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),

                        // colored card
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: metarStore.getFlightRulesColor(context).withValues(alpha: 0.2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                spacing: 12,
                                children: [
                                  // FLIGHT RULES
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 12,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: metarStore.getFlightRulesColor(context)),
                                        child: Text(
                                          metarStore.metar != null ? metarStore.metar!.flightRules : "Condition",
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      Text(
                                        metarStore.metar != null ? metarStore.metar!.flightRulesToReadableString() : "",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),

                                  // Temperature/dewpoint, winds/vis, altimeter
                                  _buildStats(mediaQuery),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // summary card
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
                                spacing: 8,
                                children: [
                                  Text(
                                    "Summary",
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                                  ),
                                  Text(metarStore.metar != null ? metarStore.metar!.summary : "Summary"),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Raw metar
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
                                spacing: 8,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Raw Metar",
                                        style: Theme.of(context).textTheme.bodyLarge
                                            ?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                                      ),
                                      InkWell(
                                        child: Icon(Icons.copy, size: 15, color: Theme.of(context).dividerColor),
                                        onTap: () async {
                                          if (metarStore.metar != null) {
                                            await Clipboard.setData(ClipboardData(text: metarStore.metar!.raw));
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied raw METAR!")));
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No raw metar to copy!")));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(metarStore.metar != null ? metarStore.metar!.raw : "No raw metar."),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Cloud layers
                        IntrinsicHeight(
                          child: Flex(
                            direction: mediaQuery.size.width > minWidth ? Axis.horizontal : Axis.vertical,
                            children: [
                              // cloud layers
                              Visibility(
                                visible: metarStore.metar != null && metarStore.metar!.cloudLayers.isNotEmpty,
                                child: Flexible(
                                  flex: 1,
                                  child: SizedBox(
                                    width: double.infinity,
                                    // height: 115,
                                    child: Card(
                                      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
                                      elevation: 0,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width > smallWidth ? 28 : 15, vertical: 22.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              "Cloud Layers",
                                              style: Theme.of(context).textTheme.bodyLarge
                                                  ?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                                            ),
                                            ...(metarStore.metar != null ? metarStore.metar!.cloudLayers.map(buildCloudLayer) : [const Text("Cloud Layers")]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // remarks
                              Visibility(
                                visible: metarStore.metar != null && metarStore.metar!.remarksTranslations.isNotEmpty,
                                child: Flexible(
                                  flex: 1,
                                  child: SizedBox(
                                    width: double.infinity,
                                    // height: 115,
                                    child: Card(
                                      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(25)),
                                      elevation: 0,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width > smallWidth ? 28 : 15, vertical: 22.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 6,
                                          children: [
                                            Text(
                                              "Remarks",
                                              style: Theme.of(context).textTheme.bodyLarge
                                                  ?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                                            ),
                                            Text(metarStore.metar != null ? metarStore.metar!.remarksTranslations : "Remarks"),
                                            if (metarStore.metar != null && metarStore.metar!.remarks.isNotEmpty)
                                              Text(
                                                metarStore.metar!.remarks,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).dividerColor),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // airport info
                        const SizedBox(height: 16.0),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Airport Info", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8.0),
                        if (metarStore.metar == null) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: Card(
                              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                              elevation: 0,
                              child: const Center(child: Text("Airport Info")),
                            ),
                          ),
                        ],

                        if (metarStore.metar != null) ...[AirportInfo(airport: metarStore.metar!.airport, metar: metarStore.metar!)],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
