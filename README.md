# Morphix

Monorepo com:

- `morphix_design_system`: package de componentes DS.
- `morphix_ds_catalog`: ferramenta web de preview por branch/componente.

## Como funciona preview por branch

Workflow `DS Preview` builda o catalogo web e publica no GitHub Pages em pasta da branch.

Formato de URL:

- Branch: `https://<owner>.github.io/morphix/<branch-slug>/`
- Componente: `https://<owner>.github.io/morphix/<branch-slug>/<component-id>`

Para evitar cache do navegador entre builds da mesma branch, use o parâmetro
`v` gerado pelo workflow:

- Branch: `https://<owner>.github.io/morphix/<branch-slug>/?v=<sha-curto>`
- Componente: `https://<owner>.github.io/morphix/<branch-slug>/<component-id>?v=<sha-curto>`

Exemplo atual:

- `main/ds_button`

## Adicionar novo componente

1. Defina anotacao de preview no arquivo do componente em `morphix_ds_catalog/lib/src/components/`, por exemplo `morphix_ds_catalog/lib/src/components/ds_button_preview.dart`.

```dart
@CatalogPreview(
	id: 'ds_button',
	title: 'DS Button',
	description: 'Botao base do design system.',
)
final ComponentSpec dsButtonSpec = ComponentSpec(
	builder: (context) => DsButton(
		label: 'Continuar',
		onPressed: () {},
	),
)
```

2. Exporte no registry em `morphix_ds_catalog/lib/src/component_registry.dart`.
3. Adicione o id em `morphix_ds_catalog/tool/component_ids.txt`.

CI valida sincronismo entre `@CatalogPreview` e `component_ids.txt`.
