import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metar_viewer_3/screens/components/airport_info.dart';
import 'package:mobx/mobx.dart';
import 'package:time_formatter/time_formatter.dart';

import 'metar_store.dart';

class MetarPage extends StatefulWidget {
  const MetarPage({Key? key}) : super(key: key);

  @override
  State<MetarPage> createState() => _MetarPageState();
}

class _MetarPageState extends State<MetarPage> {
  MetarStore metarStore = MetarStore();

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
  }

  // final SearchController controller = SearchController();

  Widget buildCard(Widget content) {
    return Expanded(
      child: Card(
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Observer(builder: (context) {
                // if (metarStore.metar == null) {
                //   return const Center(
                //     child: Text("No metar"),
                //   );
                // }
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (metarStore.isLoading) ...[
                      const LinearProgressIndicator(),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          // Airport name, winds, altimeter
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              //STATION
                              Text(
                                metarStore.metar != null
                                    ? metarStore.metar!.station
                                    : "Station",
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),

                              // WINDS
                              Text(
                                metarStore.metar != null
                                    ? "${metarStore.metar!.windDirection}° @ ${metarStore.metar!.windSpeed}kt"
                                    : "Winds",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              // ALTIMETER
                              Text(
                                metarStore.metar != null
                                    ? "${metarStore.metar!.altimeter} ${metarStore.metar!.altIsInHg ? "inHg" : "hPa"}"
                                    : "Altimeter",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              // CONDITION
                              Text(
                                metarStore.metar != null
                                    ? metarStore.metar!.flightRules
                                    : "Condition",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: metarStore.metar != null
                                          ? metarStore.metar!.flightRules ==
                                                  "VFR"
                                              ? Colors.green
                                              : metarStore.metar!.flightRules ==
                                                      "MVFR"
                                                  ? Colors.blue
                                                  : metarStore.metar!
                                                              .flightRules ==
                                                          "IFR"
                                                      ? Colors.red
                                                      : metarStore.metar!
                                                                  .flightRules ==
                                                              "LIFR"
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
                            child: SearchAnchor.bar(
                              // searchController: controller,
                              // builder: (BuildContext context, SearchController controller) {
                              //   return SearchBar(
                              //     controller: controller,
                              //     padding: const MaterialStatePropertyAll<EdgeInsets>(
                              //       EdgeInsets.symmetric(horizontal: 16.0),
                              //     ),
                              //     onTap: () {
                              //       controller.openView();
                              //     },
                              //     onChanged: (_) {
                              //       controller.openView();
                              //     },
                              //     leading: const Icon(Icons.search),
                              //   );
                              // },
                              isFullScreen:
                                  MediaQuery.of(context).size.width < 700,
                              suggestionsBuilder: (
                                BuildContext context,
                                SearchController controller,
                              ) {
                                if (controller.text.isEmpty ||
                                    controller.text == "" ||
                                    controller.text == " ") {
                                  if (metarStore.searchHistory.isNotEmpty) {
                                    return metarStore.getHistoryList(
                                        controller, context);
                                  }
                                  return [
                                    const Center(
                                      child: Text("No history"),
                                    ),
                                  ];
                                }
                                return metarStore.getSuggestions(
                                  controller,
                                  context,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Raw metar and summary
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
                                "Raw Metar",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              Text(
                                metarStore.metar != null
                                    ? metarStore.metar!.raw
                                    : "Raw metar",
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "Summary",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              Text(
                                metarStore.metar != null
                                    ? metarStore.metar!.summary
                                    : "Summary",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Temperature/dewpoint, winds/vis, altimeter/condition
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Temperature/dewpoint
                        buildCard(
                          Column(
                            children: [
                              Text(
                                "Temperature",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              Text(
                                metarStore.metar != null
                                    ? "${metarStore.metar!.temperature}°${metarStore.metar!.temperatureUnits}"
                                    : "temp°C",
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "Dewpoint",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
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
                            children: [
                              Text(
                                "Winds",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (metarStore.metar != null)
                                    Transform.rotate(
                                      angle: metarStore.metar!.windDirection
                                              .toDouble() -
                                          90,
                                      child: Icon(
                                        Icons.arrow_right_alt_rounded,
                                        color: Theme.of(context).dividerColor,
                                        size: 17.0,
                                        weight: 1.0,
                                      ),
                                    ),
                                  Text(
                                    metarStore.metar != null
                                        ? "${metarStore.metar!.windDirection}° @ ${metarStore.metar!.windSpeed}kt${metarStore.metar!.windGust != "/" ? " gusting ${metarStore.metar!.windGust}kt" : ""}"
                                        : "Winds",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "Visibility",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              Text(
                                metarStore.metar != null
                                    ? "${metarStore.metar!.visibility} ${metarStore.metar!.visiblityUnits}"
                                    : "Visibility",
                              ),
                            ],
                          ),
                        ),
                        // Altimeter/condition
                        buildCard(
                          Column(
                            children: [
                              Text(
                                "Altimeter",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              Text(
                                metarStore.metar != null
                                    ? "${metarStore.metar!.altimeter} ${metarStore.metar!.altIsInHg ? "inHg" : "hPa"}"
                                    : "Altimeter",
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "Condition",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).dividerColor,
                                    ),
                              ),
                              Text(
                                metarStore.metar != null
                                    ? metarStore.metar!.flightRules
                                    : "Condition",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: metarStore.metar != null
                                          ? metarStore.metar!.flightRules ==
                                                  "VFR"
                                              ? Colors.green
                                              : metarStore.metar!.flightRules ==
                                                      "MVFR"
                                                  ? Colors.blue
                                                  : metarStore.metar!
                                                              .flightRules ==
                                                          "IFR"
                                                      ? Colors.red
                                                      : metarStore.metar!
                                                                  .flightRules ==
                                                              "LIFR"
                                                          ? Colors.purple
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.color
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                    ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    // Cloud layers
                    Row(
                      children: [
                        // cloud layers
                        if (metarStore.metar != null &&
                            metarStore.metar!.cloudLayers.isNotEmpty) ...[
                          Flexible(
                            flex: 2,
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
                                      Text(
                                        "Cloud Layers",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                            ),
                                      ),
                                      Text(
                                        metarStore.metar != null
                                            ? metarStore.metar!.cloudLayers
                                                .join(", ")
                                            : "Cloud Layers",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // remarks
                        Flexible(
                          flex: 1,
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
                                    Text(
                                      "Remarks",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Text(
                                      metarStore.metar != null
                                          ? metarStore.metar!.remarks
                                          : "Remarks",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                    if (metarStore.metar != null) ...[
                      const SizedBox(height: 16.0),
                      const Text(
                        "Airport Info",
                      ),
                      const SizedBox(height: 8.0),
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
    );
  }
}
