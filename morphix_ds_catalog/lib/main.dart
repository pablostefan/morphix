import 'package:flutter/material.dart';

import 'src/component_registry.dart';
import 'src/engine/preview_engine.dart';

void main() {
  runApp(const DsCatalogApp());
}

class DsCatalogApp extends StatelessWidget {
  const DsCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedId = _selectedComponentIdFromUrl();

    return MaterialApp(
      title: 'Morphix DS Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: CatalogHomePage(selectedComponentId: selectedId),
    );
  }
}

String? _selectedComponentIdFromUrl() {
  final componentFromQuery = Uri.base.queryParameters['component'];
  if (componentFromQuery != null &&
      catalogComponentById.containsKey(componentFromQuery)) {
    return componentFromQuery;
  }

  final segments = Uri.base.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.length >= 3) {
    final candidate = segments.last;
    if (catalogComponentById.containsKey(candidate)) {
      return candidate;
    }
  }

  return null;
}

class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({required this.selectedComponentId, super.key});

  final String? selectedComponentId;

  @override
  Widget build(BuildContext context) {
    final selected = selectedComponentId == null
        ? null
        : catalogComponentById[selectedComponentId!];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selected == null
              ? 'Morphix DS Catalog'
              : 'Morphix DS - ${selected.title}',
        ),
      ),
      body: selected == null
          ? const _CatalogIndexView()
          : _CatalogComponentView(component: selected),
    );
  }
}

class _CatalogIndexView extends StatelessWidget {
  const _CatalogIndexView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: catalogComponents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final component = catalogComponents[index];
        return Card(
          child: ListTile(
            title: Text(component.title),
            subtitle: Text(component.description),
            trailing: Text('/${component.id}'),
          ),
        );
      },
    );
  }
}

class _CatalogComponentView extends StatelessWidget {
  const _CatalogComponentView({required this.component});

  final CatalogPreview component;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(component.description),
          const SizedBox(height: 16),
          component.build(context),
        ],
      ),
    );
  }
}
