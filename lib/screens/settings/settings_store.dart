import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  late LocalStorageInterface prefs;

  _SettingsStore() {
    init();
  }

  Future<void> init() async {
    prefs = await LocalStorage.getInstance();

    startPage = prefs.getBool("startPage") ?? false;

    darkMode = prefs.getBool('darkMode') ?? false;

    fetchMetarOnStartup = prefs.getBool("fetchMetarOnStartup") ?? false;
    defaultMetarAirport = prefs.getString("defaultMetarAirport");

    fetchTafOnStartup = prefs.getBool("fetchTafOnStartup") ?? false;
    defaultTafAirport = prefs.getString("defaultTafAirport");
  }

  @observable
  bool startPage = false; // false for metar, true for taf

  @action
  void setStartPage(bool val) {
    startPage = val;
    prefs.setBool("startPage", val);
  }

  @observable
  bool darkMode = false;

  @action
  void setDarkMode(bool value) {
    darkMode = value;
    prefs.setBool('darkMode', value);
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
