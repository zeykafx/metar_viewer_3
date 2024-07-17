import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/models/metar.dart';

import '../models/taf.dart';

class AvwxApi {
  int CACHE_DURATION_MIN = 3;
  String? token = dotenv.env["TOKEN"];
  String baseUrl = "https://avwx.rest/api/";
  Map<String, (Airport, DateTime, Metar)> metarCachedAirports = {};
  Metar? metar;

  Map<String, (Airport, DateTime, Taf)> tafCachedAirport = {};
  Taf? taf;

  /// fetch the metar, and return the metar object and a boolean indicating if the response was cached.
  Future<(Metar, bool)> getMetar(Airport airport) async {
    if (kDebugMode) {
      print("Fetching metar for ${airport.icao}");
    }

    String icao = airport.icao;
    DateTime currentTime = DateTime.now();

    // if the metar for a specific airport has been fetched less than 3 minutes ago, do not fetch again
    if (metarCachedAirports[icao] case (Airport apt, DateTime timeFetched, Metar cachedMetar)) {
      if (currentTime.difference(timeFetched) < Duration(minutes: CACHE_DURATION_MIN)) {
        if (kDebugMode) {
          print("Metar is still valid");
        }
        return (cachedMetar, true);
      }
    }

    String reqUrl = '${baseUrl}metar/${icao.toUpperCase()}?options=summary';
    Dio dio = Dio();
    Response response;
    try {
      response = await dio.get(
        reqUrl,
        options: Options(
          headers: {HttpHeaders.authorizationHeader: token!},
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception("Failed to fetch metar");
    }

    if (response.statusCode == 200) {
      metar = Metar.fromJson(response.data, airport);
      metarCachedAirports[icao] = (airport, currentTime, metar!);
      return (metar!, false);
    } else {
      if (kDebugMode) {
        print(response.statusCode);
      }
      throw Exception("Failed to fetch metar");
    }
  }

  Future<(Taf, bool)> getTaf(Airport airport) async {
    if (kDebugMode) {
      print("Fetching taf for ${airport.icao}");
    }

    String icao = airport.icao;
    DateTime currentTime = DateTime.now();

    if (tafCachedAirport[icao] case (Airport airport, DateTime lastUpdated, Taf cachedTaf)) {
      if (currentTime.difference(lastUpdated) < Duration(minutes: CACHE_DURATION_MIN)) {
        // taf report was cached
        return (taf!, true);
      }
    }

    Dio dio = Dio();
    String reqUrl = '${baseUrl}taf/$icao?options=summary&remove=temps,alts';
    Response response;

    try {
      response = await dio.get(
        reqUrl,
        options: Options(
          headers: {HttpHeaders.authorizationHeader: token!},
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception("Failed to fetch taf");
    }

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.data);
      }
      taf = Taf.fromJson(response.data);
      tafCachedAirport[icao] = (airport, currentTime, taf!);
      return (taf!, false);
    } else {
      if (kDebugMode) {
        print(response.statusCode);
      }
      throw Exception("Failed to fetch taf");
    }
  }
}
