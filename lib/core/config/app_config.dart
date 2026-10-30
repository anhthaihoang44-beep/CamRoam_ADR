import 'package:flutter/services.dart';

class AppConfig {
  static String windyApiKey = '';
  static String mapStyle = 'osm';

  static Future<void> load() async {
    try {
      final envStr = await rootBundle.loadString('.env');
      for (final line in envStr.split('\n')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          if (key == 'WINDY_API_KEY') windyApiKey = value;
          if (key == 'MAP_STYLE') mapStyle = value;
        }
      }
    } catch (_) {}
  }

  static bool get hasWindyKey => windyApiKey.isNotEmpty;
}

