import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habilift_final/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: HabiLiftApp()));

    // Verify that the splash screen text is present.
    expect(find.text('HabiLift Splash Screen'), findsOneWidget);
  });
}
