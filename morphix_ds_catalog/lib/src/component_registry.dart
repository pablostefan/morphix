import 'components/ds_button_preview.dart';
import 'engine/preview_engine.dart';

/// Registro canonico de componentes publicados no catalogo.
final List<CatalogPreview> catalogComponents = [buildDsButtonPreview()];

final Map<String, CatalogPreview> catalogComponentById = {
  for (final component in catalogComponents) component.id: component,
};
