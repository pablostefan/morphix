import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'figma_config.dart';
import 'figma_models.dart';

/// Serviço para acessar Figma API.
class FigmaService {
  static const String _baseUrl = 'https://api.figma.com/v1';

  /// Obtém arquivo Figma completo (com estrutura de páginas).
  ///
  /// Requer token configurado.
  /// Returns: FigmaFile com metadados do arquivo.
  static Future<FigmaFile?> getFile(String fileId) async {
    if (!isFigmaTokenConfigured()) {
      // ignore: avoid_print
      print('[Figma] Token não configurado. Defina FIGMA_API_TOKEN.');
      return null;
    }

    try {
      final response = await _request('GET', '/files/$fileId');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return FigmaFile.fromJson(json);
      } else if (response.statusCode == 401) {
        // ignore: avoid_print
        print('[Figma] Token inválido ou expirado.');
        return null;
      } else if (response.statusCode == 404) {
        // ignore: avoid_print
        print('[Figma] Arquivo não encontrado.');
        return null;
      } else {
        // ignore: avoid_print
        print('[Figma] Erro ao buscar arquivo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Figma] Exceção: $e');
      return null;
    }
  }

  /// Obtém screenshot de uma página Figma.
  ///
  /// [fileId]: ID do arquivo Figma.
  /// [pageId]: ID da página (obtido de FigmaFile.pages).
  /// [scale]: Escala da imagem (1, 2, 3, 4). Default: 1.
  /// [format]: 'png', 'jpg', 'svg'. Default: 'png'.
  ///
  /// Returns: URL da imagem renderizada.
  static Future<String?> getPageScreenshot(
    String fileId,
    String pageId, {
    int scale = 2,
    String format = 'png',
  }) async {
    if (!isFigmaTokenConfigured()) {
      // ignore: avoid_print
      print('[Figma] Token não configurado. Defina FIGMA_API_TOKEN.');
      return null;
    }

    try {
      final query = {
        'ids': pageId,
        'format': format,
        'scale': scale.toString(),
      };

      final response = await _request(
        'GET',
        '/images/$fileId',
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final imagesResponse = FigmaImagesResponse.fromJson(json);
        return imagesResponse.images[pageId];
      } else {
        // ignore: avoid_print
        print('[Figma] Erro ao obter screenshot: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Figma] Exceção ao gerar screenshot: $e');
      return null;
    }
  }

  /// Obtém nós específicos de um arquivo (para metadados, bounds, etc).
  static Future<FigmaNodesResponse?> getNodes(
    String fileId,
    List<String> nodeIds,
  ) async {
    if (!isFigmaTokenConfigured()) {
      // ignore: avoid_print
      print('[Figma] Token não configurado. Defina FIGMA_API_TOKEN.');
      return null;
    }

    try {
      final query = {'ids': nodeIds.join(',')};
      final response = await _request(
        'GET',
        '/files/$fileId/nodes',
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return FigmaNodesResponse.fromJson(json);
      } else {
        // ignore: avoid_print
        print('[Figma] Erro ao obter nós: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Figma] Exceção ao buscar nós: $e');
      return null;
    }
  }

  /// Requisição HTTP interna com headers padrão.
  static Future<http.Response> _request(
    String method,
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final headers = {
      'X-FIGMA-TOKEN': figmaApiToken,
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('$_baseUrl$path');
    final urlWithQuery = url.replace(queryParameters: queryParameters);

    final request = http.Request(method, urlWithQuery);
    request.headers.addAll(headers);

    final streamResponse = await request.send().timeout(figmaApiTimeout);
    return http.Response.fromStream(streamResponse);
  }
}
