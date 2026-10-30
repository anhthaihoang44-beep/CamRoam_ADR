import '../../domain/entities/webcam.dart';

class WebcamModel extends Webcam {
  const WebcamModel({
    required super.id,
    required super.title,
    required super.city,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.thumbnailUrl,
    required super.streamUrl,
    required super.category,
    super.isHot = false,
    super.timezone = 'UTC',
    super.isFavorite = false,
  });

  factory WebcamModel.fromJson(Map<String, dynamic> json) {
    return WebcamModel(
      id: json['id'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Unnamed Webcam',
      city: json['city'] as String? ?? 'Unknown City',
      country: json['country'] as String? ?? 'Unknown Country',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      streamUrl: json['streamUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      isHot: json['isHot'] as bool? ?? false,
      timezone: json['timezone'] as String? ?? 'UTC',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'thumbnailUrl': thumbnailUrl,
      'streamUrl': streamUrl,
      'category': category,
      'isHot': isHot,
      'timezone': timezone,
      'isFavorite': isFavorite,
    };
  }
}

