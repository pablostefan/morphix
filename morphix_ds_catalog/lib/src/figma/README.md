# Integração Figma - Estrutura Modular

## 📁 Estrutura de Arquivos

```
lib/src/figma/
├── figma_config.dart                      # Configuração (token, URLs, timeouts)
├── figma_models.dart                      # Types para respostas da API
├── figma_service.dart                     # Cliente HTTP para Figma API
├── figma_registry.dart                    # Registro de arquivos/páginas Figma
├── figma_page_view.dart                   # Widget para renderizar página
├── figma_external_link_opener.dart        # Export condicional (web/non-web)
├── figma_external_link_opener_web.dart    # Implementação web (dart:html)
├── figma_external_link_opener_stub.dart   # Stub para plataformas não-web
└── index.dart                             # Barrel export público
```

## 🔧 Setup

### 1. Token Figma

Gere seu token em: https://www.figma.com/developers/api#access-tokens

Defina como variável de ambiente:
```bash
export FIGMA_API_TOKEN="figd_seu_token_aqui"
```

Ao compilar:
```bash
flutter build web --release --dart-define=FIGMA_API_TOKEN="figd_..."
```

### 2. Registrar Arquivo Figma

Em [figma_registry.dart](figma_registry.dart), adicione novo arquivo à lista:

```dart
const List<RegisteredFigmaFile> registeredFigmaFiles = [
  RegisteredFigmaFile(
    id: 'figma_meu_projeto',           // ID único para query param
    fileId: 'abc123...xyz',             // Extrair de URL do design
    title: 'Meu Projeto - Design File',
    pageNames: ['Page1', 'Page2'],      // Páginas para buscar
    description: 'Descrição breve',
    designUrl: 'https://figma.com/design/...',  // URL completa
  ),
];
```

## 🎯 Como Funciona

### Fluxo de Dados

```
1. URL com ?figma=figma_meu_projeto
   ↓
2. main.dart identifica e busca RegisteredFigmaFile
   ↓
3. FigmaPageView({fileId: "abc123...xyz"})
   ↓
4. _loadFigmaData():
   - Chama FigmaService.getFile(fileId)
   - API retorna metadados (páginas, nomes)
   - Chama FigmaService.getPageScreenshot(fileId, pageId)
   - API gera URL da imagem PNG
   ↓
5. Exibe screenshot + botões (Copiar URL, Abrir no Figma)
```

### Componentes Principais

**FigmaService** — Cliente HTTP
- `getFile()`: metadados de arquivo
- `getPageScreenshot()`: URL de screenshot
- `getNodes()`: metadados de nós específicos

**FigmaPageView** — Widget
- Carrega dados automaticamente
- Exibe screenshot com loading + error handling
- Botões para ações (copiar, abrir)

**FigmaExternalLinkOpener** — Abstração plataforma
- Web: usa `dart:html` + `window.open()`
- Não-web: fallback a SnackBar com URL

## 🚀 Rotas

```
?figma=figma_picto_portfolio    → Exibe Picto Portfolio
?figma=figma_meu_projeto        → Exibe Meu Projeto
```

Ou via navegação in-app (index view → clica em "Referencias Figma").

## ⚙️ Configuração de Token

**Opção 1: Variável de Ambiente** (Recomendado)
```bash
# No .bashrc / .zshrc
export FIGMA_API_TOKEN="figd_xxxxx"

# Build reconhece automaticamente
flutter build web --release
```

**Opção 2: Dart Define** (Para CI/CD)
```bash
flutter build web --release \
  --dart-define=FIGMA_API_TOKEN="figd_xxxxx"
```

**Opção 3: Const String** (Desenvolvimento local, NÃO PARA GIT)
```dart
// figma_config.dart
const String figmaApiToken = 'figd_xxxxx';  // ❌ NÃO COMMITAR
```

## 📊 Monitoramento

### Logs

Todos os erros vão para console com prefixo `[Figma]`:

```
[Figma] Token não configurado. Defina FIGMA_API_TOKEN.
[Figma] Token inválido ou expirado.
[Figma] Arquivo não encontrado.
[Figma] Erro ao obter screenshot: 401
```

### Handling de Erros

1. **Token inválido**: Mostra card de erro + mensagem clara
2. **Arquivo não encontrado**: Card de erro
3. **Screenshot falha**: Mostra botão "Abrir no Figma" como fallback
4. **Non-web environment**: Fallback a SnackBar com URL

## 🧪 Testes

Todos os testes passam:
```bash
flutter test
# ✅ All tests passed!
```

O módulo é testável porque:
- Conditional imports isolam `dart:html`
- FigmaService é static (fácil mockar)
- Widgets testáveis com padrão padrão do Flutter

## 📝 Próximos Passos

1. ✅ Token configurado
2. ✅ Arquivo registrado em `registeredFigmaFiles`
3. ✅ Build web
4. 📍 Deploy e testar em production

## 🔐 Segurança

- **Token jamais versionado** em git
- Use CI/CD secrets para fornecer token em build
- Em dev local: use `.bashrc` / `.zshrc` ou `.env` (gitignored)

## 📚 Referências

- [Figma REST API Docs](https://www.figma.com/developers/api)
- [Access Tokens](https://www.figma.com/developers/api#access-tokens)
- [Images Endpoint](https://www.figma.com/developers/api#images)
