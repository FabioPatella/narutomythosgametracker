import 'dart:math';
import 'package:flutter/material.dart';
import '../models/card_model.dart';

class SharedCardMini extends StatelessWidget {
  final SharedCardModel card;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const SharedCardMini({
    super.key,
    required this.card,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "S:",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () {
              card.score = max(0, card.score - 1);
              onUpdate();
            },
            child: const Icon(Icons.remove, size: 12, color: Colors.white70),
          ),
          SizedBox(
            width: 18,
            child: Center(
              child: Text(
                "${card.score}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              card.score += 1;
              onUpdate();
            },
            child: const Icon(Icons.add, size: 12, color: Colors.white70),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 12, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
