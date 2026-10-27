import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:houseprice_mobile_app/main.dart';
import 'package:houseprice_mobile_app/routes.dart';

void main() {
  testWidgets('HousePrice app shows its main navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const HousePriceApp(initialRoute: AppRoutes.main));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Estimasi'), findsOneWidget);
    expect(find.text('KPR'), findsOneWidget);
  });
}
