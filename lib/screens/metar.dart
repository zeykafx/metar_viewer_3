import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import 'metar_store.dart';

class MetarPage extends StatelessWidget {
  const MetarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metarStore = MetarStore();

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

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
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
                                // STATION
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.station} - ${metarStore.metar!.airport.facility}"
                                      : "Station",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                // WINDS
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.windDirection!}° @ ${metarStore.metar!.windSpeed!}kt"
                                      : "Winds",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                // ALTIMETER
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.altimeter!} ${metarStore.metar!.altIsInHg! ? "inHg" : "hPa"}"
                                      : "Altimeter",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                // CONDITION
                                Text(
                                  metarStore.metar != null
                                      ? metarStore.metar!.flightRules!
                                      : "Condition",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: metarStore.metar != null
                                            ? metarStore.metar!.flightRules! ==
                                                    "VFR"
                                                ? Colors.green
                                                : metarStore.metar!
                                                            .flightRules! ==
                                                        "MVFR"
                                                    ? Colors.blue
                                                    : metarStore.metar!
                                                                .flightRules! ==
                                                            "IFR"
                                                        ? Colors.red
                                                        : metarStore.metar!
                                                                    .flightRules! ==
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
                                suggestionsBuilder: (
                                  BuildContext context,
                                  SearchController controller,
                                ) {
                                  if (controller.text.isEmpty) {
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
                                const Text(
                                  "Raw Metar",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? metarStore.metar!.raw
                                      : "Raw metar",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Summary",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? metarStore.metar!.summary
                                      : "Summary",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
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
                                const Text(
                                  "Temperature",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.temperature!}°${metarStore.metar!.temperatureUnits!}"
                                      : "temp°C",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Dewpoint",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.dewpoint!}°${metarStore.metar!.temperatureUnits!}"
                                      : "dew°C",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Winds/vis
                          buildCard(
                            Column(
                              children: [
                                const Text(
                                  "Winds",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.windDirection!}° @ ${metarStore.metar!.windSpeed!}kt${metarStore.metar!.windGust != "/" ? " gusting ${metarStore.metar!.windGust!}kt" : ""}"
                                      : "Winds",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Visibility",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.visibility!}${metarStore.metar!.visiblityUnits!}"
                                      : "Visibility",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Altimeter/condition
                          buildCard(
                            Column(
                              children: [
                                const Text(
                                  "Altimeter",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? "${metarStore.metar!.altimeter!} ${metarStore.metar!.altIsInHg! ? "inHg" : "hPa"}"
                                      : "Altimeter",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Condition",
                                ),
                                Text(
                                  metarStore.metar != null
                                      ? metarStore.metar!.flightRules!
                                      : "Condition",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: metarStore.metar != null
                                            ? metarStore.metar!.flightRules! ==
                                                    "VFR"
                                                ? Colors.green
                                                : metarStore.metar!
                                                            .flightRules! ==
                                                        "MVFR"
                                                    ? Colors.blue
                                                    : metarStore.metar!
                                                                .flightRules! ==
                                                            "IFR"
                                                        ? Colors.red
                                                        : metarStore.metar!
                                                                    .flightRules! ==
                                                                "LIFR"
                                                            ? Colors.purple
                                                            : Theme.of(context)
                                                                .dividerColor
                                            : Theme.of(context).dividerColor,
                                      ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
