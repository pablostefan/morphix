# morphix_ds_catalog

Catalogo web do Morphix para preview de componentes, compare de PR e consulta
de referencias Figma.

## Rodar local

```bash
flutter pub get
flutter run -d chrome
```

## Rotas uteis

- Componente: `/?component=<component-id>`
- Compare: `/?compare=1&component=<id>&base=<branch>&head=<branch>`
- Figma: `/?figma=<figma-id>`

ID Figma inicial disponivel:

- `figma_picto_portfolio`

Fonte canonica de paginas Figma:

- `lib/src/figma_pages_registry.dart`
