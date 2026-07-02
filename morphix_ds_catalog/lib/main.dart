import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final theme = Theme.of(context);
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 1100;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _CompareHeader(config: config),
              const SizedBox(height: 12),
              const _CompareTips(),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _ComparePanel(
                  label: 'Base',
                  branch: config.baseBranch,
                  version: config.baseVersion,
                  url: baseUrl,
                  accentColor: Colors.teal,
                  frameHeight: 520,
                ),
                const SizedBox(height: 16),
                _ComparePanel(
                  label: 'Head',
                  branch: config.headBranch,
                  version: config.headVersion,
                  url: headUrl,
                  accentColor: Colors.deepOrange,
                  frameHeight: 520,
                ),
              ] else
                SizedBox(
                  height: 760,
                  child: Row(
                    children: [
                      Expanded(
                        child: _ComparePanel(
                          label: 'Base',
                          branch: config.baseBranch,
                          version: config.baseVersion,
                          url: baseUrl,
                          accentColor: Colors.teal,
                          frameHeight: 640,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ComparePanel(
                          label: 'Head',
                          branch: config.headBranch,
                          version: config.headVersion,
                          url: headUrl,
                          accentColor: Colors.deepOrange,
                          frameHeight: 640,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
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
        'cmp': '$branch-$version',
      },
    ).toString();
  }
}

class _CompareHeader extends StatelessWidget {
  const _CompareHeader({required this.config});

  final _CompareConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparando componente ${config.componentId}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Base ${config.baseBranch} (${config.baseVersion}) x Head ${config.headBranch} (${config.headVersion})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  label: 'Componente',
                  value: config.componentId,
                  color: Colors.blueGrey,
                ),
                _MetaChip(
                  label: 'Base',
                  value: config.baseBranch,
                  color: Colors.teal,
                ),
                _MetaChip(
                  label: 'Head',
                  value: config.headBranch,
                  color: Colors.deepOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _CompareTips extends StatelessWidget {
  const _CompareTips();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dica: use os links Base e Head para validar individualmente e confirme a diferenca visual no compare lado a lado.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparePanel extends StatelessWidget {
  const _ComparePanel({
    required this.label,
    required this.branch,
    required this.version,
    required this.url,
    required this.accentColor,
    required this.frameHeight,
  });

  final String label;
  final String branch;
  final String version;
  final String url;
  final Color accentColor;
  final double frameHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$label: $branch',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'versao: $version',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    url,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Copiar URL',
                  child: IconButton(
                    onPressed: () => _copyUrl(context),
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: frameHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CompareFrame(url: url),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyUrl(BuildContext context) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copiada')),
    );
  }
}
