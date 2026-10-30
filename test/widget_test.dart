import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamcam/main.dart';

void main() {
  testWidgets('RoamCamApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RoamCamApp(),
      ),
    );
    expect(find.byType(RoamCamApp), findsOneWidget);
  });
}
