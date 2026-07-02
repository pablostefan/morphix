import 'package:morphix_design_system/morphix_design_system.dart';

import '../engine/preview_engine.dart';

CatalogPreview buildDsBadgePreview() {
  return CatalogPreview(
    id: 'ds_badge',
    title: 'DS Badge',
    description: 'Badge para destacar status curto.',
    builder: (context) => const DsBadge(label: 'Novo'),
  );
}
