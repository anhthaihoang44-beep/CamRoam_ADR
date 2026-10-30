import '../../domain/entities/landmark.dart';

class LandmarkModel extends Landmark {
  const LandmarkModel({
    required super.id,
    required super.name,
    required super.city,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.category,
    required super.thumbnailUrl,
    required super.panorama360Url,
    required super.badgeIcon,
    required super.description,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    return LandmarkModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Landmark',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Historic',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      panorama360Url: json['panorama360Url'] as String? ?? '',
      badgeIcon: json['badgeIcon'] as String? ?? 'landmark',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'panorama360Url': panorama360Url,
      'badgeIcon': badgeIcon,
      'description': description,
    };
  }
}

