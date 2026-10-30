enum StampSource {
  liveWebcamView,
  gpsCameraCapture,
  roam360,
  manualDiscovery,
}

class PassportStamp {
  final String landmarkId;
  final String title;
  final String city;
  final String country;
  final DateTime unlockedAt;
  final StampSource source;
  final String badgeIcon;
  final int visitCount;

  const PassportStamp({
    required this.landmarkId,
    required this.title,
    required this.city,
    required this.country,
    required this.unlockedAt,
    required this.source,
    required this.badgeIcon,
    this.visitCount = 1,
  });

  PassportStamp copyWith({
    int? visitCount,
    DateTime? unlockedAt,
    StampSource? source,
  }) {
    return PassportStamp(
      landmarkId: landmarkId,
      title: title,
      city: city,
      country: country,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      source: source ?? this.source,
      badgeIcon: badgeIcon,
      visitCount: visitCount ?? this.visitCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'landmarkId': landmarkId,
      'title': title,
      'city': city,
      'country': country,
      'unlockedAt': unlockedAt.toIso8601String(),
      'source': source.name,
      'badgeIcon': badgeIcon,
      'visitCount': visitCount,
    };
  }

  factory PassportStamp.fromJson(Map<String, dynamic> json) {
    return PassportStamp(
      landmarkId: json['landmarkId'] as String,
      title: json['title'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      source: StampSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => StampSource.manualDiscovery,
      ),
      badgeIcon: (json['badgeIcon'] as String?) ?? 'landmark',
      visitCount: (json['visitCount'] as int?) ?? 1,
    );
  }
}

