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
- `owner=<owner-do-repo>`
- `repo=<nome-do-repo>`
- `pr=<numero-da-pr>`

Exemplo:

- `https://pablostefan.github.io/morphix/feat-minha-branch/?compare=1&component=ds_button&base=main&head=feat-minha-branch&vbase=abc123def456&vhead=789abc123def&owner=pablostefan&repo=morphix&pr=10`

## Review actions na pagina de compare

A tela de compare agora suporta tres acoes de review:

1. `Aprovar` (APPROVE)
2. `Solicitar alteracoes` (REQUEST_CHANGES)
3. `Desaprovar revisao` (dismiss de uma review existente)

Importante:

- O compare continua exibindo o comentario automatico da PR como antes.
- As acoes de review dependem de backend seguro; a pagina web nao deve chamar token GitHub diretamente.

## Contrato de backend para review

A UI faz `POST` para:

- `${MORPHIX_REVIEW_API_BASE}/github/reviews`

Payload enviado:

- `owner`
- `repo`
- `pull_number`
- `event` (`APPROVE`, `REQUEST_CHANGES`, `DISMISS`)
- `body` (obrigatorio para `REQUEST_CHANGES` e `DISMISS`)
- `review_id` (obrigatorio para `DISMISS`)
- `component_id`
- `base_branch`
- `head_branch`

Headers:

- `Content-Type: application/json`
- `Accept: application/json`
- `X-Morphix-Review-Key` (opcional, se `MORPHIX_REVIEW_API_KEY` for definido no build)

## Build com review actions habilitado

Exemplo local:

```bash
cd morphix_ds_catalog
flutter build web \
  --release \
  --dart-define=MORPHIX_REVIEW_API_BASE=https://seu-backend.example.com/
```

Opcionalmente, para chave adicional de gateway:

```bash
flutter build web \
  --release \
  --dart-define=MORPHIX_REVIEW_API_BASE=https://seu-backend.example.com/ \
  --dart-define=MORPHIX_REVIEW_API_KEY=chave-de-gateway-nao-secreta
```

## Regras de validacao da UI

1. Sem `owner`, `repo` e `pr` na URL, as acoes ficam sem contexto valido.
2. `REQUEST_CHANGES` exige comentario.
3. `DISMISS` exige comentario e `review_id` valido.
4. Sem `MORPHIX_REVIEW_API_BASE`, a UI exibe erro de backend nao configurado.

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
  - Confirmar no run de `push` da branch se o passo `Patch web assets cache-busting` executou com sucesso.
  - Forcar refresh do navegador.
- Sem comentario na PR:
  - Verificar permissao `pull-requests: write` no workflow.
  - Verificar se o job `pr-compare-links` executou sem erro.

## Nota de cache

No job de `push`, o pipeline publica o web build com cache-busting de asset:

- `main.dart.js?v=<sha-curto>`

Isso reduz chance de o navegador reaproveitar bundle antigo da mesma branch durante comparacoes sucessivas em PR.
