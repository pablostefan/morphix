import 'package:flutter/material.dart';

import 'src/component_registry.dart';

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
      componentSpecById.containsKey(componentFromQuery)) {
    return componentFromQuery;
  }

  final segments = Uri.base.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.length >= 3) {
    final candidate = segments.last;
    if (componentSpecById.containsKey(candidate)) {
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
        : componentSpecById[selectedComponentId!];

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
          : _CatalogComponentView(spec: selected),
    );
  }
}

class _CatalogIndexView extends StatelessWidget {
  const _CatalogIndexView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: componentSpecs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final spec = componentSpecs[index];
        return Card(
          child: ListTile(
            title: Text(spec.title),
            subtitle: Text(spec.description),
            trailing: Text('/${spec.id}'),
          ),
        );
      },
    );
  }
}

class _CatalogComponentView extends StatelessWidget {
  const _CatalogComponentView({required this.spec});

  final ComponentSpec spec;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(spec.description),
          const SizedBox(height: 16),
          spec.builder(context),
        ],
      ),
    );
  }
}
