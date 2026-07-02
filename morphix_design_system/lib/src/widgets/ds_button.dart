import 'package:flutter/material.dart';

/// Botao simples do design system.
/// @dsPreview(id: ds_button, title: DS Button)
class DsButton extends StatelessWidget {
  const DsButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
