// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class CompareFrame extends StatefulWidget {
  const CompareFrame({required this.url, super.key});

  final String url;

  @override
  State<CompareFrame> createState() => _CompareFrameState();
}

class _CompareFrameState extends State<CompareFrame> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType =
        'compare-frame-${DateTime.now().microsecondsSinceEpoch}-${widget.url.hashCode}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final iframe = html.IFrameElement()
        ..src = widget.url
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
