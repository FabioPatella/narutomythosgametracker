import 'package:flutter/material.dart';
import '../models/player_state.dart';
import '../models/card_model.dart';
import '../views/player_view.dart';
import '../widgets/shared_cards_middle_bar.dart';
import '../models/game_storage.dart';

class GameBoard extends StatefulWidget {
  final PlayerState? initialP1;
  final PlayerState? initialP2;
  final List<SharedCardModel?>? initialShared;
  final String? gameId;

  const GameBoard({
    super.key,
    this.initialP1,
    this.initialP2,
    this.initialShared,
    this.gameId,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late PlayerState player1;
  late PlayerState player2;
  late List<SharedCardModel?> sharedCards;
  String? currentGameId;
  bool p1Flipped = false;
  bool p2Flipped = true;

  @override
  void initState() {
    super.initState();
    player1 = widget.initialP1 ?? PlayerState(name: "Giocatore 1");
    player2 = widget.initialP2 ?? PlayerState(name: "Giocatore 2");
    sharedCards = widget.initialShared ?? List.generate(4, (_) => null);
    currentGameId = widget.gameId;
  }

  void _saveGame() async {
    currentGameId = await GameStorage.saveExtendedGame(
      id: currentGameId,
      p1: player1,
      p2: player2,
      sharedCards: sharedCards,
    );
  }

  Future<bool> _requestExit() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiudere la partita?'),
        content: const Text(
            'La partita verrà salvata automaticamente e potrai riprenderla dalla home.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('CHIUDI', style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
    if (result == true) {
      if (!mounted) return true;
      Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: _requestExit,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: p2Flipped ? 2 : 0,
                      child: PlayerView(
                        state: player2,
                        onFlip: () => setState(() => p2Flipped = !p2Flipped),
                        isFlipped: p2Flipped,
                        color: Colors.red[900]!,
                        onChanged: _saveGame,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.orange, thickness: 1),
                  SharedCardsMiddleBar(
                    sharedCards: sharedCards,
                    onAdd: (idx) => setState(() {
                      sharedCards[idx] = SharedCardModel();
                      _saveGame();
                    }),
                    onRemove: (idx) => setState(() {
                      sharedCards[idx] = null;
                      _saveGame();
                    }),
                    onUpdate: () => setState(() {
                      _saveGame();
                    }),
                    onExit: () => _requestExit(),
                  ),
                  const Divider(height: 1, color: Colors.orange, thickness: 1),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: p1Flipped ? 2 : 0,
                      child: PlayerView(
                        state: player1,
                        onFlip: () => setState(() => p1Flipped = !p1Flipped),
                        isFlipped: p1Flipped,
                        color: Colors.blue[900]!,
                        onChanged: _saveGame,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
