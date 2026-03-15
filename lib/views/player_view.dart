import 'package:flutter/material.dart';
import '../models/player_state.dart';
import '../models/card_model.dart';
import '../widgets/score_counter.dart';
import '../widgets/card_widget.dart';

class PlayerView extends StatefulWidget {
  final PlayerState state;
  final VoidCallback onFlip;
  final bool isFlipped;
  final Color color;
  final VoidCallback? onChanged;

  const PlayerView({
    super.key,
    required this.state,
    required this.onFlip,
    required this.isFlipped,
    required this.color,
    this.onChanged,
  });

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  CardModel? _cardPendingDelete;
  int? _pendingDeleteColIndex;
  int? _pendingDeleteCardIndex;

  void _addCard(int columnIndex) {
    setState(() {
      widget.state.columns[columnIndex].add(CardModel());
    });
    widget.onChanged?.call();
  }

  void _requestDelete(CardModel card, int colIndex, int cardIndex) {
    setState(() {
      _cardPendingDelete = card;
      _pendingDeleteColIndex = colIndex;
      _pendingDeleteCardIndex = cardIndex;
    });
  }

  void _confirmDelete() {
    if (_pendingDeleteColIndex != null && _pendingDeleteCardIndex != null) {
      setState(() {
        widget.state.columns[_pendingDeleteColIndex!].removeAt(_pendingDeleteCardIndex!);
        _cardPendingDelete = null;
        _pendingDeleteColIndex = null;
        _pendingDeleteCardIndex = null;
      });
      widget.onChanged?.call();
    }
  }

  void _cancelDelete() {
    setState(() {
      _cardPendingDelete = null;
      _pendingDeleteColIndex = null;
      _pendingDeleteCardIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            border: Border.all(color: widget.color.withOpacity(0.5), width: 2),
          ),
          child: Column(
            children: [
              // Header: Name, Scores, Flip
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(widget.isFlipped ? Icons.flip_to_back : Icons.flip_to_front, size: 18),
                      onPressed: widget.onFlip,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) {
                          widget.state.name = v;
                          widget.onChanged?.call();
                        },
                        controller: TextEditingController(text: widget.state.name)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: widget.state.name.length),
                          ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScoreCounter(
                            label: "CHAKRA",
                            value: widget.state.chakra,
                            onChanged: (v) {
                              setState(() => widget.state.chakra = v);
                              widget.onChanged?.call();
                            },
                            color: Colors.cyanAccent,
                            large: !isLandscape,
                          ),
                          const SizedBox(width: 4),
                          ScoreCounter(
                            label: "SCORE",
                            value: widget.state.score,
                            onChanged: (v) {
                              setState(() => widget.state.score = v);
                              widget.onChanged?.call();
                            },
                            color: Colors.orangeAccent,
                            large: !isLandscape,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Columns
              Expanded(
                child: Row(
                  children: List.generate(4, (colIndex) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              color: widget.color.withOpacity(0.1),
                              child: Text(
                                "COL ${colIndex + 1}",
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                itemCount: widget.state.columns[colIndex].length,
                                itemBuilder: (context, cardIndex) {
                                  return CardWidget(
                                    card: widget.state.columns[colIndex][cardIndex],
                                    onDelete: () => _requestDelete(
                                      widget.state.columns[colIndex][cardIndex],
                                      colIndex,
                                      cardIndex,
                                    ),
                                    onUpdate: () {
                                      setState(() {});
                                      widget.onChanged?.call();
                                    },
                                    compact: isLandscape,
                                  );
                                },
                              ),
                            ),
                            InkWell(
                              onTap: () => _addCard(colIndex),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                                ),
                                child: const Icon(Icons.add, size: 16, color: Colors.greenAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        // Local Confirmation Overlay
        if (_cardPendingDelete != null)
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        "ELIMINA CARTA?",
                        style: TextStyle(
                          color: widget.color.withOpacity(1),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _cardPendingDelete!.name.isEmpty
                            ? "Questa carta verrà rimossa"
                            : "'${_cardPendingDelete!.name}'",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _cancelDelete,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                            child: const Text("ANNULLA", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: _confirmDelete,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                            child: const Text("ELIMINA", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
