import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

/// Low-pass filtered sensor service for compass
class SensorService {
  static const double _alpha = 0.12; // LPF coefficient

  static Stream<double> compassHeadingStream() async* {
    double filtered = 0;
    await for (final event in magnetometerEventStream()) {
      double raw = math.atan2(event.y, event.x) * (180 / math.pi);
      if (raw < 0) raw += 360;
      filtered = _alpha * raw + (1 - _alpha) * filtered;
      yield filtered;
    }
  }
}
