import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecocollect/main.dart';
import 'package:ecocollect/services/request_repository.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await RequestRepository().initialize();
  });

  testWidgets('EcoCollectApp renders home dashboard and navigation destinations', (WidgetTester tester) async {
    // Provide adequate viewport for scrollable dashboard
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const EcoCollectApp());
    await tester.pumpAndSettle();

    // Verify app title and welcome message
    expect(find.text('EcoCollect'), findsWidgets);
    expect(find.text('Give Your Old Electronics\na New Purpose!'), findsOneWidget);

    // Verify statistics section
    expect(find.text('Total Items Submitted'), findsOneWidget);
    expect(find.text('Pending Pickups'), findsOneWidget);
    expect(find.text('Collected Items'), findsOneWidget);

    // Verify category section
    expect(find.text('What Can You Recycle?'), findsOneWidget);
    expect(find.text('Mobile Phones'), findsWidgets);
    expect(find.text('Laptops and Computers'), findsWidgets);
    expect(find.text('Batteries'), findsWidgets);
    expect(find.text('Chargers and Cables'), findsWidgets);
    expect(find.text('Televisions'), findsWidgets);
    expect(find.text('Keyboards and Accessories'), findsWidgets);
    expect(find.text('Other Electronics'), findsWidgets);

    // Verify navigation tabs
    expect(find.text('Home Dashboard'), findsWidgets);
    expect(find.text('Add E-Waste'), findsWidgets);
    expect(find.text('My Requests'), findsWidgets);
    expect(find.text('Profile & Impact'), findsWidgets);
  });
}
