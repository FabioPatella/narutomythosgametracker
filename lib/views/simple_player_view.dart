import 'package:flutter/material.dart';
import '../models/player_state.dart';
import '../widgets/score_counter.dart';

class SimplePlayerView extends StatefulWidget {
  final PlayerState state;
  final VoidCallback onFlip;
  final bool isFlipped;
  final Color color;
  final VoidCallback? onChanged;

  const SimplePlayerView({
    super.key,
    required this.state,
    required this.onFlip,
    required this.isFlipped,
    required this.color,
    this.onChanged,
  });

  @override
  State<SimplePlayerView> createState() => _SimplePlayerViewState();
}

class _SimplePlayerViewState extends State<SimplePlayerView> {
  bool _colsCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      IconButton(
        icon: Icon(widget.isFlipped ? Icons.flip_to_back : Icons.flip_to_front, size: 28),
        onPressed: widget.onFlip,
        visualDensity: VisualDensity.compact,
      ),
      IconButton(
        icon: Icon(_colsCollapsed ? Icons.unfold_more : Icons.unfold_less, color: Colors.white60),
        onPressed: () => setState(() => _colsCollapsed = !_colsCollapsed),
        tooltip: _colsCollapsed ? 'Mostra Colonne' : 'Nascondi Colonne',
      ),
    ];

    final counters = FittedBox(
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
            ultraLarge: _colsCollapsed,
            superLarge: true,
            large: true,
          ),
          const SizedBox(width: 24),
          ScoreCounter(
            label: "SCORE",
            value: widget.state.score,
            onChanged: (v) {
              setState(() => widget.state.score = v);
              widget.onChanged?.call();
            },
            color: Colors.orangeAccent,
            ultraLarge: _colsCollapsed,
            superLarge: true,
            large: true,
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.all(_colsCollapsed ? 0 : 8.0),
      decoration: BoxDecoration(
        color: _colsCollapsed ? widget.color.withOpacity(0.15) : Colors.transparent,
        border: Border.all(color: widget.color.withOpacity(0.5), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _wrapInExpandedIf(
            condition: _colsCollapsed,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                borderRadius: _colsCollapsed ? BorderRadius.zero : BorderRadius.circular(12),
              ),
              child: _colsCollapsed
                  ? Column(
                      children: [
                        Expanded(child: Center(child: counters)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buttons,
                        ),
                        const SizedBox(height: 8),
                      ],
                    )
                  : Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: buttons,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: counters),
                      ],
                    ),
            ),
          ),
          if (!_colsCollapsed) ...[
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: List.generate(4, (colIndex) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: widget.state.simpleColumns[colIndex] == null
                                ? Center(
                                    child: IconButton(
                                      iconSize: 56,
                                      icon: const Icon(Icons.add_circle_outline),
                                      color: Colors.greenAccent.withOpacity(0.5),
                                      onPressed: () {
                                        setState(() {
                                          widget.state.simpleColumns[colIndex] = 0;
                                        });
                                        widget.onChanged?.call();
                                      },
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "${widget.state.simpleColumns[colIndex]}",
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              IconButton(
                                                iconSize: 32,
                                                icon: const Icon(Icons.remove_circle_outline),
                                                color: Colors.redAccent.withOpacity(0.7),
                                                onPressed: () {
                                                  setState(() {
                                                    if (widget.state.simpleColumns[colIndex]! > 0) {
                                                      widget.state.simpleColumns[colIndex] =
                                                          widget.state.simpleColumns[colIndex]! - 1;
                                                    } else {
                                                      widget.state.simpleColumns[colIndex] = null;
                                                    }
                                                  });
                                                  widget.onChanged?.call();
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                iconSize: 44,
                                                icon: const Icon(Icons.add_circle),
                                                color: Colors.greenAccent,
                                                onPressed: () {
                                                  setState(() {
                                                    widget.state.simpleColumns[colIndex] =
                                                        widget.state.simpleColumns[colIndex]! + 1;
                                                  });
                                                  widget.onChanged?.call();
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
        ],
      ),
    );
  }

  Widget _wrapInExpandedIf({required bool condition, required Widget child}) {
    if (condition) return Expanded(child: child);
    return child;
  }
}
