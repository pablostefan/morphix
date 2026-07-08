// ignore: dangling_library_doc_comments
/// Registro de arquivos e páginas Figma disponíveis no catálogo.

/// Metadados de um arquivo Figma registrado.
class RegisteredFigmaFile {
  const RegisteredFigmaFile({
    required this.id,
    required this.fileId,
    required this.title,
    required this.pageNames,
    this.description,
    this.designUrl,
  });

  /// Identificador único na app (ex: 'figma_picto_portfolio').
  final String id;

  /// ID do arquivo Figma (obtido da URL, antes da barra).
  final String fileId;

  /// Título para exibição (ex: 'Picto Portfolio - Community Template').
  final String title;

  /// Nomes das páginas dentro do arquivo a mostrar.
  /// Se vazio, mostra todas.
  final List<String> pageNames;

  /// Descrição opcional.
  final String? description;

  /// URL do design (link original no Figma).
  final String? designUrl;
}

/// Registro canônico de arquivos Figma disponíveis no catálogo.
const List<RegisteredFigmaFile> registeredFigmaFiles = [
  RegisteredFigmaFile(
    id: 'figma_picto_portfolio',
    fileId: 'dNJqJo3t7XdPOiBNDA2cfm',
    title: 'Picto Portfolio - Community Template',
    pageNames: ['Design', 'Components'],
    description: 'Página de referência no Figma para validação visual rápida.',
    designUrl:
        'https://www.figma.com/design/dNJqJo3t7XdPOiBNDA2cfm/Picto---Personal-Portfolio-Free-Template--Community---Community-?node-id=85-2552&t=aiP4jncdbuVRcp7u-4',
  ),
];

/// Índice para lookup rápido por ID.
final Map<String, RegisteredFigmaFile> registeredFigmaFileById = {
  for (final file in registeredFigmaFiles) file.id: file,
};
