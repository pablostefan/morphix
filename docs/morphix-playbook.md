# Morphix Playbook (Monorepo + GitHub Pages + PR Compare)

Este documento descreve, em detalhes, como o Morphix funciona hoje e como reproduzir o mesmo fluxo em outro monorepo.

## 1. Objetivo

O Morphix entrega um fluxo de Design System orientado a PR:

1. Um package de componentes (`morphix_design_system`).
2. Um catalogo web para preview (`morphix_ds_catalog`).
3. Publicacao automatica no GitHub Pages por branch.
4. Comentario automatico em PR com links de compare (base x head) por componente alterado.

## 2. Estrutura atual do repositorio

```text
morphix/
  .github/
    workflows/
      ds-preview.yml
  docs/
    pr-compare.md
    morphix-playbook.md
  morphix_design_system/
    lib/
      morphix_design_system.dart
      src/widgets/
        ds_button.dart
        ds_badge.dart
  morphix_ds_catalog/
    lib/
      main.dart
      src/
        compare_frame.dart
        compare_frame_web.dart
        compare_frame_stub.dart
        component_registry.dart
        components/
          ds_button_preview.dart
          ds_badge_preview.dart
        engine/
          preview_engine.dart
    tool/
      component_ids.txt
      validate_registry.dart
  README.md
```

## 3. Arquitetura funcional

### 3.1 Design System package

Responsabilidade:

- Definir widgets reutilizaveis do DS.
- Exportar a API publica em `morphix_design_system/lib/morphix_design_system.dart`.

Exemplo:

- `DsButton` em `morphix_design_system/lib/src/widgets/ds_button.dart`
- `DsBadge` em `morphix_design_system/lib/src/widgets/ds_badge.dart`

### 3.2 Catalog web

Responsabilidade:

- Renderizar previews de componentes.
- Resolver rota por query/path.
- Renderizar modo compare lado a lado com iframe (web).

Ponto de entrada:

- `morphix_ds_catalog/lib/main.dart`

Modelo de preview:

- `CatalogPreview` em `morphix_ds_catalog/lib/src/engine/preview_engine.dart`

Registro canonico:

- `morphix_ds_catalog/lib/src/component_registry.dart`

### 3.3 Compare runtime (web)

No web, o compare usa `HtmlElementView` + `IFrameElement`:

- `morphix_ds_catalog/lib/src/compare_frame_web.dart`

No stub (nao web), renderiza fallback:

- `morphix_ds_catalog/lib/src/compare_frame_stub.dart`

## 4. Contrato de URLs

### 4.1 Preview de branch

- Branch home:
  `https://<owner>.github.io/<repo>/<branch-slug>/?v=<sha-curto>`
- Componente:
  `https://<owner>.github.io/<repo>/<branch-slug>/<component-id>?v=<sha-curto>`

### 4.2 Compare de PR

- Compare page:
  `https://<owner>.github.io/<repo>/<head-slug>/?compare=1&component=<id>&base=<base-slug>&head=<head-slug>&vbase=<sha-base-12>&vhead=<sha-head-12>`

- Base direta:
  `https://<owner>.github.io/<repo>/<base-slug>/<component-id>?v=<sha-base-12>`

- Head direta:
  `https://<owner>.github.io/<repo>/<head-slug>/<component-id>?v=<sha-head-12>`

## 5. Workflow DS Preview (CI/CD)

Arquivo:

- `.github/workflows/ds-preview.yml`

Triggers:

- `push`
- `pull_request` (`opened`, `synchronize`, `reopened`)

Permissoes:

- `contents: write`
- `pull-requests: write`

### 5.1 Job publish (push)

Pipeline:

1. Resolve `BRANCH_SLUG` e `PREVIEW_VERSION` (`GITHUB_SHA::12`).
2. Setup Flutter.
3. `flutter pub get` no catalogo.
4. `dart run tool/validate_registry.dart`.
5. `flutter test`.
6. `flutter build web --release --pwa-strategy=none --base-href "/<repo>/<branch-slug>/"`.
7. Patch de cache-busting em assets (`main.dart.js?v=<sha>` em `flutter_bootstrap.js` e `index.html`).
8. Gera redirects por componente em `build/web/<component-id>/index.html`.
9. Publica em `gh-pages` com `destination_dir=<branch-slug>`.
10. Escreve links no `GITHUB_STEP_SUMMARY`.

### 5.2 Job pr-compare-links (pull_request)

Pipeline:

1. Resolve contexto da PR (`BASE_REF`, `HEAD_REF`, `BASE_SHA`, `HEAD_SHA`).
2. Slugifica branches (`BASE_SLUG`, `HEAD_SLUG`).
3. Detecta componentes alterados pelo diff:
   - `morphix_ds_catalog/lib/src/components/*_preview.dart`
   - `morphix_design_system/lib/src/widgets/*.dart`
4. Fallback para todos os IDs de `morphix_ds_catalog/tool/component_ids.txt`.
5. Gera comentario com:
   - Link compare
   - Link base
   - Link head
6. Cria ou atualiza comentario unico usando marcador:
   `<!-- morphix-pr-compare -->`

## 6. Catalogo de componentes (governanca)

Fonte canonica de IDs:

- `morphix_ds_catalog/tool/component_ids.txt`

Validador:

- `morphix_ds_catalog/tool/validate_registry.dart`

Regra:

- IDs em previews e IDs em `component_ids.txt` devem estar sincronizados.

Falhas comuns:

- Componente criado sem entrar no registry.
- ID novo sem atualizar `component_ids.txt`.

## 7. Cache e consistencia visual

### 7.1 Medidas ativas no Morphix

1. Parametro `v=<sha-curto>` nas URLs.
2. `--pwa-strategy=none` no build Flutter web.
3. Patch de `main.dart.js?v=<sha>` no bootstrap/index.

### 7.2 Sintoma comum

"Base e Head estao iguais"

Checklist:

1. Verifique se `vbase` e `vhead` diferem.
2. Abra Base e Head diretamente (fora do compare).
3. Veja se o `push` job da branch concluiu com sucesso.
4. Valide que o branch folder existe em `gh-pages`.

## 8. GitHub Pages: pontos criticos

Este e o ponto mais sensivel para reproducao em outro repo.

### 8.1 Configuracao obrigatoria

No repositorio alvo, configure Pages para:

- Branch: `gh-pages`
- Path: `/`

Sem isso, os links publicados podem retornar `404` mesmo com workflow verde.

### 8.2 Branch `gh-pages` e retençao de pastas

Cada branch de trabalho publica em um subdiretorio de `gh-pages`:

- `gh-pages/<branch-slug>/...`

Se o deploy sobrescrever toda a branch `gh-pages`, voce perde previews antigos (ex.: `main/`).

Recomendacao:

- usar `keep_files: true` no passo de deploy.

### 8.3 Erro operacional que quebra tudo

Apagar `gh-pages` derruba o site (Pages pode voltar para estado 404).

Recuperacao:

1. Recriar/publicar `gh-pages` via workflow.
2. Reconfigurar Pages para `gh-pages` + `/`.
3. Republicar `main` e branches necessarias.

### 8.4 Teste local de artefato e base-href

Se voce servir `build/web` localmente sem respeitar `base-href` de producao, pode ver 404 de assets como:

- `/morphix/<branch>/flutter_bootstrap.js`

Isto nao implica erro de build necessariamente; pode ser mismatch de path local.

## 9. Como reproduzir em outro monorepo (passo a passo)

### 9.1 Pre-requisitos

1. Repo GitHub com permissao de Actions.
2. Flutter instalado para build local.
3. Estrutura minima:
   - package DS
   - app catalogo web
4. Pages habilitavel (repo publico ou plano que suporte Pages privado).

### 9.2 Estrutura minima sugerida

```text
<repo>/
  .github/workflows/ds-preview.yml
  <ds_package>/
  <catalog_app>/
    tool/component_ids.txt
    tool/validate_registry.dart
```

### 9.3 Implementar catalogo

1. Criar `CatalogPreview` (id/title/description/builder).
2. Criar registry canonico com lista/map.
3. Suportar rota por:
   - `?component=<id>`
   - path `/<branch>/<component-id>`
4. Suportar compare via query (`compare=1`, `base`, `head`, `vbase`, `vhead`).

### 9.4 Implementar workflow

Copiar a logica do `ds-preview.yml` com ajustes de:

- nome do repositorio no `base-href`
- caminho do app catalogo
- org/user no dominio GitHub Pages

### 9.5 Ativar Pages

Opcao CLI:

```bash
gh api -X POST repos/<owner>/<repo>/pages \
  -f 'source[branch]=gh-pages' \
  -f 'source[path]=/'
```

Se ja existir configuracao, use `PUT` com o mesmo payload.

### 9.6 Fluxo de validacao

1. Push em branch de feature.
2. Verifique URL da branch no summary do workflow.
3. Abra PR para `main`.
4. Verifique comentario automatico com compare.
5. Compare Base x Head do componente alterado.

## 10. Matriz de troubleshooting

### 10.1 Workflow verde, links 404

Causa provavel:

- Pages desconfigurado ou branch `gh-pages` ausente.

Acoes:

1. Validar `gh api repos/<owner>/<repo>/pages`.
2. Validar existencia de `gh-pages`.
3. Confirmar diretoro `<branch-slug>/` publicado.

### 10.2 Compare sem diferenca visual

Causa provavel:

- cache do browser ou URL com `v` antigo.

Acoes:

1. Abrir links Base/Head diretos com `v` atual.
2. Checar comentario mais recente da PR.
3. Rodar hard refresh / aba anonima.

### 10.3 Comentario de PR nao aparece

Causa provavel:

- job `pr-compare-links` nao executou ou sem permissao.

Acoes:

1. Verificar job da run de `pull_request`.
2. Validar `pull-requests: write`.
3. Validar marcador unico no comentario.

### 10.4 Branch preview sumiu apos novo deploy

Causa provavel:

- deploy em `gh-pages` sem preservar arquivos.

Acao:

- habilitar `keep_files: true` no action de deploy.

## 11. Comandos uteis de operacao

Checar runs:

```bash
gh run list --workflow "DS Preview"
```

Checar comentario de PR:

```bash
gh pr view <numero> --json comments
```

Checar pastas em `gh-pages`:

```bash
git fetch origin gh-pages:refs/remotes/origin/gh-pages
git ls-tree --name-only origin/gh-pages
```

Checar Pages:

```bash
gh api repos/<owner>/<repo>/pages
```

## 12. Checklist de migracao para outro repo

1. [ ] Criar package DS e catalogo web.
2. [ ] Implementar registry de previews + `component_ids.txt`.
3. [ ] Implementar `validate_registry.dart`.
4. [ ] Adicionar workflow de publish/compare.
5. [ ] Configurar Pages para `gh-pages` + `/`.
6. [ ] Garantir `keep_files: true` no deploy.
7. [ ] Testar PR com mudanca minima de cor em um botao.
8. [ ] Confirmar comentario automatico e links Base/Head/Compare.
9. [ ] Documentar comandos de operacao para o time.

## 13. Decisoes atuais do Morphix

1. Compare e feito por iframe de URLs publicados.
2. Mapeamento de componente alterado e por padrao de path.
3. Fallback para todos os componentes quando mapeamento nao encontra IDs.
4. Cache-busting e feito por versao SHA em URL e assets.
5. Fonte de verdade de IDs e `component_ids.txt`.

## 14. Recomendacoes futuras

1. Adicionar smoke test de URLs publicadas no fim do `publish`.
2. Adicionar validacao automatica para detectar ausencia de `main/` em `gh-pages`.
3. Publicar changelog de componentes no comentario da PR.
4. Criar script de bootstrap para reproduzir o setup em novos monorepos.
