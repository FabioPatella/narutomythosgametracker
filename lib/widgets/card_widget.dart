import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'value_edit.dart';
import 'stat_label.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final bool compact;

  const CardWidget({
    super.key,
    required this.card,
    required this.onDelete,
    required this.onUpdate,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = compact ? 20 : 35;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      color: card.isFacedown ? Colors.orange[900]?.withOpacity(0.5) : Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: card.isFacedown ? const BorderSide(color: Colors.orange, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(card.isCollapsed ? 4.0 : 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    card.isFacedown = !card.isFacedown;
                    onUpdate();
                  },
                  child: Icon(
                    card.isFacedown ? Icons.visibility_off : Icons.bolt,
                    size: 14,
                    color: card.isFacedown ? Colors.orangeAccent : Colors.orange,
                  ),
                ),
                if (!card.isFacedown)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 200,
                          child: card.isCollapsed
                              ? Text(
                                  card.name.isEmpty ? "CARTA" : card.name,
                                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                )
                              : TextField(
                                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    hintText: "Nome...",
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (v) => card.name = v,
                                  controller: TextEditingController(text: card.name)
                                    ..selection = TextSelection.fromPosition(
                                      TextPosition(offset: card.name.length),
                                    ),
                                ),
                        ),
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text(
                        "COPERTA",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (!card.isFacedown) ...[
              if (card.isCollapsed)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatLabel(label: "P", value: card.power, color: Colors.greenAccent),
                        const SizedBox(width: 4),
                        StatLabel(label: "C", value: card.cost, color: Colors.purpleAccent),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            card.isCollapsed = false;
                            onUpdate();
                          },
                          child: const Icon(Icons.unfold_more, size: 14, color: Colors.white60),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 4),
                ValueEdit(
                  label: "P",
                  value: card.power,
                  onChanged: (v) {
                    card.power = v;
                    onUpdate();
                  },
                  color: Colors.greenAccent,
                  compact: compact,
                ),
                ValueEdit(
                  label: "C",
                  value: card.cost,
                  onChanged: (v) {
                    card.cost = v;
                    onUpdate();
                  },
                  color: Colors.purpleAccent,
                  compact: compact,
                ),
                const Divider(height: 8, thickness: 0.5, color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        card.isCollapsed = true;
                        onUpdate();
                      },
                      child: const Icon(Icons.unfold_less, size: 16, color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
