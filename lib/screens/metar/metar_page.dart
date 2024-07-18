import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/screens/components/airport_info.dart';
import 'package:metar_viewer_3/screens/metar/metar_store.dart';
import 'package:metar_viewer_3/screens/settings/settings_store.dart';
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

  int MIN_WIDTH = 400;

  @override
  void initState() {
    super.initState();
    final dispose = reaction((_) => metarStore.hasAlert, (bool hasAlert) {
      // if there is an alert to show, show it in a snackbar
      if (hasAlert) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(metarStore.alertMessage),
          ),
        );
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
      Airport apt = await metarStore.getAirportFromIcao(settingsStore.defaultMetarAirport!);
      if (kDebugMode) {
        print("Fetching default airport metar");
      }
      metarStore.fetchMetar(apt);
    }
  }

  // final SearchController controller = SearchController();

  Widget buildCard(Widget content) {
    return Expanded(
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28.0,
            vertical: 18.0,
          ),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Observer(builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (metarStore.isLoading) ...[
                          const LinearProgressIndicator(),
                        ],
                        IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Flex(
                              direction: mediaQuery.size.width > MIN_WIDTH ? Axis.horizontal : Axis.vertical,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: mediaQuery.size.width > MIN_WIDTH
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                              children: [
                                // Airport name, winds, altimeter
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //STATION
                                    Text(
                                      metarStore.metar != null ? metarStore.metar!.station : "Station",
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    ),

                                    // WINDS
                                    Text(
                                      metarStore.metar != null
                                          ? "${metarStore.metar!.windDirection}° @ ${metarStore.metar!.windSpeed}kt"
                                          : "Winds",
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    // ALTIMETER
                                    Text(
                                      metarStore.metar != null
                                          ? "${metarStore.metar!.altimeter} ${metarStore.metar!.altIsInHg ? "inHg" : "hPa"}"
                                          : "Altimeter",
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    // CONDITION
                                    Text(
                                      metarStore.metar != null ? metarStore.metar!.flightRules : "Condition",
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: metarStore.metar != null
                                                ? metarStore.metar!.flightRules == "VFR"
                                                    ? Colors.green
                                                    : metarStore.metar!.flightRules == "MVFR"
                                                        ? Colors.blue
                                                        : metarStore.metar!.flightRules == "IFR"
                                                            ? Colors.red
                                                            : metarStore.metar!.flightRules == "LIFR"
                                                                ? Colors.purple
                                                                : Colors.black
                                                : Theme.of(context).dividerColor,
                                          ),
                                    ),
                                  ],
                                ),

                                const Spacer(),

                                // Search bar
                                Expanded(
                                  flex: 4,
                                  child: SearchAnchor.bar(
                                    isFullScreen: MediaQuery.of(context).size.width < 700,
                                    suggestionsBuilder: (
                                      BuildContext context,
                                      SearchController controller,
                                    ) {
                                      if (controller.text.isEmpty || controller.text == "" || controller.text == " ") {
                                        if (metarStore.searchHistory.isNotEmpty && mounted) {
                                          return metarStore.getHistoryList(controller, context, mounted);
                                        }
                                        return [
                                          const Center(
                                            child: Text("No history"),
                                          ),
                                        ];
                                      }
                                      return metarStore.getSuggestions(controller, context, mounted);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Raw metar and summary
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28.0,
                                vertical: 22.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Raw Metar",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                  ),
                                  Text(
                                    metarStore.metar != null ? metarStore.metar!.raw : "Raw metar",
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    "Summary",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                  ),
                                  Text(
                                    metarStore.metar != null ? metarStore.metar!.summary : "Summary",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Temperature/dewpoint, winds/vis, altimeter/condition
                        IntrinsicHeight(
                          child: Flex(
                            direction: mediaQuery.size.width > MIN_WIDTH ? Axis.horizontal : Axis.vertical,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Temperature/dewpoint
                              buildCard(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      mediaQuery.size.width < 600 ? "Temp" : "Temperature",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        metarStore.metar != null
                                            ? "${metarStore.metar!.temperature}°${metarStore.metar!.temperatureUnits}"
                                            : "temp°C",
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Flexible(
                                      child: Text(
                                        mediaQuery.size.width < 600 ? "Dew" : "Dewpoint",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).dividerColor,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      metarStore.metar != null
                                          ? "${metarStore.metar!.dewpoint}°${metarStore.metar!.temperatureUnits}"
                                          : "dew°C",
                                    ),
                                  ],
                                ),
                              ),
                              // Winds/vis
                              buildCard(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Winds",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (metarStore.metar != null)
                                          Transform.rotate(
                                            angle: vector.radians(metarStore.metar!.windDirection.toDouble() + 90),
                                            child: Icon(
                                              Icons.arrow_right_alt_rounded,
                                              color: Theme.of(context).dividerColor,
                                              size: 17.0,
                                              weight: 1.0,
                                            ),
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
                                    const SizedBox(height: 8.0),
                                    Text(
                                      "Visibility",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        metarStore.metar != null
                                            ? "${metarStore.metar!.visibility} ${metarStore.metar!.visiblityUnits}"
                                            : "Visibility",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Altimeter/condition
                              buildCard(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Altimeter",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        metarStore.metar != null
                                            ? "${metarStore.metar!.altimeter} ${metarStore.metar!.altIsInHg ? "inHg" : "hPa"}"
                                            : "Altimeter",
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      "Condition",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Text(
                                      metarStore.metar != null ? metarStore.metar!.flightRules : "Condition",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: metarStore.metar != null
                                                ? metarStore.metar!.flightRules == "VFR"
                                                    ? Colors.green
                                                    : metarStore.metar!.flightRules == "MVFR"
                                                        ? Colors.blue
                                                        : metarStore.metar!.flightRules == "IFR"
                                                            ? Colors.red
                                                            : metarStore.metar!.flightRules == "LIFR"
                                                                ? Colors.purple
                                                                : Theme.of(context).textTheme.bodyMedium?.color
                                                : Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        // Cloud layers
                        IntrinsicHeight(
                          child: Flex(
                            direction: mediaQuery.size.width > MIN_WIDTH ? Axis.horizontal : Axis.vertical,
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
                                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 28.0,
                                          vertical: 22.0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              "Cloud Layers",
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Theme.of(context).dividerColor,
                                                  ),
                                            ),
                                            Text(
                                              metarStore.metar != null
                                                  ? metarStore.metar!.cloudLayers.join(", ")
                                                  : "Cloud Layers",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // remarks
                              Visibility(
                                visible: metarStore.metar != null && metarStore.metar!.remarks.isNotEmpty,
                                child: Flexible(
                                  flex: 1,
                                  child: SizedBox(
                                    width: double.infinity,
                                    // height: 115,
                                    child: Card(
                                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 28.0,
                                          vertical: 22.0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              "Remarks",
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Theme.of(context).dividerColor,
                                                  ),
                                            ),
                                            Text(
                                              metarStore.metar != null ? metarStore.metar!.remarks : "Remarks",
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

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Last updated: ${metarStore.metar != null ? formatTime(metarStore.metar!.observationTime.millisecondsSinceEpoch) : "Never"}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).dividerColor,
                                ),
                          ),
                        ),

                        // airport info
                        const SizedBox(height: 16.0),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Airport Info",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (metarStore.metar == null) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: Card(
                              color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                              elevation: 0,
                              child: const Center(
                                child: Text("Airport Info"),
                              ),
                            ),
                          ),
                        ],

                        if (metarStore.metar != null) ...[
                          AirportInfo(
                            airport: metarStore.metar!.airport,
                            metar: metarStore.metar!,
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
