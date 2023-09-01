import 'package:cross_local_storage/cross_local_storage.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:metar_viewer_3/api/avwx.dart";
import "package:metar_viewer_3/models/airport.dart";
import "package:metar_viewer_3/models/metar.dart";
import "package:mobx/mobx.dart";

import "../main.dart";

part 'metar_store.g.dart';

class MetarStore = _MetarStore with _$MetarStore;

abstract class _MetarStore with Store {
  AvwxApi avwxApi = AvwxApi();

  @observable
  Metar? metar;

  @computed
  bool get hasMetar => metar != null;

  @computed
  DateTime? get lastUpdated => metar?.time!;

  @observable
  bool hasAlert = false;
  @observable
  String alertMessage = "";
  @observable
  bool isLoading = false;

  @observable
  List<Airport> searchHistory = [];

  @action
  Future<void> fetchMetar(Airport airport) async {
    try {
      isLoading = true;

      var value = await avwxApi.getMetar(airport);
      var (Metar metarValue, bool cached) = value;
      metar = metarValue;

      isLoading = false;
      if (cached) {
        alertMessage =
            "The metar displayed is cached, it will refresh in ${3 - DateTime.now().difference(lastUpdated!).inMinutes} minutes";
        hasAlert = true;
      } else {
        alertMessage = "";
        hasAlert = false;
      }
    } catch (e) {
      print(e);
      alertMessage = "Failed to fetch metar for ${airport.icao}";
      hasAlert = true;
    }
  }

  @action
  Future<void> addToSearchHistory(Airport airport) async {
    // add to the search history if it's not already in it
    if (searchHistory.isEmpty ||
        !searchHistory.map((e) => e.icao == airport.icao).contains(true)) {
      searchHistory.insert(0, airport);
      LocalStorageInterface pref = await LocalStorage.getInstance();
      // save the new search history to the prefs
      await pref.setStringList(
        "searchHistory",
        searchHistory.map((e) => e.icao).toList(),
      );
      if (kDebugMode) {
        print("saved search history");
      }
    }
  }

  @action
  Future<void> removeFromSearchHistory(Airport airport) async {
    if (searchHistory.contains(airport)) {
      searchHistory.remove(airport);
      LocalStorageInterface pref = await LocalStorage.getInstance();
      // save the new search history to the prefs
      await pref.setStringList(
        "searchHistory",
        searchHistory.map((e) => e.icao).toList(),
      );
      if (kDebugMode) {
        print('removed ${airport.icao} from search history');
      }
    }
  }

  @action
  Future<void> getSearchHistoryFromPrefs() async {
    LocalStorageInterface pref = await LocalStorage.getInstance();
    List<String>? history = pref.getStringList("searchHistory");
    if (history != null) {
      for (String icao in history) {
        // wait until database is not null
        while (database == null) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        List<Map<String, Object?>> res = await database!.query(
          "NatFixes",
          where: "NavId LIKE ?",
          whereArgs: ["$icao%"],
        );
        Airport airportFromPrefs = Airport.fromDb(res[0]);
        if (!searchHistory.contains(airportFromPrefs)) {
          searchHistory.add(airportFromPrefs);
        }
      }
    }

    if (kDebugMode) {
      print("loaded search history");
    }
  }

  @action
  Iterable<Widget> getHistoryList(
      SearchController controller, BuildContext context) {
    return searchHistory.map(
      (Airport airport) => ListTile(
        title: Text(airport.icao),
        subtitle: Text(airport.state),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                        title: const Text("Delete airport from history?"),
                        content: Text(
                            "Do you really want to delete ${airport.icao} from your search history?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              controller.text = "";
                              controller.closeView("");
                              removeFromSearchHistory(airport);
                            },
                            child: const Text("Delete"),
                          ),
                        ]));
          },
        ),
        onTap: () {
          fetchMetar(airport);
          addToSearchHistory(airport);
          controller.closeView(airport.icao);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  @action
  Future<Iterable<Widget>> getSuggestions(
      SearchController controller, BuildContext context) async {
    List<Map<String, Object?>> res = await database!.query("NatFixes",
        where: "NavId LIKE ?",
        whereArgs: ["${controller.text.toUpperCase()}%"]);
    List<Airport> airports = [];
    for (var element in res) {
      airports.add(Airport.fromDb(element));
    }

    return airports.map(
      (airport) => ListTile(
        title: Text("${airport.icao} - ${airport.facility}"),
        subtitle: Text(airport.state),
        onTap: () {
          fetchMetar(airport);
          addToSearchHistory(airport);
          controller.closeView(airport.icao);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
