// ignore: dangling_library_doc_comments
/// Modelos para respostas da Figma API.

/// Resposta do endpoint GET /v1/files/:file_id
class FigmaFile {
  const FigmaFile({
    required this.id,
    required this.name,
    required this.pages,
  });

  final String id;
  final String name;
  final List<FigmaPageNode> pages;

  /// Parse from JSON (resposta da API).
  factory FigmaFile.fromJson(Map<String, dynamic> json) {
    final pagesJson = json['document']['children'] as List<dynamic>? ?? [];
    return FigmaFile(
      id: json['file']['key'] as String? ?? '',
      name: json['file']['name'] as String? ?? '',
      pages: pagesJson
          .map((p) => FigmaPageNode.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Representa uma página dentro de um arquivo Figma.
class FigmaPageNode {
  const FigmaPageNode({
    required this.id,
    required this.name,
    this.children = const [],
  });

  final String id;
  final String name;
  final List<dynamic> children;

  factory FigmaPageNode.fromJson(Map<String, dynamic> json) {
    return FigmaPageNode(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      children: json['children'] as List<dynamic>? ?? [],
    );
  }
}

/// Resposta do endpoint GET /v1/files/:file_id/nodes (para screenshots).
class FigmaNodesResponse {
  const FigmaNodesResponse({
    required this.nodes,
  });

  final Map<String, FigmaNode> nodes;

  factory FigmaNodesResponse.fromJson(Map<String, dynamic> json) {
    final nodesJson = json['nodes'] as Map<String, dynamic>? ?? {};
    return FigmaNodesResponse(
      nodes: nodesJson.map(
        (key, value) => MapEntry(key, FigmaNode.fromJson(value)),
      ),
    );
  }
}

/// Nó individual (para metadados, bounds, etc).
class FigmaNode {
  const FigmaNode({
    required this.id,
    required this.name,
    this.type,
    this.bounds,
  });

  final String id;
  final String name;
  final String? type;
  final Map<String, dynamic>? bounds;

  factory FigmaNode.fromJson(Map<String, dynamic> json) {
    return FigmaNode(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      bounds: json['bounds'] as Map<String, dynamic>?,
    );
  }
}

/// Resposta do endpoint GET /v1/images (para obter URLs de imagens).
class FigmaImagesResponse {
  const FigmaImagesResponse({
    required this.images,
  });

  final Map<String, String> images;

  factory FigmaImagesResponse.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as Map<String, dynamic>? ?? {};
    return FigmaImagesResponse(
      images: imagesJson.cast<String, String>(),
    );
  }
}
