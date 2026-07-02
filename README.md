# Morphix

Monorepo com:

- `morphix_design_system`: package de componentes DS.
- `morphix_ds_catalog`: ferramenta web de preview por branch/componente.

## Como funciona preview por branch

Workflow `DS Preview` builda o catalogo web e publica no GitHub Pages em pasta da branch.

Formato de URL:

- Branch: `https://<owner>.github.io/morphix/<branch-slug>/`
- Componente: `https://<owner>.github.io/morphix/<branch-slug>/<component-id>`
- Compare (main vs branch):
	`https://<owner>.github.io/morphix/<head-branch-slug>/?compare=1&component=<component-id>&base=<base-branch-slug>&head=<head-branch-slug>&vbase=<sha-curto-base>&vhead=<sha-curto-head>`

Para evitar cache do navegador entre builds da mesma branch, use o parâmetro
`v` gerado pelo workflow:

- Branch: `https://<owner>.github.io/morphix/<branch-slug>/?v=<sha-curto>`
- Componente: `https://<owner>.github.io/morphix/<branch-slug>/<component-id>?v=<sha-curto>`

O pipeline também aplica cache-busting no bundle web publicado, versionando
`main.dart.js` com o SHA curto do build.

Exemplo atual:

- `main/ds_button`

## Adicionar novo componente

1. Crie um arquivo preview em `morphix_ds_catalog/lib/src/components/`, por exemplo `morphix_ds_catalog/lib/src/components/ds_button_preview.dart`.

```dart
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
```

2. Registre no registry em `morphix_ds_catalog/lib/src/component_registry.dart`:

```dart
final catalogComponents = <CatalogPreview>[
	buildDsButtonPreview(),
];
```

3. Adicione o id em `morphix_ds_catalog/tool/component_ids.txt`.

CI valida sincronismo entre previews registrados e `component_ids.txt`.

## Compare em PR

No evento de Pull Request, o workflow detecta componentes alterados e publica
um comentário automático com links de compare lado a lado (base vs head).

## Quando o workflow roda

O workflow `DS Preview` foi limitado para mudanças relevantes do design system.

Os globs configuráveis ficam em `.github/ds-preview-paths.txt`.

Uso esperado:

- adicione um glob por linha;
- linhas em branco são ignoradas;
- linhas começando com `#` são comentários.

Exemplo:

```text
morphix_design_system/**
morphix_ds_catalog/lib/**
```

Limitação importante:

- o GitHub Actions não consegue ler `on.paths` diretamente desse arquivo;
- por isso o workflow usa um gatilho mínimo no YAML e um job inicial de guarda
	que lê `.github/ds-preview-paths.txt` antes de decidir se roda `publish` e
	`pr-compare-links`.

Guia de operação:

- `docs/pr-compare.md`
- `docs/ds-preview-workflow.md`

