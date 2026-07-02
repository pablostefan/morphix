import 'package:morphix_design_system/morphix_design_system.dart';

import '../engine/preview_engine.dart';

CatalogPreview buildDsButtonPreview() {
  return CatalogPreview(
    id: 'ds_button',
    title: 'DS Button',
    description: 'Botao base do design system.',
    builder: (context) => DsButton(label: 'Continuar', onPressed: () {}),
  );
}
