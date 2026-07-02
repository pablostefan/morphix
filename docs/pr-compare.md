# PR Compare no Morphix

Este documento descreve como validar visualmente componentes alterados em uma Pull Request.

## O que acontece automaticamente

Quando uma PR e aberta ou atualizada, o workflow `DS Preview`:

1. Detecta os componentes alterados no diff da PR.
2. Gera links de compare lado a lado (base vs head).
3. Cria ou atualiza um comentario da PR com esses links.

Marcador do comentario automatico:

- `<!-- morphix-pr-compare -->`

## Formato dos links

O link principal de compare usa:

- `compare=1`
- `component=<component-id>`
- `base=<branch-base-slug>`
- `head=<branch-head-slug>`
- `vbase=<sha-curto-base>`
- `vhead=<sha-curto-head>`

Exemplo:

- `https://pablostefan.github.io/morphix/feat-minha-branch/?compare=1&component=ds_button&base=main&head=feat-minha-branch&vbase=abc123def456&vhead=789abc123def`

## Mapeamento de componente alterado

A deteccao considera:

- `morphix_ds_catalog/lib/src/components/*_preview.dart`
- `morphix_design_system/lib/src/widgets/*.dart`

Fallback:

- Se nenhum componente for detectado pelo diff, o workflow usa todos os IDs de `morphix_ds_catalog/tool/component_ids.txt`.

## Checklist de validacao

1. Abrir PR para `main`.
2. Aguardar o workflow `DS Preview` finalizar.
3. Abrir comentario automatico com titulo `Morphix Component Compare`.
4. Clicar no link `Compare` do componente alterado.
5. Confirmar render lado a lado: base a esquerda e head a direita.
6. Confirmar que a diferenca visual esperada esta visivel.

## Troubleshooting rapido

- Link abre sem diferenca visual:
  - Verificar se `vbase` e `vhead` estao diferentes.
  - Forcar refresh do navegador.
- Sem comentario na PR:
  - Verificar permissao `pull-requests: write` no workflow.
  - Verificar se o job `pr-compare-links` executou sem erro.
