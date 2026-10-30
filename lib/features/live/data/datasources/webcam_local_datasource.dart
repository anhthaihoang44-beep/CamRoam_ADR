import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/utils/haversine_calc.dart';
import '../models/webcam_model.dart';

class WebcamLocalDataSource {
  List<WebcamModel> _cachedWebcams = [];

  Future<List<WebcamModel>> loadWebcams() async {
    if (_cachedWebcams.isNotEmpty) return _cachedWebcams;

    try {
      final jsonStr = await rootBundle.loadString('assets/mock/webcams.json');
      final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
      _cachedWebcams = list
          .map((item) => WebcamModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedWebcams;
    } catch (e) {
      // In case bundle is not yet loaded or test environment
      return [];
    }
  }

  List<WebcamModel> getHotWebcams(List<WebcamModel> all) {
    return all.where((c) => c.isHot).toList();
  }

  List<WebcamModel> getWebcamsByCategory(List<WebcamModel> all, String category) {
    if (category.toLowerCase() == 'all') return all;
    return all.where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<WebcamModel> getNearbyWebcams(
    List<WebcamModel> all, {
    required double userLat,
    required double userLng,
    int limit = 10,
  }) {
    final sorted = List<WebcamModel>.from(all);
    sorted.sort((a, b) {
      final distA = HaversineCalc.distanceKm(userLat, userLng, a.latitude, a.longitude);
      final distB = HaversineCalc.distanceKm(userLat, userLng, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });
    return sorted.take(limit).toList();
  }
}

