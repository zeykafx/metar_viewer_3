import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

enum DarkMode {
  system,
  dark,
  light,
}

DarkMode stringToDarkMode(String darkModeString) {
  return switch (darkModeString) {
    "System" => DarkMode.system,
    "Dark" => DarkMode.dark,
    "Light" => DarkMode.light,
    String() => DarkMode.system,
  };
}

String darkModeToString(DarkMode darkMode) {
  return switch (darkMode) {
    DarkMode.system => "System",
    DarkMode.dark => "Dark",
    DarkMode.light => "Light",
  };
}

const darkModeNames = ["System", "Dark", "Light"];

abstract class _SettingsStore with Store {
  late LocalStorageInterface prefs;

  _SettingsStore() {
    init();
  }

  Future<void> init() async {
    prefs = await LocalStorage.getInstance();

    startPage = prefs.getBool("startPage") ?? false;

    darkMode = stringToDarkMode(prefs.getString('newDarkMode') ?? "System");

    fetchMetarOnStartup = prefs.getBool("fetchMetarOnStartup") ?? false;
    defaultMetarAirport = prefs.getString("defaultMetarAirport");

    fetchTafOnStartup = prefs.getBool("fetchTafOnStartup") ?? false;
    defaultTafAirport = prefs.getString("defaultTafAirport");

    initialized = true;
  }

  @observable
  bool startPage = false; // false for metar, true for taf

  @observable
  bool initialized = false;

  @action
  void setStartPage(bool val) {
    startPage = val;
    prefs.setBool("startPage", val);
  }

  @observable
  DarkMode darkMode = DarkMode.system;

  @action
  void setDarkMode(DarkMode value) {
    darkMode = value;
    prefs.setString('newDarkMode', darkModeToString(value));
  }

  @observable
  bool fetchMetarOnStartup = false;

  @observable
  bool fetchTafOnStartup = false;

  @observable
  String? defaultMetarAirport;

  @observable
  String? defaultTafAirport;

  @action
  void setFetchMetarOnStartup(bool value) {
    fetchMetarOnStartup = value;
    prefs.setBool('fetchMetarOnStartup', value);
  }

  @action
  void setFetchTafOnStartup(bool value) {
    fetchTafOnStartup = value;
    prefs.setBool('fetchTafOnStartup', value);
  }

  @action
  void setDefaultMetarAirport(String value) {
    defaultMetarAirport = value;
    prefs.setString("defaultMetarAirport", value);
  }

  @action
  void setDefaultTafAirport(String value) {
    defaultTafAirport = value;
    prefs.setString("defaultTafAirport", value);
  }
}
