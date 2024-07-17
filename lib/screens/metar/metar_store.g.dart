// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metar_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MetarStore on _MetarStore, Store {
  Computed<bool>? _$hasMetarComputed;

  @override
  bool get hasMetar => (_$hasMetarComputed ??=
          Computed<bool>(() => super.hasMetar, name: '_MetarStore.hasMetar'))
      .value;
  Computed<DateTime?>? _$lastUpdatedComputed;

  @override
  DateTime? get lastUpdated =>
      (_$lastUpdatedComputed ??= Computed<DateTime?>(() => super.lastUpdated,
              name: '_MetarStore.lastUpdated'))
          .value;

  late final _$metarAtom = Atom(name: '_MetarStore.metar', context: context);

  @override
  Metar? get metar {
    _$metarAtom.reportRead();
    return super.metar;
  }

  @override
  set metar(Metar? value) {
    _$metarAtom.reportWrite(value, super.metar, () {
      super.metar = value;
    });
  }

  late final _$hasAlertAtom =
      Atom(name: '_MetarStore.hasAlert', context: context);

  @override
  bool get hasAlert {
    _$hasAlertAtom.reportRead();
    return super.hasAlert;
  }

  @override
  set hasAlert(bool value) {
    _$hasAlertAtom.reportWrite(value, super.hasAlert, () {
      super.hasAlert = value;
    });
  }

  late final _$alertMessageAtom =
      Atom(name: '_MetarStore.alertMessage', context: context);

  @override
  String get alertMessage {
    _$alertMessageAtom.reportRead();
    return super.alertMessage;
  }

  @override
  set alertMessage(String value) {
    _$alertMessageAtom.reportWrite(value, super.alertMessage, () {
      super.alertMessage = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_MetarStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$searchHistoryAtom =
      Atom(name: '_MetarStore.searchHistory', context: context);

  @override
  List<Airport> get searchHistory {
    _$searchHistoryAtom.reportRead();
    return super.searchHistory;
  }

  @override
  set searchHistory(List<Airport> value) {
    _$searchHistoryAtom.reportWrite(value, super.searchHistory, () {
      super.searchHistory = value;
    });
  }

  late final _$fetchMetarAsyncAction =
      AsyncAction('_MetarStore.fetchMetar', context: context);

  @override
  Future<void> fetchMetar(Airport airport) {
    return _$fetchMetarAsyncAction.run(() => super.fetchMetar(airport));
  }

  late final _$getAirportFromIcaoAsyncAction =
      AsyncAction('_MetarStore.getAirportFromIcao', context: context);

  @override
  Future<Airport> getAirportFromIcao(String icao) {
    return _$getAirportFromIcaoAsyncAction
        .run(() => super.getAirportFromIcao(icao));
  }

  late final _$addToSearchHistoryAsyncAction =
      AsyncAction('_MetarStore.addToSearchHistory', context: context);

  @override
  Future<void> addToSearchHistory(Airport airport) {
    return _$addToSearchHistoryAsyncAction
        .run(() => super.addToSearchHistory(airport));
  }

  late final _$removeFromSearchHistoryAsyncAction =
      AsyncAction('_MetarStore.removeFromSearchHistory', context: context);

  @override
  Future<void> removeFromSearchHistory(Airport airport) {
    return _$removeFromSearchHistoryAsyncAction
        .run(() => super.removeFromSearchHistory(airport));
  }

  late final _$getSearchHistoryFromPrefsAsyncAction =
      AsyncAction('_MetarStore.getSearchHistoryFromPrefs', context: context);

  @override
  Future<void> getSearchHistoryFromPrefs() {
    return _$getSearchHistoryFromPrefsAsyncAction
        .run(() => super.getSearchHistoryFromPrefs());
  }

  late final _$getSuggestionsAsyncAction =
      AsyncAction('_MetarStore.getSuggestions', context: context);

  @override
  Future<Iterable<Widget>> getSuggestions(
      SearchController controller, BuildContext context, bool mounted) {
    return _$getSuggestionsAsyncAction
        .run(() => super.getSuggestions(controller, context, mounted));
  }

  late final _$_MetarStoreActionController =
      ActionController(name: '_MetarStore', context: context);

  @override
  Iterable<Widget> getHistoryList(
      SearchController controller, BuildContext context, bool mounted) {
    final _$actionInfo = _$_MetarStoreActionController.startAction(
        name: '_MetarStore.getHistoryList');
    try {
      return super.getHistoryList(controller, context, mounted);
    } finally {
      _$_MetarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
metar: ${metar},
hasAlert: ${hasAlert},
alertMessage: ${alertMessage},
isLoading: ${isLoading},
searchHistory: ${searchHistory},
hasMetar: ${hasMetar},
lastUpdated: ${lastUpdated}
    ''';
  }
}
