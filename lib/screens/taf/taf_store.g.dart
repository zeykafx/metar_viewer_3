// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taf_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TafStore on _TafStore, Store {
  Computed<bool>? _$hasTafComputed;

  @override
  bool get hasTaf => (_$hasTafComputed ??=
          Computed<bool>(() => super.hasTaf, name: '_TafStore.hasTaf'))
      .value;
  Computed<DateTime?>? _$lastUpdatedComputed;

  @override
  DateTime? get lastUpdated =>
      (_$lastUpdatedComputed ??= Computed<DateTime?>(() => super.lastUpdated,
              name: '_TafStore.lastUpdated'))
          .value;

  late final _$tafAtom = Atom(name: '_TafStore.taf', context: context);

  @override
  Taf? get taf {
    _$tafAtom.reportRead();
    return super.taf;
  }

  @override
  set taf(Taf? value) {
    _$tafAtom.reportWrite(value, super.taf, () {
      super.taf = value;
    });
  }

  late final _$hasAlertAtom =
      Atom(name: '_TafStore.hasAlert', context: context);

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
      Atom(name: '_TafStore.alertMessage', context: context);

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
      Atom(name: '_TafStore.isLoading', context: context);

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
      Atom(name: '_TafStore.searchHistory', context: context);

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

  late final _$fetchTafAsyncAction =
      AsyncAction('_TafStore.fetchTaf', context: context);

  @override
  Future<void> fetchTaf(Airport airport) {
    return _$fetchTafAsyncAction.run(() => super.fetchTaf(airport));
  }

  late final _$getAirportFromIcaoAsyncAction =
      AsyncAction('_TafStore.getAirportFromIcao', context: context);

  @override
  Future<Airport> getAirportFromIcao(String icao) {
    return _$getAirportFromIcaoAsyncAction
        .run(() => super.getAirportFromIcao(icao));
  }

  late final _$addToSearchHistoryAsyncAction =
      AsyncAction('_TafStore.addToSearchHistory', context: context);

  @override
  Future<void> addToSearchHistory(Airport airport) {
    return _$addToSearchHistoryAsyncAction
        .run(() => super.addToSearchHistory(airport));
  }

  late final _$removeFromSearchHistoryAsyncAction =
      AsyncAction('_TafStore.removeFromSearchHistory', context: context);

  @override
  Future<void> removeFromSearchHistory(Airport airport) {
    return _$removeFromSearchHistoryAsyncAction
        .run(() => super.removeFromSearchHistory(airport));
  }

  late final _$getSearchHistoryFromPrefsAsyncAction =
      AsyncAction('_TafStore.getSearchHistoryFromPrefs', context: context);

  @override
  Future<void> getSearchHistoryFromPrefs() {
    return _$getSearchHistoryFromPrefsAsyncAction
        .run(() => super.getSearchHistoryFromPrefs());
  }

  late final _$getSuggestionsAsyncAction =
      AsyncAction('_TafStore.getSuggestions', context: context);

  @override
  Future<Iterable<Widget>> getSuggestions(
      SearchController controller, BuildContext context, bool mounted) {
    return _$getSuggestionsAsyncAction
        .run(() => super.getSuggestions(controller, context, mounted));
  }

  late final _$_TafStoreActionController =
      ActionController(name: '_TafStore', context: context);

  @override
  Iterable<Widget> getHistoryList(
      SearchController controller, BuildContext context, bool mounted) {
    final _$actionInfo = _$_TafStoreActionController.startAction(
        name: '_TafStore.getHistoryList');
    try {
      return super.getHistoryList(controller, context, mounted);
    } finally {
      _$_TafStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
taf: ${taf},
hasAlert: ${hasAlert},
alertMessage: ${alertMessage},
isLoading: ${isLoading},
searchHistory: ${searchHistory},
hasTaf: ${hasTaf},
lastUpdated: ${lastUpdated}
    ''';
  }
}
