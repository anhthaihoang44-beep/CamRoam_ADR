class Landmark {
  final String id;
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String category;
  final String thumbnailUrl;
  final String panorama360Url;
  final String badgeIcon;
  final String description;

  const Landmark({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.thumbnailUrl,
    required this.panorama360Url,
    required this.badgeIcon,
    required this.description,
  });
}

