import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'shared_slot.dart';

class SharedCardsMiddleBar extends StatelessWidget {
  final List<SharedCardModel?> sharedCards;
  final Function(int) onAdd;
  final Function(int) onRemove;
  final VoidCallback onUpdate;
  final VoidCallback onExit;

  const SharedCardsMiddleBar({
    super.key,
    required this.sharedCards,
    required this.onAdd,
    required this.onRemove,
    required this.onUpdate,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.grey),
            onPressed: onExit,
            tooltip: 'Torna alla Home',
          ),
          const VerticalDivider(width: 1, color: Colors.white24, thickness: 1),
          Expanded(
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: SharedSlot(
                    card: sharedCards[index],
                    onAdd: () => onAdd(index),
                    onRemove: () => onRemove(index),
                    onUpdate: onUpdate,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
