// ignore: dangling_library_doc_comments
/// Serviço de abertura de links externos.
/// Export condicional baseado em plataforma.

export 'figma_external_link_opener_stub.dart'
    if (dart.library.html) 'figma_external_link_opener_web.dart';
