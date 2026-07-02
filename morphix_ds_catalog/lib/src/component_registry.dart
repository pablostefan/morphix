import 'package:flutter/material.dart';
import 'package:morphix_design_system/morphix_design_system.dart';

/// Registro canonico de componentes publicados no catalogo.
final List<ComponentSpec> componentSpecs = [
  ComponentSpec(
    id: 'ds_button',
    title: 'DS Button',
    description: 'Botao base do design system.',
    builder: (context) => DsButton(label: 'Continuar', onPressed: () {}),
  ),
];

final Map<String, ComponentSpec> componentSpecById = {
  for (final spec in componentSpecs) spec.id: spec,
};

class ComponentSpec {
  const ComponentSpec({
    required this.id,
    required this.title,
    required this.description,
    required this.builder,
  });

  final String id;
  final String title;
  final String description;
  final WidgetBuilder builder;
}
