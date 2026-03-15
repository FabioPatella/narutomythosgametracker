import 'dart:async' as async_timer;
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NarutoGameTracker());
}

class NarutoGameTracker extends StatelessWidget {
  const NarutoGameTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naruto Mythos TCG Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange[800],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange[900]!,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GameBoard(),
    );
  }
}

class SharedCardModel {
  int score;
  SharedCardModel({this.score = 0});
}

class CardModel {
  String name;
  int power;
  int cost;
  bool isFacedown;
  bool isCollapsed;
  CardModel({this.name = "", this.power = 0, this.cost = 0, this.isFacedown = false, this.isCollapsed = false});
}

class PlayerState {
  String name;
  int chakra = 0;
  int score = 0;
  List<List<CardModel>> columns = List.generate(4, (_) => []);
  PlayerState({required this.name});
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  PlayerState player1 = PlayerState(name: "Giocatore 1");
  PlayerState player2 = PlayerState(name: "Giocatore 2");
  List<SharedCardModel?> sharedCards = List.generate(4, (_) => null);
  bool p1Flipped = false;
  bool p2Flipped = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Player (Player 2)
                Expanded(
                  child: RotatedBox(
                    quarterTurns: p2Flipped ? 2 : 0,
                    child: PlayerView(
                      state: player2,
                      onFlip: () => setState(() => p2Flipped = !p2Flipped),
                      isFlipped: p2Flipped,
                      color: Colors.red[900]!,
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.orange, thickness: 1),
                _SharedCardsMiddleBar(
                  sharedCards: sharedCards,
                  onAdd: (idx) => setState(() => sharedCards[idx] = SharedCardModel()),
                  onRemove: (idx) => setState(() => sharedCards[idx] = null),
                  onUpdate: () => setState(() {}),
                ),
                const Divider(height: 1, color: Colors.orange, thickness: 1),
                // Bottom Player (Player 1)
                Expanded(
                  child: RotatedBox(
                    quarterTurns: p1Flipped ? 2 : 0,
                    child: PlayerView(
                      state: player1,
                      onFlip: () => setState(() => p1Flipped = !p1Flipped),
                      isFlipped: p1Flipped,
                      color: Colors.blue[900]!,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedCardsMiddleBar extends StatelessWidget {
  final List<SharedCardModel?> sharedCards;
  final Function(int) onAdd;
  final Function(int) onRemove;
  final VoidCallback onUpdate;

  const _SharedCardsMiddleBar({
    required this.sharedCards,
    required this.onAdd,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.black,
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: _SharedSlot(
              card: sharedCards[index],
              onAdd: () => onAdd(index),
              onRemove: () => onRemove(index),
              onUpdate: onUpdate,
            ),
          );
        }),
      ),
    );
  }
}

class _SharedSlot extends StatelessWidget {
  final SharedCardModel? card;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onUpdate;

  const _SharedSlot({this.card, required this.onAdd, required this.onRemove, required this.onUpdate});

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
          : _SharedCardMini(
              card: card!,
              onDelete: onRemove,
              onUpdate: onUpdate,
            ),
    );
  }
}

class PlayerView extends StatefulWidget {
  final PlayerState state;
  final VoidCallback onFlip;
  final bool isFlipped;
  final Color color;

  const PlayerView({
    super.key,
    required this.state,
    required this.onFlip,
    required this.isFlipped,
    required this.color,
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
                        onChanged: (v) => widget.state.name = v,
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
                      _ScoreCounter(
                        label: "CHAKRA",
                        value: widget.state.chakra,
                        onChanged: (v) => setState(() => widget.state.chakra = v),
                        color: Colors.cyanAccent,
                        large: !isLandscape,
                      ),
                      const SizedBox(width: 4),
                      _ScoreCounter(
                        label: "SCORE",
                        value: widget.state.score,
                        onChanged: (v) => setState(() => widget.state.score = v),
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
                              child: Text("COL ${colIndex + 1}", 
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                itemCount: widget.state.columns[colIndex].length,
                                itemBuilder: (context, cardIndex) {
                                  return _CardWidget(
                                    card: widget.state.columns[colIndex][cardIndex],
                                    onDelete: () => _requestDelete(widget.state.columns[colIndex][cardIndex], colIndex, cardIndex),
                                    onUpdate: () => setState(() {}),
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
                        style: TextStyle(color: widget.color.withOpacity(1), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _cardPendingDelete!.name.isEmpty ? "Questa carta verrà rimossa" : "'${_cardPendingDelete!.name}'",
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

class _ScoreCounter extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;
  final bool large;

  const _ScoreCounter({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BigButton(
                icon: Icons.remove, 
                onPressed: () => onChanged(max(0, value - 1)),
                color: color,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 32),
                alignment: Alignment.center,
                child: Text(
                  "$value", 
                  style: TextStyle(
                    fontSize: large ? 24 : 18, 
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  )
                ),
              ),
              _BigButton(
                icon: Icons.add, 
                onPressed: () => onChanged(value + 1),
                color: color,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final bool compact;

  const _CardWidget({
    super.key,
    required this.card, 
    required this.onDelete, 
    required this.onUpdate,
    this.compact = false,
  });

  void _confirmDelete(BuildContext context) {
    // This will trigger the PlayerView's _requestDelete method
    // which then shows the global confirmation overlay.
    onDelete();
  }

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
            // Row 1: JUST Bolt and Name (MAX SPACE FOR NAME)
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
                          width: 200, // Increased width for maximum flexibility
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
                      child: Text("COPERTA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    ),
                  ),
              ],
            ),
            
            // Row 2: Stats and Actions (if collapsed)
            if (!card.isFacedown) ...[
              if (card.isCollapsed)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatLabel(label: "P", value: card.power, color: Colors.greenAccent),
                        const SizedBox(width: 4),
                        _StatLabel(label: "C", value: card.cost, color: Colors.purpleAccent),
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
                          onTap: () => _confirmDelete(context),
                          child: const Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 4),
                _ValueEdit(
                  label: "P",
                  value: card.power,
                  onChanged: (v) { card.power = v; onUpdate(); },
                  color: Colors.greenAccent,
                  compact: compact,
                ),
                _ValueEdit(
                  label: "C",
                  value: card.cost,
                  onChanged: (v) { card.cost = v; onUpdate(); },
                  color: Colors.purpleAccent,
                  compact: compact,
                ),
                // Expanded actions row
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
                      onTap: () => _confirmDelete(context),
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

class _SharedCardMini extends StatelessWidget {
  final SharedCardModel card;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const _SharedCardMini({required this.card, required this.onDelete, required this.onUpdate});

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
          const Text("S:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () { card.score = max(0, card.score - 1); onUpdate(); },
            child: const Icon(Icons.remove, size: 12, color: Colors.white70),
          ),
          SizedBox(
            width: 18,
            child: Center(
              child: Text("${card.score}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          GestureDetector(
            onTap: () { card.score += 1; onUpdate(); },
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

class _ValueEdit extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;
  final bool compact;

  const _ValueEdit({
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
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
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
              child: Text("$value", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

class _BigButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _BigButton({required this.icon, required this.onPressed, required this.color});

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
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatLabel({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text("$value", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

