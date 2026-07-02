import 'dart:convert';

import 'package:http/http.dart' as http;

enum ReviewActionType {
  approve,
  requestChanges,
  dismiss,
}

extension ReviewActionTypeApiValue on ReviewActionType {
  String get apiValue {
    switch (this) {
      case ReviewActionType.approve:
        return 'APPROVE';
      case ReviewActionType.requestChanges:
        return 'REQUEST_CHANGES';
      case ReviewActionType.dismiss:
        return 'DISMISS';
    }
  }

  String get label {
    switch (this) {
      case ReviewActionType.approve:
        return 'Aprovar';
      case ReviewActionType.requestChanges:
        return 'Solicitar alteracoes';
      case ReviewActionType.dismiss:
        return 'Desaprovar revisao';
    }
  }
}

class ReviewContext {
  const ReviewContext({
    required this.owner,
    required this.repo,
    required this.pullNumber,
    this.reviewId,
  });

  final String owner;
  final String repo;
  final int pullNumber;
  final int? reviewId;

  bool get isValid => owner.isNotEmpty && repo.isNotEmpty && pullNumber > 0;

  ReviewContext copyWith({
    String? owner,
    String? repo,
    int? pullNumber,
    int? reviewId,
  }) {
    return ReviewContext(
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      pullNumber: pullNumber ?? this.pullNumber,
      reviewId: reviewId ?? this.reviewId,
    );
  }

  static ReviewContext? fromQuery(Map<String, String> query) {
    final owner = query['owner'];
    final repo = query['repo'];
    final pullNumber = int.tryParse(query['pr'] ?? '');
    if (owner == null || repo == null || pullNumber == null) {
      return null;
    }

    final reviewId = int.tryParse(query['review_id'] ?? '');
    return ReviewContext(
      owner: owner,
      repo: repo,
      pullNumber: pullNumber,
      reviewId: reviewId,
    );
  }
}

class ReviewActionResult {
  const ReviewActionResult({
    required this.ok,
    required this.message,
    this.statusCode,
  });

  final bool ok;
  final String message;
  final int? statusCode;
}

class ReviewApiClient {
  static const String _baseUrl =
      String.fromEnvironment('MORPHIX_REVIEW_API_BASE', defaultValue: '');
  static const String _apiKey =
      String.fromEnvironment('MORPHIX_REVIEW_API_KEY', defaultValue: '');

  bool get isEnabled => _baseUrl.trim().isNotEmpty;

  Future<ReviewActionResult> sendReviewAction({
    required ReviewContext context,
    required ReviewActionType action,
    String? body,
    String? componentId,
    String? baseBranch,
    String? headBranch,
  }) async {
    if (!isEnabled) {
      return const ReviewActionResult(
        ok: false,
        message:
            'Backend de review nao configurado. Defina MORPHIX_REVIEW_API_BASE no build web.',
      );
    }

    final endpoint = Uri.parse(_normalizeBase(_baseUrl));
    final payload = {
      'owner': context.owner,
      'repo': context.repo,
      'pull_number': context.pullNumber,
      'event': action.apiValue,
      'body': body?.trim().isNotEmpty == true ? body!.trim() : null,
      'review_id': context.reviewId,
      'component_id': componentId,
      'base_branch': baseBranch,
      'head_branch': headBranch,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_apiKey.isNotEmpty) {
      headers['X-Morphix-Review-Key'] = _apiKey;
    }

    try {
      final response = await http.post(
        endpoint,
        headers: headers,
        body: jsonEncode(payload),
      );

      final statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode < 300) {
        return ReviewActionResult(
          ok: true,
          message: 'Acao ${action.label} enviada com sucesso.',
          statusCode: statusCode,
        );
      }

      final responseBody = response.body.trim();
      final shortBody = responseBody.length > 220
          ? '${responseBody.substring(0, 220)}...'
          : responseBody;
      return ReviewActionResult(
        ok: false,
        message: 'Falha HTTP ${response.statusCode}: $shortBody',
        statusCode: statusCode,
      );
    } catch (error) {
      return ReviewActionResult(
        ok: false,
        message: 'Erro de rede ao chamar backend de review: $error',
      );
    }
  }

  String _normalizeBase(String base) {
    final trimmed = base.trim();
    if (trimmed.endsWith('/')) {
      return '${trimmed}github/reviews';
    }
    return '$trimmed/github/reviews';
  }
}
