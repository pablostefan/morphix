import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'figma_external_link_opener.dart';
import 'figma_registry.dart';
import 'figma_service.dart';

/// Widget para exibir uma página Figma com screenshot.
///
/// Carrega dinamicamente via Figma API usando o token configurado.
/// Exibe screenshot, título, descrição e ações (copiar URL, abrir no Figma).
class FigmaPageView extends StatefulWidget {
  const FigmaPageView({
    required this.fileId,
    super.key,
  });

  final String fileId;

  @override
  State<FigmaPageView> createState() => _FigmaPageViewState();
}

class _FigmaPageViewState extends State<FigmaPageView> {
  String? _pageScreenshotUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFigmaData();
  }

  Future<void> _loadFigmaData() async {
    try {
      // 1. Busca metadados do arquivo
      final file = await FigmaService.getFile(widget.fileId);

      if (file == null) {
        setState(() {
          _error = 'Não foi possível carregar o arquivo Figma.';
          _isLoading = false;
        });
        return;
      }

      // 2. Se houver páginas, busca screenshot da primeira
      if (file.pages.isNotEmpty) {
        final pageId = file.pages.first.id;
        final screenshotUrl = await FigmaService.getPageScreenshot(
          widget.fileId,
          pageId,
          scale: 2,
          format: 'png',
        );

        setState(() {
          _pageScreenshotUrl = screenshotUrl;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Nenhuma página encontrada no arquivo.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar: $e';
        _isLoading = false;
      });
    }
  }

  void _copyUrl() {
    final file = registeredFigmaFileById.values.firstWhere(
      (f) => f.fileId == widget.fileId,
      orElse: () => registeredFigmaFiles.first,
    );

    if (file.designUrl != null) {
      Clipboard.setData(ClipboardData(text: file.designUrl!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL copiada para clipboard')),
        );
      }
    }
  }

  void _openInFigma() {
    final file = registeredFigmaFileById.values.firstWhere(
      (f) => f.fileId == widget.fileId,
      orElse: () => registeredFigmaFiles.first,
    );

    if (file.designUrl != null) {
      final opened = openExternalLink(file.designUrl!);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abra em: ${file.designUrl}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Busca arquivo registrado pelo fileId
    RegisteredFigmaFile? file;
    for (final f in registeredFigmaFiles) {
      if (f.fileId == widget.fileId) {
        file = f;
        break;
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com título e descrição
            if (file != null) ...[
              Text(
                file.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              if (file.description != null)
                Text(
                  file.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 16),

              // Botões de ação
              Wrap(
                spacing: 12,
                children: [
                  FilledButton(
                    onPressed: _openInFigma,
                    child: const Text('Abrir no Figma'),
                  ),
                  OutlinedButton(
                    onPressed: _copyUrl,
                    child: const Text('Copiar URL'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Estado de carregamento
            if (_isLoading)
              Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando página Figma...'),
                  ],
                ),
              )
            else if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Erro ao carregar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else if (_pageScreenshotUrl != null) ...[
              // Screenshot da página
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    _pageScreenshotUrl!,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Não foi possível carregar o screenshot',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhuma página disponível'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
