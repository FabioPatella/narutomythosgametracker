import 'dart:math';
import 'package:flutter/material.dart';
import 'big_button.dart';

class ScoreCounter extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;
  final bool large;
  final bool superLarge;
  final bool ultraLarge;

  const ScoreCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.color,
    this.large = false,
    this.superLarge = false,
    this.ultraLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ultraLarge ? 20 : (superLarge ? 12 : 8),
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BigButton(
                icon: Icons.remove,
                onPressed: () => onChanged(max(0, value - 1)),
                color: color,
                size: superLarge ? 32 : 20,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 32),
                alignment: Alignment.center,
                child: Text(
                  "$value",
                  style: TextStyle(
                    fontSize: ultraLarge ? 120 : (superLarge ? 64 : (large ? 24 : 18)),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              BigButton(
                icon: Icons.add,
                onPressed: () => onChanged(value + 1),
                color: color,
                size: superLarge ? 32 : 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
