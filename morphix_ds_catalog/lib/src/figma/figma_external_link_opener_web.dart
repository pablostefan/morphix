// ignore: avoid_web_libraries_in_flutter
// ignore: dangling_library_doc_comments
/// Serviço de abertura de links externos.
/// Implementação web usando dart:html.

// ignore: avoid_web_libraries_in_flutter
// ignore: deprecated_member_use
import 'dart:html' as html;

// ignore: deprecated_member_use
bool openExternalLink(String url) {
  try {
    // ignore: deprecated_member_use
    html.window.open(url, '_blank');
    return true;
  } catch (_) {
    return false;
  }
}
