import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/screens/settings/settings_store.dart';
import 'package:metar_viewer_3/screens/taf/taf_store.dart';
import 'package:mobx/mobx.dart';
import 'package:time_formatter/time_formatter.dart';

class TafPage extends StatefulWidget {
  const TafPage({Key? key}) : super(key: key);

  @override
  State<TafPage> createState() => _TafPageState();
}

class _TafPageState extends State<TafPage> {
  TafStore tafStore = TafStore();
  SettingsStore settingsStore = SettingsStore();
  int MIN_WIDTH = 500;

  Map<String, String> typeToDescription = {
    "FROM": "Changes expected from a date/hour to another date/hour",
    "BECMG": "Gradual changes expected from a date/hour to another date/hour",
    "TEMPO": "Temporary changes expected from a date/hour to another date/hour",
    "PROB": "Changes have a probability of happening",
    "RMK": "Remark",
  };

  @override
  void initState() {
    super.initState();

    final dispose = reaction((_) => tafStore.hasAlert, (bool hasAlert) {
      if (hasAlert) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tafStore.alertMessage),
          ),
        );
        tafStore.hasAlert = false;
        tafStore.alertMessage = "";
      }
    });

    tafStore.getSearchHistoryFromPrefs();
    init();
  }

  Future<void> init() async {
    while (!settingsStore.initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (settingsStore.fetchTafOnStartup) {
      Airport apt = await tafStore.getAirportFromIcao(settingsStore.defaultTafAirport!);
      if (kDebugMode) {
        print("Fetching default airport taf");
      }
      tafStore.fetchTaf(apt);
    }
  }

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

  String formatDatetime(DateTime? time1, DateTime? time2, bool showDate) {
    if (time1 == null || time2 == null) {
      return "Time";
    }
    DateTime time1Local = time1.toLocal();
    DateTime time2Local = time2.toLocal();

    if (showDate) {
      return "${time1Local.day}/${time1Local.month}/${time1Local.year} ${time1Local.hour}:${time1Local.minute} to ${time2Local.day}/${time2Local.month}/${time2Local.year} ${time2Local.hour}:${time2Local.minute}";
    } else {
      return "${time1Local.hour}h to ${time2Local.hour}h";
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Observer(
                    builder: (context) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tafStore.isLoading) ...[
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
                                  // Airport name
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //STATION
                                      Text(
                                        tafStore.taf != null ? tafStore.taf!.station : "Station",
                                        style: Theme.of(context).textTheme.headlineMedium,
                                      ),

                                      Text(
                                        tafStore.taf != null
                                            ? formatTime(tafStore.taf!.time.millisecondsSinceEpoch)
                                            : "Time",
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: Theme.of(context).dividerColor,
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
                                        if (controller.text.isEmpty ||
                                            controller.text == "" ||
                                            controller.text == " ") {
                                          if (tafStore.searchHistory.isNotEmpty && mounted) {
                                            return tafStore.getHistoryList(controller, context, mounted);
                                          }
                                          return [
                                            const Center(
                                              child: Text("No history"),
                                            ),
                                          ];
                                        }
                                        return tafStore.getSuggestions(controller, context, mounted);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                      "Raw TAF",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Text(
                                      tafStore.taf != null ? tafStore.taf!.sanitized : "Raw TAF",
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      "Time",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).dividerColor,
                                          ),
                                    ),
                                    Text(
                                      tafStore.taf != null
                                          ? formatDatetime(tafStore.taf!.startTime, tafStore.taf!.endTime, false)
                                          : "Time",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16.0),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Forecasts",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          if (tafStore.taf == null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 30),
                              child: SizedBox(
                                width: double.infinity,
                                height: 500,
                                child: Card(
                                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                                  elevation: 0,
                                  child: const Center(
                                    child: Text("Forecasts"),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // taf forecasts
                          if (tafStore.taf != null) ...[
                            ...tafStore.taf!.forecast
                                .asMap()
                                .map(
                                  (i, forecast) => MapEntry(
                                    i,
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 30),
                                      child: SizedBox(
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
                                                  "Type",
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: Theme.of(context).dividerColor,
                                                      ),
                                                ),
                                                Tooltip(
                                                  enableFeedback: true,
                                                  triggerMode: TooltipTriggerMode.tap,
                                                  message: typeToDescription[forecast.type] ?? "Description",
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(forecast.type),
                                                      const SizedBox(width: 3.0),
                                                      Icon(
                                                        Icons.info,
                                                        size: 13.0,
                                                        color: Theme.of(context).dividerColor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                Text(
                                                  "Summary",
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: Theme.of(context).dividerColor,
                                                      ),
                                                ),
                                                Text(forecast.summary),
                                                const SizedBox(height: 8.0),
                                                Text(
                                                  "Time",
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        color: Theme.of(context).dividerColor,
                                                      ),
                                                ),
                                                Text(formatDatetime(forecast.startTime, forecast.endTime, false)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ).animate(delay: Duration(milliseconds: 100 + i * 150)).fadeIn(),
                                  ),
                                )
                                .values,
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
