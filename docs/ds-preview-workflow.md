# DS Preview Workflow

Este documento descreve como o workflow `DS Preview` decide se deve rodar.

## Objetivo

Evitar builds e comentários de PR quando a mudança não toca áreas relevantes do
design system.

## Como funciona

O fluxo tem duas camadas:

1. Gatilho mínimo no GitHub Actions.
2. Filtro configurável lido de `.github/ds-preview-paths.txt`.

### 1. Gatilho mínimo

O arquivo `.github/workflows/ds-preview.yml` ainda usa `paths` nativo do GitHub
Actions para acordar o workflow apenas quando algo potencialmente relevante muda.

Isso cobre:

- `.github/workflows/ds-preview.yml`
- `.github/ds-preview-paths.txt`
- `morphix_design_system/**`
- `morphix_ds_catalog/**`

### 2. Filtro configurável

Depois que o workflow inicia, o job `detect-relevant-changes`:

1. calcula os arquivos alterados no `push` ou `pull_request`;
2. lê os globs de `.github/ds-preview-paths.txt`;
3. decide se `publish` e `pr-compare-links` devem rodar.

Se nenhum arquivo alterado bater com um glob configurado, os jobs pesados são
pulados.

## Arquivo de configuração

Arquivo: `.github/ds-preview-paths.txt`

Regras:

- um glob por linha;
- linhas em branco são ignoradas;
- linhas começando com `#` são comentários.

Exemplo:

```text
# package DS
morphix_design_system/**

# app de preview
morphix_ds_catalog/lib/**
morphix_ds_catalog/test/**
morphix_ds_catalog/tool/**
morphix_ds_catalog/pubspec.yaml
morphix_ds_catalog/pubspec.lock
```

## Como alterar os paths

1. Edite `.github/ds-preview-paths.txt`.
2. Faça push.
3. O próprio workflow será acionado porque esse arquivo faz parte do gatilho mínimo.

## Limitação do GitHub Actions

O GitHub Actions não permite carregar `on.push.paths` ou `on.pull_request.paths`
de um arquivo externo do repositório.

Por isso a configuração é híbrida:

- `paths` mínimo no YAML;
- guarda dinâmica no job `detect-relevant-changes`.

## O que validar

1. Mudança fora dos globs: workflow inicia e encerra sem `publish` nem `pr-compare-links`.
2. Mudança dentro dos globs: workflow segue normalmente.
3. Mudança no arquivo de config: workflow também inicia.