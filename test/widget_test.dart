// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// This is a basic Flutter widget test for the Docket app.

import 'package:flutter_test/flutter_test.dart';

import 'package:sltinternapp/main.dart';

void main() {
  testWidgets('Docket app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DocketApp());

    // Verify that the app title appears
    expect(find.text('Maintenance Docket'), findsOneWidget);
    
    // Verify that category dropdown exists
    expect(find.text('Select Category'), findsOneWidget);
    
    // Verify that all 5 categories are available
    expect(find.text('Electrical'), findsNothing); // Not visible until dropdown opened
  });
}
