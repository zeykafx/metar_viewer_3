// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$startPageAtom =
      Atom(name: '_SettingsStore.startPage', context: context);

  @override
  bool get startPage {
    _$startPageAtom.reportRead();
    return super.startPage;
  }

  @override
  set startPage(bool value) {
    _$startPageAtom.reportWrite(value, super.startPage, () {
      super.startPage = value;
    });
  }

  late final _$initializedAtom =
      Atom(name: '_SettingsStore.initialized', context: context);

  @override
  bool get initialized {
    _$initializedAtom.reportRead();
    return super.initialized;
  }

  @override
  set initialized(bool value) {
    _$initializedAtom.reportWrite(value, super.initialized, () {
      super.initialized = value;
    });
  }

  late final _$darkModeAtom =
      Atom(name: '_SettingsStore.darkMode', context: context);

  @override
  bool get darkMode {
    _$darkModeAtom.reportRead();
    return super.darkMode;
  }

  @override
  set darkMode(bool value) {
    _$darkModeAtom.reportWrite(value, super.darkMode, () {
      super.darkMode = value;
    });
  }

  late final _$fetchMetarOnStartupAtom =
      Atom(name: '_SettingsStore.fetchMetarOnStartup', context: context);

  @override
  bool get fetchMetarOnStartup {
    _$fetchMetarOnStartupAtom.reportRead();
    return super.fetchMetarOnStartup;
  }

  @override
  set fetchMetarOnStartup(bool value) {
    _$fetchMetarOnStartupAtom.reportWrite(value, super.fetchMetarOnStartup, () {
      super.fetchMetarOnStartup = value;
    });
  }

  late final _$fetchTafOnStartupAtom =
      Atom(name: '_SettingsStore.fetchTafOnStartup', context: context);

  @override
  bool get fetchTafOnStartup {
    _$fetchTafOnStartupAtom.reportRead();
    return super.fetchTafOnStartup;
  }

  @override
  set fetchTafOnStartup(bool value) {
    _$fetchTafOnStartupAtom.reportWrite(value, super.fetchTafOnStartup, () {
      super.fetchTafOnStartup = value;
    });
  }

  late final _$defaultMetarAirportAtom =
      Atom(name: '_SettingsStore.defaultMetarAirport', context: context);

  @override
  String? get defaultMetarAirport {
    _$defaultMetarAirportAtom.reportRead();
    return super.defaultMetarAirport;
  }

  @override
  set defaultMetarAirport(String? value) {
    _$defaultMetarAirportAtom.reportWrite(value, super.defaultMetarAirport, () {
      super.defaultMetarAirport = value;
    });
  }

  late final _$defaultTafAirportAtom =
      Atom(name: '_SettingsStore.defaultTafAirport', context: context);

  @override
  String? get defaultTafAirport {
    _$defaultTafAirportAtom.reportRead();
    return super.defaultTafAirport;
  }

  @override
  set defaultTafAirport(String? value) {
    _$defaultTafAirportAtom.reportWrite(value, super.defaultTafAirport, () {
      super.defaultTafAirport = value;
    });
  }

  late final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore', context: context);

  @override
  void setStartPage(bool val) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setStartPage');
    try {
      return super.setStartPage(val);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDarkMode(bool value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setDarkMode');
    try {
      return super.setDarkMode(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFetchMetarOnStartup(bool value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setFetchMetarOnStartup');
    try {
      return super.setFetchMetarOnStartup(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFetchTafOnStartup(bool value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setFetchTafOnStartup');
    try {
      return super.setFetchTafOnStartup(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDefaultMetarAirport(String value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setDefaultMetarAirport');
    try {
      return super.setDefaultMetarAirport(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDefaultTafAirport(String value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setDefaultTafAirport');
    try {
      return super.setDefaultTafAirport(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
startPage: ${startPage},
initialized: ${initialized},
darkMode: ${darkMode},
fetchMetarOnStartup: ${fetchMetarOnStartup},
fetchTafOnStartup: ${fetchTafOnStartup},
defaultMetarAirport: ${defaultMetarAirport},
defaultTafAirport: ${defaultTafAirport}
    ''';
  }
}
