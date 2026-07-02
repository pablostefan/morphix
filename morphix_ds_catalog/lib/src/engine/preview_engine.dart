import 'package:flutter/material.dart';

typedef PreviewWidgetBuilder = Widget Function(BuildContext context);

class CatalogPreview {
  const CatalogPreview({
    required this.id,
    required this.title,
    required this.description,
    required this.builder,
  });

  final String id;
  final String title;
  final String description;
  final PreviewWidgetBuilder builder;

  Widget build(BuildContext context) => builder(context);
}
