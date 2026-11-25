import 'package:flutter_test/flutter_test.dart';
import 'package:medical/main.dart';

void main() {
  testWidgets('Welcome screen loads successfully and displays buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Welcome heading is visible
    expect(find.text('Welcome to\nMedical AI Assistant'), findsOneWidget);

    // Verify that 'Start' and 'Help' buttons exist
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
  });
}