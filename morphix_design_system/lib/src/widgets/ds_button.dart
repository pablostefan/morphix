import 'package:flutter/material.dart';

/// Botao simples do design system.
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
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
