class Webcam {
  final String id;
  final String title;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String thumbnailUrl;
  final String streamUrl;
  final String category;
  final bool isHot;
  final String timezone;
  final bool isFavorite;

  const Webcam({
    required this.id,
    required this.title,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.thumbnailUrl,
    required this.streamUrl,
    required this.category,
    this.isHot = false,
    this.timezone = 'UTC',
    this.isFavorite = false,
  });

  Webcam copyWith({
    String? id,
    String? title,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? thumbnailUrl,
    String? streamUrl,
    String? category,
    bool? isHot,
    String? timezone,
    bool? isFavorite,
  }) {
    return Webcam(
      id: id ?? this.id,
      title: title ?? this.title,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      category: category ?? this.category,
      isHot: isHot ?? this.isHot,
      timezone: timezone ?? this.timezone,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

