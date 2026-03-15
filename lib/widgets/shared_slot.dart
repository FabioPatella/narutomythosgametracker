import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'shared_card_mini.dart';

class SharedSlot extends StatelessWidget {
  final SharedCardModel? card;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onUpdate;

  const SharedSlot({
    super.key,
    this.card,
    required this.onAdd,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: card == null
          ? InkWell(
              onTap: onAdd,
              child: const Icon(Icons.add, size: 14, color: Colors.orangeAccent),
            )
          : SharedCardMini(
              card: card!,
              onDelete: onRemove,
              onUpdate: onUpdate,
            ),
    );
  }
}
