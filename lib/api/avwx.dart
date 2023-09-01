import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:metar_viewer_3/models/airport.dart';
import 'package:metar_viewer_3/models/metar.dart';

class AvwxApi {
  String? token = dotenv.env["TOKEN"];
  String baseUrl = "https://avwx.rest/api/";
  Map<String, (Airport, DateTime)> cachedAirports = {};
  Metar? metar;

  /// fetch the metar, and return the metar object and a boolean indicating if the response was cached.
  Future<(Metar, bool)> getMetar(Airport airport) async {
    String icao = airport.icao;
    DateTime currentTime = DateTime.now();

    // if the metar for a specific airport has been fetched less than 3 minutes ago, do not fetch again
    if (cachedAirports[airport] case (Airport apt, DateTime timeFetched)) {
      if (currentTime.difference(timeFetched) < const Duration(minutes: 3)) {
        print("Metar is still valid");
        return (metar!, true);
      }
    }

    String reqUrl = '${baseUrl}metar/${icao.toUpperCase()}?options=info';
    Uri uri = Uri.parse(reqUrl);
    http.Response response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: token!},
    );

    if (response.statusCode == 200) {
      metar = Metar.fromJson(response.body);
      cachedAirports[airport.icao] = (airport, currentTime);
      return (metar!, false);
    } else {
      print(response.statusCode);
      throw Exception("Failed to fetch metar");
    }
  }
}
