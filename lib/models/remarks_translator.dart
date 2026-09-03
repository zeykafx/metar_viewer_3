class RemarkTranslator {
  RemarkTranslator._();

  static const Map<String, String> _staticCodes = {
    'AO1': 'Automated station without precipitation discriminator',
    'AO2': 'Automated station with precipitation discriminator',
    'PNO': 'Precipitation sensor not operational',
    'NOSPEC': 'No SPECI reports are taken at this station',
    'NOSPECI': 'No SPECI reports are taken at this station',
    r'$': 'Station needs maintenance',
    'COR': 'Corrected observation',
    'AUTO': 'Automated observation',
    'PRESFR': 'Pressure falling rapidly',
    'PRESRR': 'Pressure rising rapidly',
    'SLPNO': 'Sea-level pressure not available',
    'FZRANO': 'Freezing rain sensor not operational',
    'TSNO': 'Thunderstorm sensor not operational',
    'PWINO': 'Present weather identifier not operational',
    'VISNO': 'Visibility sensor not operational',
    'CHINO': 'Ceiling height sensor not operational',
    'RVRNO': 'Runway visual range sensor not operational',
    'FROPA': 'Frontal passage',
    'CB': 'Cumulonimbus',
    'TCU': 'Towering cumulus',
    'ACSL': 'Altocumulus standing lenticular',
    'ACC': 'Altocumulus castellanus',
    'EMBDD': 'Embedded',
    'OCNL': 'Occasional',
    'FRQ': 'Frequent',
    'LTGCG': 'Lightning cloud-to-ground',
    'LTGCC': 'Lightning cloud-to-cloud',
    'LTGIC': 'Lightning in-cloud',
    'RGD': 'Ragged',
    'NOSIG': 'No significant change expected',
    'OVR': 'over',
    'RDG': 'ridge',
    'OVHD': 'overhead',
    'DIST': 'distant',
    'MOV': 'moving',
    'NE': 'northeast',
    'SE': 'southeast',
    'SW': 'southwest',
    'NW': 'northwest',
  };

  static final RegExp _slp = RegExp(r'^SLP\d{3}$');
  static final RegExp _tempDew = RegExp(r'^T\d{8}$');
  static final RegExp _temp24 = RegExp(r'^4\d{8}$');
  static final RegExp _snowDepth = RegExp(r'^4/\d{3}$');
  static final RegExp _max6 = RegExp(r'^1\d{4}$');
  static final RegExp _min6 = RegExp(r'^2\d{4}$');
  static final RegExp _pressureTendency = RegExp(r'^5\d{4}$');
  static final RegExp _precipHour = RegExp(r'^P\d{4}$');
  static final RegExp _precip36 = RegExp(r'^6\d{4}$');
  static final RegExp _precip24 = RegExp(r'^7\d{4}$');
  static final RegExp _sunshine = RegExp(r'^98\d{3}$');
  static final RegExp _beginEnd = RegExp(r'^([A-Z]+)B(\d{2,4})E(\d{2,4})$');
  static final RegExp _begin = RegExp(r'^([A-Z]+)B(\d{2,4})$');
  static final RegExp _end = RegExp(r'^([A-Z]+)E(\d{2,4})$');
  static final RegExp _cloudOpacity = RegExp(r'([A-Z]{1,4})([0-8])');
  static final RegExp _cloudOpacityGroups = RegExp(r'^(?:[A-Z]{1,4}[0-8])+$');
  static final RegExp _runwayState = RegExp(
    r'^R(\d{2})/([0-9/])([0-9/])([0-9/]{2})([0-9/]{2})$',
  );

  /// translates a raw remarks string into a readable English sentence.
  static String translate(String remarks) {
    final String trimmed = remarks.trim();
    if (trimmed.isEmpty) return '';

    final List<String> tokens = trimmed.split(RegExp(r'\s+'));
    final List<String> output = [];

    for (int i = 0; i < tokens.length; i++) {
      final String token = tokens[i];
      final String upper = token.toUpperCase();

      if (upper == 'RMK') continue;

      // peak wind: "PK WND 28045/15".
      if (upper == 'PK' &&
          i + 2 < tokens.length &&
          tokens[i + 1].toUpperCase() == 'WND') {
        output.add(_peakWind(tokens[i + 2]));
        i += 2;
        continue;
      }

      // wind shift: "WSHFT 30".
      if (upper == 'WSHFT' && i + 1 < tokens.length) {
        output.add('Wind shift at ${_timeString(tokens[i + 1])}');
        i += 1;
        continue;
      }

      // wind shear: "WS RWY36" or "WS ALL RWY".
      if (upper == 'WS' && i + 1 < tokens.length) {
        final String next = tokens[i + 1].toUpperCase();
        if (next == 'ALL' &&
            i + 2 < tokens.length &&
            tokens[i + 2].toUpperCase() == 'RWY') {
          output.add('Wind shear on all runways');
          i += 2;
          continue;
        }
        if (next.startsWith('RWY')) {
          output.add('Wind shear on runway ${next.substring(3)}');
          i += 1;
          continue;
        }
      }

      // ceiling remark: "CIG 004V008" or "CIG RGD".
      if (upper == 'CIG' && i + 1 < tokens.length) {
        if (tokens[i + 1].toUpperCase() == 'RGD') {
          output.add('Ceiling ragged');
        } else {
          output.add(_ceiling(tokens[i + 1]));
        }
        i += 1;
        continue;
      }

      final String translated = _translateToken(token, upper);
      if (translated.isNotEmpty) output.add(translated);
    }

    return output.join(', ');
  }

  static String _translateToken(String token, String upper) {
    final String? staticValue = _staticCodes[upper];
    if (staticValue != null) return staticValue;

    if (_slp.hasMatch(upper)) return _seaLevelPressure(token);
    if (_tempDew.hasMatch(upper)) return _temperatureDewpoint(token);
    if (_temp24.hasMatch(upper)) return _twentyFourHourTemperature(token);
    if (_snowDepth.hasMatch(upper)) {
      return 'Snow depth ${int.parse(token.substring(2))} in';
    }
    if (_max6.hasMatch(upper)) {
      return '6-hour maximum temperature ${_signedTenths(token.substring(1, 5))}°C';
    }
    if (_min6.hasMatch(upper)) {
      return '6-hour minimum temperature ${_signedTenths(token.substring(1, 5))}°C';
    }
    if (_pressureTendency.hasMatch(upper)) return _pressureTendencyText(token);
    if (_precipHour.hasMatch(upper)) return _precipitation('hour', token);
    if (_precip36.hasMatch(upper)) return _precipitation('3/6 hours', token);
    if (_precip24.hasMatch(upper)) return _precipitation('24 hours', token);
    if (_sunshine.hasMatch(upper)) {
      return 'Duration of sunlight: ${int.parse(token.substring(2))} minutes';
    }

    final RegExpMatch? beginEnd = _beginEnd.firstMatch(token);
    if (beginEnd != null) {
      return '${_weatherName(beginEnd.group(1)!)} began at ${_timeString(beginEnd.group(2)!)} and ended at ${_timeString(beginEnd.group(3)!)}';
    }

    final RegExpMatch? begin = _begin.firstMatch(token);
    if (begin != null) {
      return '${_weatherName(begin.group(1)!)} began at ${_timeString(begin.group(2)!)}';
    }

    final RegExpMatch? end = _end.firstMatch(token);
    if (end != null) {
      return '${_weatherName(end.group(1)!)} ended at ${_timeString(end.group(2)!)}';
    }

    if (_runwayState.hasMatch(token)) return _runwayStateText(token);

    final String? cloud = _cloudOpacityGroup(token);
    if (cloud != null) return cloud;

    return token;
  }

  /// decodes a `snnn` temperature group: sign (`0`/`1`) + value in tenths °C.
  static String _signedTenths(String code) {
    final double value = int.parse(code.substring(1)) / 10.0;
    return (code[0] == '1' ? -value : value).toStringAsFixed(1);
  }

  static String _seaLevelPressure(String token) {
    final String digits = token.substring(3);
    final String prefix = int.parse(digits[0]) >= 5 ? '9' : '10';
    final double hPa = int.parse('$prefix$digits') / 10.0;
    return 'Sea-level pressure ${hPa.toStringAsFixed(1)} hPa';
  }

  static String _temperatureDewpoint(String token) {
    return 'Temperature ${_signedTenths(token.substring(1, 5))}°C and dewpoint ${_signedTenths(token.substring(5, 9))}°C';
  }

  static String _twentyFourHourTemperature(String token) {
    return '24-hour temperature: maximum ${_signedTenths(token.substring(1, 5))}°C, minimum ${_signedTenths(token.substring(5, 9))}°C';
  }

  static String _pressureTendencyText(String token) {
    final int code = int.parse(token.substring(1, 2));
    final double change = int.parse(token.substring(2)) / 10.0;
    final String description =
        _pressureTendencyDescriptions[code] ?? 'Unknown tendency';
    return '3-hour pressure tendency: $description, change ${change.toStringAsFixed(1)} hPa';
  }

  static String _precipitation(String label, String token) {
    final int hundredths = int.parse(token.substring(1));
    final String amount = hundredths == 0
        ? 'trace'
        : '${(hundredths / 100).toStringAsFixed(2)} in';
    return 'Precipitation in the last $label: $amount';
  }

  static String _weatherName(String code) {
    switch (code.toUpperCase()) {
      case 'RA':
        return 'Rain';
      case 'SN':
        return 'Snow';
      case 'TS':
        return 'Thunderstorm';
      case 'DZ':
        return 'Drizzle';
      case 'FZRA':
        return 'Freezing rain';
      case 'FZDZ':
        return 'Freezing drizzle';
      case 'GR':
        return 'Hail';
      case 'GS':
        return 'Small hail';
      case 'PL':
        return 'Ice pellets';
      case 'UP':
        return 'Unknown precipitation';
      case 'SH':
        return 'Showers';
      case 'SHRA':
        return 'Rain showers';
      case 'SHSN':
        return 'Snow showers';
      case 'TSRA':
        return 'Thunderstorm with rain';
      case 'TSSN':
        return 'Thunderstorm with snow';
      default:
        return code;
    }
  }

  static String _timeString(String raw) {
    if (raw.length <= 2) return ':$raw past the hour';
    if (raw.length == 4) {
      return '${raw.substring(0, 2)}:${raw.substring(2)} UTC';
    }
    return raw;
  }

  static String _peakWind(String value) {
    final RegExpMatch? match = RegExp(r'^(\d{3})(\d{2,3})/(\d{2,4})$')
        .firstMatch(value);
    if (match == null) return 'Peak wind $value';

    return 'Peak wind ${match.group(1)}° at ${match.group(2)} knots at ${_timeString(match.group(3)!)}';
  }

  static String _ceiling(String value) {
    final RegExpMatch? match = RegExp(r'^(\d{3})V(\d{3})$').firstMatch(value);
    if (match != null) {
      final int low = int.parse(match.group(1)!) * 100;
      final int high = int.parse(match.group(2)!) * 100;
      return 'Ceiling variable between $low and $high feet';
    }
    return 'Ceiling $value';
  }

  static String? _cloudOpacityGroup(String token) {
    if (!_cloudOpacityGroups.hasMatch(token)) return null;

    final List<String> parts = [];
    for (final RegExpMatch match in _cloudOpacity.allMatches(token)) {
      final String? type = _cloudTypes[match.group(1)!];
      if (type == null) return null;
      final int oktas = int.parse(match.group(2)!);
      final String amount = oktas == 0 ? 'trace' : '$oktas oktas';
      parts.add('$type, $amount');
    }
    return parts.join(', ');
  }

  static String _runwayStateText(String token) {
    final RegExpMatch? match = _runwayState.firstMatch(token);
    if (match == null) return token;

    final String runway = switch (match.group(1)!) {
      '88' => 'All runways',
      '99' => 'Runway (repeat of last report)',
      final code => 'Runway $code',
    };

    final String deposit = _runwayDeposits[match.group(2)] ?? 'unknown deposit';
    final String extent = _runwayExtent[match.group(3)] ?? 'unknown extent';
    final String depth = _runwayDepth(match.group(4)!);
    final String braking = _runwayBraking(match.group(5)!);

    return '$runway: $deposit, $extent, $depth, $braking';
  }

  static String _runwayDepth(String code) {
    if (code == '//') return 'depth not reported';
    final int value = int.tryParse(code) ?? -1;
    if (value >= 0 && value <= 90) return '$value mm';
    return switch (value) {
      92 => '10 cm',
      93 => '15 cm',
      94 => '20 cm',
      95 => '25 cm',
      96 => '30 cm',
      97 => '35 cm',
      98 => '40 cm or more',
      99 => 'runway not operational',
      _ => 'depth unknown',
    };
  }

  static String _runwayBraking(String code) {
    if (code == '//') return 'braking action not reported';
    final int value = int.tryParse(code) ?? -1;
    if (value >= 0 && value <= 90) {
      return 'friction coefficient ${(value / 100).toStringAsFixed(2)}';
    }
    return switch (value) {
      91 => 'braking action poor',
      92 => 'braking action medium/poor',
      93 => 'braking action medium',
      94 => 'braking action medium/good',
      95 => 'braking action good',
      99 => 'braking action unreliable',
      _ => 'braking action unknown',
    };
  }

  static const Map<String, String> _cloudTypes = {
    'CI': 'Cirrus',
    'CC': 'Cirrocumulus',
    'CS': 'Cirrostratus',
    'AC': 'Altocumulus',
    'AS': 'Altostratus',
    'NS': 'Nimbostratus',
    'SC': 'Stratocumulus',
    'ST': 'Stratus',
    'CU': 'Cumulus',
    'CB': 'Cumulonimbus',
    'TCU': 'Towering cumulus',
    'CF': 'Cumulus fractus',
    'SF': 'Stratus fractus',
    'F': 'Fog',
    'S': 'Stratus',
  };

  static const Map<String, String> _runwayDeposits = {
    '0': 'clear and dry',
    '1': 'damp',
    '2': 'wet or water patches',
    '3': 'rime or frost',
    '4': 'dry snow',
    '5': 'wet snow',
    '6': 'slush',
    '7': 'ice',
    '8': 'compacted or rolled snow',
    '9': 'frozen ruts or ridges',
    '/': 'deposit not reported',
  };

  static const Map<String, String> _runwayExtent = {
    '1': '10% or less covered',
    '2': '11% to 25% covered',
    '5': '26% to 50% covered',
    '9': '51% to 100% covered',
    '/': 'extent not reported',
  };

  static const Map<int, String> _pressureTendencyDescriptions = {
    0: 'Increasing, then decreasing',
    1: 'Increasing, then steady',
    2: 'Increasing steadily or unsteadily',
    3: 'Decreasing or steady, then increasing',
    4: 'Steady',
    5: 'Decreasing, then increasing',
    6: 'Decreasing, then steady',
    7: 'Decreasing steadily or unsteadily',
    8: 'Steady or increasing, then decreasing',
  };
}
