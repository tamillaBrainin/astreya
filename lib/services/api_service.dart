import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

// ─── Models ──────────────────────────────────────────────────────────────────

class PlanetPosition {
  final String name;
  final String sign;
  final double degrees;
  final double longitude;
  final int house;
  final bool retrograde;

  PlanetPosition({
    required this.name,
    required this.sign,
    required this.degrees,
    required this.longitude,
    required this.house,
    required this.retrograde,
  });

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      name: json['name'] as String,
      sign: json['sign'] as String,
      degrees: (json['degrees'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      house: json['house'] as int,
      retrograde: json['retrograde'] as bool? ?? false,
    );
  }

  String get houseLabel {
    final suffix = house == 1
        ? 'st'
        : house == 2
            ? 'nd'
            : house == 3
                ? 'rd'
                : 'th';
    return '$house$suffix House';
  }

  String get glyphName {
    const glyphs = {
      'Sun': '\u2600\ufe0f',
      'Moon': '\ud83c\udf19',
      'Mercury': '\u263f',
      'Venus': '\u2640',
      'Mars': '\u2642',
      'Jupiter': '\u2643',
      'Saturn': '\u2644',
      'Uranus': '\u2645',
      'Neptune': '\u2646',
      'Pluto': '\u2647',
    };
    return '${glyphs[name] ?? '\u2605'} $name';
  }
}


class AspectInfo {
  final String planet1;
  final String planet2;
  final String aspect;
  final double orb;

  AspectInfo({
    required this.planet1,
    required this.planet2,
    required this.aspect,
    required this.orb,
  });

  factory AspectInfo.fromJson(Map<String, dynamic> json) {
    return AspectInfo(
      planet1: json['planet1'] as String? ?? '',
      planet2: json['planet2'] as String? ?? '',
      aspect:  json['aspect']  as String? ?? '',
      orb:     (json['orb'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ChartResponse {
  final String ascendantSign;
  final double ascendantDegrees;
  final String mcSign;
  final double mcDegrees;
  final List<PlanetPosition> planets;
  final List<String> patterns;
  final List<AspectInfo> aspects;
  final String interpretation;
  final Map<String, String> planetaryInterpretations;
  final Map<String, String> patternInterpretations;
  final Map<String, String> aspectInterpretations;

  ChartResponse({
    required this.ascendantSign,
    required this.ascendantDegrees,
    required this.mcSign,
    required this.mcDegrees,
    required this.planets,
    required this.patterns,
    required this.aspects,
    required this.interpretation,
    this.planetaryInterpretations = const {},
    this.patternInterpretations = const {},
    this.aspectInterpretations = const {},
  });

  factory ChartResponse.fromJson(Map<String, dynamic> json) {
    final piRaw = json['planetaryInterpretations'] as Map<String, dynamic>? ?? {};
    final prRaw = json['patternInterpretations'] as Map<String, dynamic>? ?? {};
    return ChartResponse(
      ascendantSign: json['ascendantSign'] as String? ?? '',
      ascendantDegrees: (json['ascendant'] as num?)?.toDouble() ?? 0.0,
      mcSign: json['mcSign'] as String? ?? '',
      mcDegrees: (json['mc'] as num?)?.toDouble() ?? 0.0,
      planets: (json['planets'] as List? ?? [])
          .map((p) => PlanetPosition.fromJson(p as Map<String, dynamic>))
          .toList(),
      patterns:
          (json['patterns'] as List?)?.map((e) => e as String).toList() ?? [],
      aspects: (json['aspects'] as List? ?? [])
          .map((a) => AspectInfo.fromJson(a as Map<String, dynamic>))
          .toList(),
      interpretation: json['interpretation'] as String? ?? '',
      planetaryInterpretations: piRaw.map((k, v) => MapEntry(k, v as String)),
      patternInterpretations: prRaw.map((k, v) => MapEntry(k, v as String)),
      aspectInterpretations: (json['aspectInterpretations'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, v as String)),
    );
  }
}

class DailyEnergyResponse {
  final String headline;
  final String description;
  final String moonSign;
  final String moonPhase;

  DailyEnergyResponse({
    required this.headline,
    required this.description,
    required this.moonSign,
    required this.moonPhase,
  });

  factory DailyEnergyResponse.fromJson(Map<String, dynamic> json) {
    return DailyEnergyResponse(
      headline: json['headline'] as String,
      description: json['description'] as String,
      moonSign: json['moonSign'] as String? ?? '',
      moonPhase: json['moonPhase'] as String? ?? '',
    );
  }
}

class TransitItem {
  final String transitPlanet;
  final String transitSign;
  final int transitHouse;
  final String natalPlanet;
  final String aspect;
  final double orb;
  // kept for home_page.dart compatibility
  String get description => '';
  String get timeUntil => '';

  TransitItem({
    required this.transitPlanet,
    required this.transitSign,
    required this.transitHouse,
    required this.natalPlanet,
    required this.aspect,
    required this.orb,
  });

  factory TransitItem.fromJson(Map<String, dynamic> json) {
    return TransitItem(
      transitPlanet: json['transitPlanet'] as String? ?? '',
      transitSign:   json['transitSign']   as String? ?? '',
      transitHouse:  (json['transitHouse'] as num?)?.toInt() ?? 0,
      natalPlanet:   json['natalPlanet']   as String? ?? '',
      aspect:        json['aspect']        as String? ?? '',
      orb:           (json['orb'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get title => '$transitPlanet $aspect $natalPlanet';
}

class TransitResponse {
  final List<TransitItem> transits;
  final String interpretation;

  TransitResponse({required this.transits, required this.interpretation});

  factory TransitResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['transits'] as List? ?? [])
        .map((e) => TransitItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return TransitResponse(
      transits: list,
      interpretation: json['interpretation'] as String? ?? '',
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

class ApiService {
  /// Override at build time with:
  /// flutter build web --dart-define=API_BASE_URL=https://api.example.com
  /// For local web dev against a backend on :8082, use:
  /// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8082
  static const String _configuredBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const Duration _requestTimeout = Duration(seconds: 20);

  /// Web default -> same-origin `/api` (reverse-proxied to backend by Caddy).
  /// Android emulator default -> 10.0.2.2:8082.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return kIsWeb ? '/api' : 'http://10.0.2.2:8082';
  }

  static Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri).timeout(_requestTimeout);
    } on Exception catch (error) {
      throw Exception('GET ${uri.toString()} failed: $error');
    }
  }

  static Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await http
          .post(uri, headers: headers, body: body)
          .timeout(_requestTimeout);
    } on Exception catch (error) {
      throw Exception('POST ${uri.toString()} failed: $error');
    }
  }

  static Future<ChartResponse> getChart({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required String city,
    String language = 'Eng',
  }) async {
    final uri = Uri.parse('$baseUrl/chart').replace(queryParameters: {
      'year': '$year',
      'month': '$month',
      'day': '$day',
      'hour': '$hour',
      'minute': '$minute',
      'city': city,
      'language': language,
    });
    // ignore: avoid_print
    print('[ApiService] GET ${uri.toString()}');
    final response = await _get(uri);
    if (response.statusCode == 200) {
      return ChartResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load chart: ${response.statusCode}\n${response.body}');
  }

  static Future<String> getChartInterpretation({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required String city,
    String language = 'Eng',
  }) async {
    final uri = Uri.parse('$baseUrl/chart/interpretation').replace(
      queryParameters: {
        'year': '$year',
        'month': '$month',
        'day': '$day',
        'hour': '$hour',
        'minute': '$minute',
        'city': city,
        'language': language,
      },
    );
    final response = await _get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['interpretation'] as String? ?? '';
    }
    throw Exception(
      'Failed to load chart interpretation: ${response.statusCode}\n${response.body}',
    );
  }

  static Future<DailyEnergyResponse> getDailyEnergy() async {
    final response = await _get(Uri.parse('$baseUrl/daily/energy'));
    if (response.statusCode == 200) {
      return DailyEnergyResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load daily energy: ${response.statusCode}');
  }

  static Future<List<TransitItem>> getTransits() async {
    final response = await _get(Uri.parse('$baseUrl/transits'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List
          ? data
          : ((data as Map<String, dynamic>)['transits'] as List? ?? []);
      return list
          .map((e) => TransitItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load transits: ${response.statusCode}');
  }

  static Future<TransitResponse> getTransitsForChart({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required String city,
    String language = 'Eng',
  }) async {
    final uri = Uri.parse('$baseUrl/transits').replace(queryParameters: {
      'year': '$year',
      'month': '$month',
      'day': '$day',
      'hour': '$hour',
      'minute': '$minute',
      'city': city,
      'language': language,
    });
    final response = await _get(uri);
    if (response.statusCode == 200) {
      return TransitResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load transits: ${response.statusCode}');
  }

  static Future<String> sendChatMessage(String message) async {
    final response = await _post(
      Uri.parse('$baseUrl/chat/message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String;
    }
    throw Exception('Chat failed: ${response.statusCode}');
  }
}
