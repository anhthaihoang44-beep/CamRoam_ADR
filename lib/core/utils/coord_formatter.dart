/// Utility to format geographic coordinates into human-readable strings
/// e.g. 40.7484° N, 73.9857° W
class CoordFormatter {
  CoordFormatter._();

  /// Formats [latitude] and [longitude] to string like "40.7484° N, 73.9857° W".
  /// [decimals] defaults to 4.
  static String format(double latitude, double longitude, {int decimals = 4}) {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';

    final latVal = latitude.abs().toStringAsFixed(decimals);
    final lngVal = longitude.abs().toStringAsFixed(decimals);

    return '$latVal° $latDir, $lngVal° $lngDir';
  }

  /// Formats latitude only, e.g. "40.7484° N"
  static String formatLat(double latitude, {int decimals = 4}) {
    final latDir = latitude >= 0 ? 'N' : 'S';
    return '${latitude.abs().toStringAsFixed(decimals)}° $latDir';
  }

  /// Formats longitude only, e.g. "73.9857° W"
  static String formatLng(double longitude, {int decimals = 4}) {
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${longitude.abs().toStringAsFixed(decimals)}° $lngDir';
  }

  /// Formats compass heading, e.g. "76° ENE"
  static String formatHeading(double degrees) {
    // Normalize to 0..360
    final normalized = (degrees % 360 + 360) % 360;
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((normalized + 11.25) / 22.5).floor() % 16;
    return '${normalized.round()}° ${directions[index]}';
  }
}

