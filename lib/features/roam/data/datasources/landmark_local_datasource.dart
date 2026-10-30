import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/utils/daily_seed.dart';
import '../../domain/entities/landmark.dart';
import '../models/landmark_model.dart';

class LandmarkLocalDataSource {
  List<LandmarkModel> _cache = [];

  Future<List<LandmarkModel>> loadLandmarks() async {
    if (_cache.isNotEmpty) return _cache;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock/landmarks.json');
      final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
      _cache = list.map((item) => LandmarkModel.fromJson(item as Map<String, dynamic>)).toList();
      return _cache;
    } catch (_) {
      return [];
    }
  }

  LandmarkModel? getDailyDiscovery(List<LandmarkModel> all) {
    if (all.isEmpty) return null;
    final index = DailySeed.getDailyIndex(all.length);
    return all[index];
  }
}

