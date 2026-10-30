import 'dart:math' as math;

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Great-circle distance calculator using the Haversine formula
class HaversineCalc {
  HaversineCalc._();

  static const double earthRadiusKm = 6371.0;
  static const double earthRadiusMiles = 3958.756;
  static const double kmToMilesRatio = 0.621371;

  /// Calculate distance in Kilometers between two coordinates
  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final rLat1 = _degreesToRadians(lat1);
    final rLat2 = _degreesToRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(rLat1) *
            math.cos(rLat2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculate distance in Miles between two coordinates
  static double distanceMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return distanceKm(lat1, lon1, lat2, lon2) * kmToMilesRatio;
  }

  /// Calculate total cumulative distance of a multi-point route in Kilometers
  static double routeDistanceKm(List<GeoPoint> points) {
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += distanceKm(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return total;
  }

  /// Convert kilometers to miles
  static double toMiles(double km) => km * kmToMilesRatio;

  /// Convert miles to kilometers
  static double toKm(double miles) => miles / kmToMilesRatio;

  /// Format distance into a display string, e.g. "1,138.4 km" or "707.4 mi"
  static String format(double distanceKm, {bool inMiles = false, int decimals = 1}) {
    final val = inMiles ? toMiles(distanceKm) : distanceKm;
    final unit = inMiles ? 'mi' : 'km';
    return '${val.toStringAsFixed(decimals)} $unit';
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}

