import 'dart:io';

final _catalogIdRegex = RegExp(r"id:\s*'([a-z0-9_]+)'");

void main() {
  final componentsDir = Directory(
    '${Directory.current.path}/lib/src/components',
  );
  final componentIdsFile = File(
    '${Directory.current.path}/tool/component_ids.txt',
  );

  if (!componentsDir.existsSync()) {
    stderr.writeln(
      'Erro: pasta components nao encontrada em ${componentsDir.path}.',
    );
    exit(1);
  }

  if (!componentIdsFile.existsSync()) {
    stderr.writeln(
      'Erro: arquivo de ids nao encontrado em ${componentIdsFile.path}.',
    );
    exit(1);
  }

  final declaredIds = <String>{};
  for (final entity in componentsDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final content = entity.readAsStringSync();
    for (final match in _catalogIdRegex.allMatches(content)) {
      declaredIds.add(match.group(1)!);
    }
  }

  final listedIds = {
    for (final line in componentIdsFile.readAsLinesSync())
      if (line.trim().isNotEmpty) line.trim(),
  };

  final missingInCode = listedIds.difference(declaredIds).toList()..sort();
  final missingInList = declaredIds.difference(listedIds).toList()..sort();

  if (missingInCode.isNotEmpty) {
    stderr.writeln(
      'Erro: ids em component_ids.txt sem CatalogPreview declarado: ${missingInCode.join(', ')}',
    );
    exit(1);
  }

  if (missingInList.isNotEmpty) {
    stderr.writeln(
      'Erro: ids de CatalogPreview ausentes em component_ids.txt: ${missingInList.join(', ')}',
    );
    exit(1);
  }

  stdout.writeln('OK: CatalogPreview e component_ids.txt sincronizados.');
}
