import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const BigButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
