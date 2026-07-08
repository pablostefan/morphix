# Estrutura Figma - Resumo Executivo

## ✅ O que foi entregue

Integração completa da **Figma REST API** no Morphix DS Catalog, com estrutura modular, organizada e testada.

## 🎯 Problema resolvido

**Antes**: Tentativa de embed webview privado sem autenticação (não funciona)  
**Depois**: API real com token → renderiza screenshots reais das páginas Figma privadas

## 📊 Estrutura criada

```
lib/src/figma/
├── 🔐 figma_config.dart          (Token + configuração)
├── 📦 figma_models.dart           (Types para API)
├── 🌐 figma_service.dart          (Cliente HTTP)
├── 📋 figma_registry.dart         (Catálogo de arquivos)
├── 🎨 figma_page_view.dart        (Widget de renderização)
├── 🔗 figma_external_link_opener* (Abstração plataforma)
└── 📄 README.md                   (Documentação completa)
```

## 🚀 Como usar

### Setup (1 minuto)

```bash
# 1. Pegar token em https://www.figma.com/developers/api#access-tokens
# 2. Setar variável de ambiente
export FIGMA_API_TOKEN="figd_seu_token_aqui"

# 3. Build
flutter build web --release
```

### Acessar página Figma

```
http://localhost:8081/?figma=figma_picto_portfolio
```

### Adicionar novo arquivo Figma

Em `lib/src/figma/figma_registry.dart`:

```dart
RegisteredFigmaFile(
  id: 'figma_meu_design',
  fileId: 'abc123xyz',  // Extrair da URL
  title: 'Meu Design File',
  description: 'Descrição',
  designUrl: 'https://figma.com/design/...',
)
```

## 💡 Como funciona

```
1. URL: ?figma=figma_picto_portfolio
2. main.dart → busca em registry
3. FigmaPageView → carrega fileId via API
4. FigmaService → requisição HTTP com token
5. Figma API → retorna URL de screenshot
6. Widget → exibe imagem + botões
```

## ✨ Features

✅ Screenshots dinâmicos (resolvidos via API)  
✅ Botão "Abrir no Figma" (com fallback)  
✅ Copiar URL para clipboard  
✅ Loading + error handling  
✅ Suporta múltiplas páginas (configurável)  
✅ Token seguro (via env var)  
✅ Testes passando  
✅ Build production pronto  

## 🔒 Segurança

- Token **NUNCA** em git
- Usa `String.fromEnvironment()` → seguro
- CI/CD injeta token via secrets
- Dev local: `.bashrc` ou variável de session

## 📈 Comparação: Antes vs Depois

| Aspecto | Antes | Depois |
|---------|-------|--------|
| **Tecnologia** | Iframe embed (webview) | REST API + Screenshots |
| **Autenticação** | ❌ Sem login | ✅ Token configurável |
| **Dev Mode** | ❌ Não funciona | ✅ Funciona (acesso privado) |
| **Organização** | ❌ Espalhado em main.dart | ✅ Módulo dedicado |
| **Manutenção** | ❌ Alto acoplamento | ✅ Baixo acoplamento |
| **Extensibilidade** | ❌ Difícil adicionar arquivos | ✅ Fácil (registry pattern) |
| **Testabilidade** | ❌ dart:html em testes | ✅ Conditional imports |
| **Build** | ❌ Warnings | ✅ Clean build |

## 🎓 Padrões usados

- **Registry Pattern**: Lista centralizada de recursos (como component_registry)
- **Conditional Imports**: Suporte a web e non-web sem conflitos
- **Barrel Exports**: `index.dart` simplifica imports
- **Service Pattern**: FigmaService encapsula HTTP
- **Error Handling**: Logging + UI gracioso

## 📱 Rotas geradas

```
?figma=figma_picto_portfolio     (Picto Portfolio - Community Template)

# Adicione mais em registeredFigmaFiles:
?figma=figma_seu_arquivo         (Seu Arquivo)
?figma=figma_outro_projeto       (Outro Projeto)
```

## ⚙️ Próximo: Sua ação

1. **Token**: `export FIGMA_API_TOKEN="figd_xxx"`
2. **Test**: `?figma=figma_picto_portfolio`
3. **Adicione seus**: Edite `figma_registry.dart`
4. **Deploy**: CI/CD injeta token via secrets

## 🐛 Se não funcionar

| Erro | Solução |
|------|---------|
| "Token não configurado" | Defina `FIGMA_API_TOKEN` antes de build |
| "Token inválido" | Verifique token em https://figma.com/account |
| "Arquivo não encontrado" | Confirme fileId (extrair da URL) |
| Screenshot em branco | Arquivo privado → token deve ser válido |

## 📚 Documentação completa

Ver [lib/src/figma/README.md](lib/src/figma/README.md)
