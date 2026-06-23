import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );

    if (icon != null) {
      return ElevatedButton.icon(
        style: style,
        icon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        label: Text(
          text, 
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        onPressed: onPressed,
      );
    }

    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Text(
        text, 
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
