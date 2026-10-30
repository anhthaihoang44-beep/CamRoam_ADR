import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamcam/features/live/data/models/webcam_model.dart';
import 'package:roamcam/features/live/presentation/screens/webcam_player_screen.dart';

void main() {
  testWidgets('WebcamPlayerScreen displays title, live badge, and action buttons', (tester) async {
    final mockCam = WebcamModel(
      id: 'cam-test',
      title: 'Shibuya Crossing Test',
      city: 'Tokyo',
      country: 'Japan',
      latitude: 35.6595,
      longitude: 139.7004,
      thumbnailUrl: 'https://images.unsplash.com/photo-1542051841857-5f90071e7989',
      streamUrl: 'https://www.youtube.com/watch?v=test',
      category: 'Skyline',
      isHot: true,
      timezone: 'Asia/Tokyo',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: WebcamPlayerScreen(webcam: mockCam),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify Title & City
    expect(find.text('Shibuya Crossing Test'), findsOneWidget);
    expect(find.text('Tokyo'), findsWidgets);
    expect(find.text('TRỰC TIẾP'), findsOneWidget);
    expect(find.text('Mở Trực Tiếp'), findsOneWidget);
    expect(find.text('Snapshot'), findsOneWidget);
    expect(find.text('Bản đồ'), findsOneWidget);
    expect(find.text('Giờ địa phương'), findsOneWidget);
    expect(find.text('Tọa độ GPS'), findsOneWidget);
  });
}

