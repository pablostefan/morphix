# Morphix

Monorepo com:

- `morphix_design_system`: package de componentes DS.
- `morphix_ds_catalog`: ferramenta web de preview por branch/componente.

## Como funciona preview por branch

Workflow `DS Preview` builda o catalogo web e publica no GitHub Pages em pasta da branch.

Formato de URL:

- Branch: `https://<owner>.github.io/morphix/<branch-slug>/`
- Componente: `https://<owner>.github.io/morphix/<branch-slug>/<component-id>`

Exemplo atual:

- `main/ds_button`

## Adicionar novo componente

1. No componente do DS, adicione doc comment com id:

```dart
/// @dsPreview(id: ds_button, title: DS Button)
```

2. Registre no catalogo em `morphix_ds_catalog/lib/src/component_registry.dart`.
3. Adicione o id em `morphix_ds_catalog/tool/component_ids.txt`.

CI valida que todo id anotado em `@dsPreview` existe no registry.
