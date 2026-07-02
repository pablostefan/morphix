import 'package:flutter/material.dart';

import 'src/compare_frame.dart';
import 'src/component_registry.dart';
import 'src/engine/preview_engine.dart';

void main() {
  runApp(const DsCatalogApp());
}

class DsCatalogApp extends StatelessWidget {
  const DsCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routeState = _routeStateFromUrl();

    return MaterialApp(
      title: 'Morphix DS Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: _CatalogHomePage(routeState: routeState),
    );
  }
}

_CatalogRouteState _routeStateFromUrl() {
  final query = Uri.base.queryParameters;
  final componentFromQuery = query['component'];

  if (query['compare'] == '1' &&
      componentFromQuery != null &&
      catalogComponentById.containsKey(componentFromQuery)) {
    final currentBranch = _currentBranchSlug();
    final compareConfig = _CompareConfig(
      componentId: componentFromQuery,
      baseBranch: query['base'] ?? 'main',
      headBranch: query['head'] ?? currentBranch,
      baseVersion: query['vbase'] ?? 'latest',
      headVersion: query['vhead'] ?? 'latest',
    );
    return _CatalogRouteState(compareConfig: compareConfig);
  }

  if (componentFromQuery != null &&
      catalogComponentById.containsKey(componentFromQuery)) {
    return _CatalogRouteState(selectedComponentId: componentFromQuery);
  }

  final segments = Uri.base.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.length >= 3) {
    final candidate = segments.last;
    if (catalogComponentById.containsKey(candidate)) {
      return _CatalogRouteState(selectedComponentId: candidate);
    }
  }

  return const _CatalogRouteState();
}

String _currentBranchSlug() {
  final segments = Uri.base.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.length >= 2) {
    return segments[1];
  }
  return 'main';
}

class _CatalogRouteState {
  const _CatalogRouteState({
    this.selectedComponentId,
    this.compareConfig,
  });

  final String? selectedComponentId;
  final _CompareConfig? compareConfig;
}

class _CompareConfig {
  const _CompareConfig({
    required this.componentId,
    required this.baseBranch,
    required this.headBranch,
    required this.baseVersion,
    required this.headVersion,
  });

  final String componentId;
  final String baseBranch;
  final String headBranch;
  final String baseVersion;
  final String headVersion;
}

class _CatalogHomePage extends StatelessWidget {
  const _CatalogHomePage({required this.routeState});

  final _CatalogRouteState routeState;

  @override
  Widget build(BuildContext context) {
    final selected = routeState.selectedComponentId == null
        ? null
        : catalogComponentById[routeState.selectedComponentId!];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForState(selected)),
      ),
      body: _buildBody(selected),
    );
  }

  String _titleForState(CatalogPreview? selected) {
    if (routeState.compareConfig != null) {
      return 'Morphix DS Compare';
    }
    if (selected != null) {
      return 'Morphix DS - ${selected.title}';
    }
    return 'Morphix DS Catalog';
  }

  Widget _buildBody(CatalogPreview? selected) {
    if (routeState.compareConfig != null) {
      return _CatalogCompareView(config: routeState.compareConfig!);
    }
    if (selected == null) {
      return const _CatalogIndexView();
    }
    return _CatalogComponentView(component: selected);
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

class _CatalogCompareView extends StatelessWidget {
  const _CatalogCompareView({required this.config});

  final _CompareConfig config;

  @override
  Widget build(BuildContext context) {
    final baseUrl = _componentUrl(
      branch: config.baseBranch,
      componentId: config.componentId,
      version: config.baseVersion,
    );
    final headUrl = _componentUrl(
      branch: config.headBranch,
      componentId: config.componentId,
      version: config.headVersion,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1000;
        if (isNarrow) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ComparePanel(label: 'Base: ${config.baseBranch}', url: baseUrl),
              const SizedBox(height: 16),
              _ComparePanel(label: 'Head: ${config.headBranch}', url: headUrl),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _ComparePanel(
                  label: 'Base: ${config.baseBranch}',
                  url: baseUrl,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ComparePanel(
                  label: 'Head: ${config.headBranch}',
                  url: headUrl,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _componentUrl({
    required String branch,
    required String componentId,
    required String version,
  }) {
    return Uri(
      scheme: Uri.base.scheme,
      host: Uri.base.host,
      port: Uri.base.hasPort ? Uri.base.port : null,
      path: '/morphix/$branch/$componentId',
      queryParameters: {
        'v': version,
      },
    ).toString();
  }
}

class _ComparePanel extends StatelessWidget {
  const _ComparePanel({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(url),
            const SizedBox(height: 12),
            SizedBox(
              height: 620,
              child: CompareFrame(url: url),
            ),
          ],
        ),
      ),
    );
  }
}
