//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stock/main.dart'; // Ensure this is the correct path to main.dart
import 'package:flutter_stock/page/home_page.dart'; // Add this line
void main() {
  testWidgets('Smoke test for StockHomePage', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Verify if the widget is loaded
    expect(find.byType(StockHomePage), findsOneWidget); // Check if the StockHomePage widget is found
  });
}