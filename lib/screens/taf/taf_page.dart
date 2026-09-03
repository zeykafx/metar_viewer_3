import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/screens/settings/settings_store.dart';
import 'package:metar_viewer_3/screens/taf/components/current_time.dart';
import 'package:metar_viewer_3/screens/taf/components/taf_timeline.dart';
import 'package:metar_viewer_3/screens/taf/taf_store.dart';
import 'package:mobx/mobx.dart';
import 'package:time_formatter/time_formatter.dart';

class TafPage extends StatefulWidget {
  const TafPage({super.key});

  @override
  State<TafPage> createState() => _TafPageState();
}

class _TafPageState extends State<TafPage> {
  TafStore tafStore = TafStore();
  SettingsStore settingsStore = SettingsStore();
  SearchController searchController = SearchController();

  static const int smallWidth = 400;

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

    final _ = reaction((_) => tafStore.hasAlert, (bool hasAlert) {
      if (hasAlert) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tafStore.alertMessage)));
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
      Airport? apt = await tafStore.getAirportFromIcao(settingsStore.defaultTafAirport!);
      if (kDebugMode) {
        print("Fetching default airport taf");
      }
      if (apt != null) {
        tafStore.fetchTaf(apt);
      }
    }
  }

  String formatUtcClock(DateTime time) {
    String pad(int n) => n.toString().padLeft(2, '0');
    DateTime utc = time.toUtc();
    return '${pad(utc.hour)}:${pad(utc.minute)} UTC';
  }

  String formatDatetime(DateTime? time1, DateTime? time2, bool showDate) {
    if (time1 == null || time2 == null) {
      return "Time";
    }
    DateTime time1Local = time1.toUtc();
    DateTime time2Local = time2.toUtc();

    if (showDate) {
      return "${time1Local.year - 2000}/${time1Local.month}/${time1Local.day} ${time1Local.hour}Z to ${time2Local.year - 2000}/${time2Local.month}/${time2Local.day} ${time2Local.hour}Z";
    } else {
      return "${time1Local.hour}Z to ${time2Local.hour}Z";
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mediaQuery.size.width > smallWidth ? 32 : 18, vertical: 12.0),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tafStore.isLoading) ...[const LinearProgressIndicator()],
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SearchAnchor.bar(
                          searchController: searchController,
                          isFullScreen: MediaQuery.of(context).size.width < 700,
                          suggestionsBuilder: (BuildContext context, SearchController controller) {
                            if (controller.text.isEmpty || controller.text == "" || controller.text == " ") {
                              if (tafStore.searchHistory.isNotEmpty && mounted) {
                                return tafStore.getHistoryList(controller, context, mounted);
                              }
                              return [const Center(child: Text("No history"))];
                            }
                            return tafStore.getSuggestions(controller, context, mounted);
                          },
                          barTrailing: [
                            if (tafStore.hasTaf && tafStore.taf != null) ...[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: IconButton(
                                  icon: const Icon(Icons.refresh, size: 20),
                                  onPressed: () async {
                                    if (tafStore.hasTaf && tafStore.taf != null) {
                                      Airport? airport = await tafStore.getAirportFromIcao(tafStore.taf!.station);
                                      if (airport != null) {
                                        tafStore.fetchTaf(airport);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text("Cannot find the airport for the ICAO: ${tafStore.taf!.station}")));
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
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
                            Text(tafStore.taf != null ? tafStore.taf!.station : "Station", style: Theme.of(context).textTheme.headlineMedium),

                            CurrentTime(),

                            Row(
                              spacing: 3.0,
                              children: [
                                Icon(Icons.access_time_rounded, size: 17, color: Theme.of(context).dividerColor),
                                Text(
                                  tafStore.taf != null
                                      ? "${formatTime(tafStore.taf!.time.millisecondsSinceEpoch)} - ${formatUtcClock(tafStore.taf!.time)}"
                                      : "Never updated",
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w600),
                                ),
                              ],
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Raw TAF",
                                      style: Theme.of(context).textTheme.bodyLarge
                                          ?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).dividerColor),
                                    ),
                                    InkWell(
                                      child: Icon(Icons.copy, size: 15, color: Theme.of(context).dividerColor),
                                      onTap: () async {
                                        if (tafStore.taf != null) {
                                          await Clipboard.setData(ClipboardData(text: tafStore.taf!.raw));
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied raw TAF!")));
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No raw taf to copy!")));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(tafStore.taf != null ? tafStore.taf!.sanitized : "Raw TAF"),

                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Valid: ",
                                      style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).dividerColor),
                                    ),
                                    Text(tafStore.taf != null ? formatDatetime(tafStore.taf!.startTime, tafStore.taf!.endTime, true) : "Time"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // FORECAST TIMELINE
                      const SizedBox(height: 16.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Forecast Timeline", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      ),

                      TafTimeline(taf: tafStore.taf),

                      // FORECASTS
                      const SizedBox(height: 16.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Forecasts", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      ),

                      if (tafStore.taf == null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: mediaQuery.size.width > smallWidth ? 30 : 15),
                          child: SizedBox(
                            width: double.infinity,
                            height: 500,
                            child: Card(
                              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                              elevation: 0,
                              child: const Center(child: Text("Forecasts")),
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
                                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: mediaQuery.size.width > smallWidth ? 30 : 15),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 22.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // FLIGHT RULES, TYPE
                                                Row(
                                                  spacing: 8,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(25),
                                                        color: forecast.getFlightRulesColor(context),
                                                      ),
                                                      child: Text(
                                                        forecast.flightRules,
                                                        style: Theme.of(context).textTheme.bodySmall
                                                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                                      ),
                                                    ),

                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(25),
                                                        color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(alpha: 0.4),
                                                      ),
                                                      child: Tooltip(
                                                        enableFeedback: true,
                                                        triggerMode: TooltipTriggerMode.tap,
                                                        message: typeToDescription[forecast.type] ?? "Description",
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(forecast.type),
                                                            const SizedBox(width: 3.0),
                                                            Icon(Icons.info, size: 13.0, color: Theme.of(context).dividerColor),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // TIME
                                                Flexible(
                                                  child: Text(
                                                    formatDatetime(forecast.startTime, forecast.endTime, true),
                                                    style: Theme.of(context).textTheme.bodyMedium
                                                        ?.copyWith(color: Theme.of(context).dividerColor, fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 8.0),
                                            Text(forecast.summary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ).animate(delay: Duration(milliseconds: 100 + i * 150)).fadeIn(curve: Curves.easeInOutQuad),
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
    );
  }
}
