import 'dart:io';

final _previewRegex = RegExp(r'@dsPreview\(id:\s*([a-z0-9_]+)');
final _registryRegex = RegExp(r"id:\s*'([a-z0-9_]+)'");

void main() {
  final repoRoot = Directory.current.parent;
  final widgetsDir = Directory(
    '${repoRoot.path}/morphix_design_system/lib/src/widgets',
  );
  final registryFile = File(
    '${Directory.current.path}/lib/src/component_registry.dart',
  );

  if (!widgetsDir.existsSync()) {
    stderr.writeln(
      'Erro: pasta de widgets nao encontrada em ${widgetsDir.path}.',
    );
    exit(1);
  }

  if (!registryFile.existsSync()) {
    stderr.writeln(
      'Erro: arquivo de registry nao encontrado em ${registryFile.path}.',
    );
    exit(1);
  }

  final previewIds = <String>{};
  for (final entity in widgetsDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final content = entity.readAsStringSync();
    for (final match in _previewRegex.allMatches(content)) {
      previewIds.add(match.group(1)!);
    }
  }

  final registryContent = registryFile.readAsStringSync();
  final registryIds = {
    for (final match in _registryRegex.allMatches(registryContent))
      match.group(1)!,
  };

  final missingInRegistry = previewIds.difference(registryIds).toList()..sort();

  if (missingInRegistry.isNotEmpty) {
    stderr.writeln(
      'Erro: ids anotados sem registry: ${missingInRegistry.join(', ')}',
    );
    exit(1);
  }

  stdout.writeln('OK: registry cobre todos ids @dsPreview.');
}
