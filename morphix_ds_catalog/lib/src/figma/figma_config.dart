// ignore: dangling_library_doc_comments
/// Configuração de acesso à Figma API.
///
/// SETUP:
/// 1. Obtenha seu token em https://www.figma.com/developers/api#access-tokens
/// 2. Defina a variável de ambiente: export FIGMA_API_TOKEN="seu_token_aqui"
/// 3. Ou declare aqui (NOT RECOMMENDED para repos públicos):
///    const String _figmaToken = 'figd_...';
///
/// Em produção, use const String.fromEnvironment() ou similar.

const String figmaApiToken = String.fromEnvironment(
  'FIGMA_API_TOKEN',
  defaultValue: '',
);

/// Host da Figma API.
const String figmaApiHost = 'api.figma.com';

/// Versão da API.
const String figmaApiVersion = 'v1';

/// Timeout padrão para requisições.
const Duration figmaApiTimeout = Duration(seconds: 30);

/// Valida se o token foi configurado.
bool isFigmaTokenConfigured() => figmaApiToken.isNotEmpty;
