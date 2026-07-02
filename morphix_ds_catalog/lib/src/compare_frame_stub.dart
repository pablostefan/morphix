import 'package:flutter/material.dart';

class CompareFrame extends StatelessWidget {
  const CompareFrame({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: SelectableText(url),
      ),
    );
  }
}
