import 'package:flutter_test/flutter_test.dart';

import 'package:morphix_ds_catalog/main.dart';

void main() {
  testWidgets('mostra componente registrado no indice', (tester) async {
    await tester.pumpWidget(const DsCatalogApp());

    expect(find.text('DS Button'), findsOneWidget);
    expect(find.text('Botao base do design system.'), findsOneWidget);
  });
}
