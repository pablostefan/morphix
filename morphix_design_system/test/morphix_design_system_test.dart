import 'package:flutter_test/flutter_test.dart';

import 'package:morphix_design_system/morphix_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('renderiza DsButton com label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DsButton(
            label: 'Continuar',
            onPressed: null,
          ),
        ),
      ),
    );

    expect(find.text('Continuar'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
