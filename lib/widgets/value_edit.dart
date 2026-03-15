import 'dart:math';
import 'package:flutter/material.dart';

class ValueEdit extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;
  final bool compact;

  const ValueEdit({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 1 : 3),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              onTap: () => onChanged(max(0, value - 1)),
              child: const Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(Icons.remove, size: 16),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              alignment: Alignment.center,
              child: Text(
                "$value",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () => onChanged(value + 1),
              child: const Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(Icons.add, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
