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
  List<Airport> searchHistory = [];

  @action
  Future<void> fetchMetar(Airport airport) async {
    try {
      var value = await avwxApi.getMetar(airport);
      var (Metar metarValue, bool cached) = value;
      metar = metarValue;
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
  void addToSearchHistory(Airport airport) {
    if (searchHistory.contains(airport)) {
      searchHistory.remove(airport);
    }
    searchHistory.insert(0, airport);
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
            searchHistory.remove(airport);
          },
        ),
        onTap: () {
          controller.closeView(airport.icao);
          addToSearchHistory(airport);
          fetchMetar(airport);
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
          controller.closeView(airport.icao);
          addToSearchHistory(airport);
          fetchMetar(airport);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
