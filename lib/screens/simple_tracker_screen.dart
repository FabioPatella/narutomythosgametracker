import 'package:flutter/material.dart';
import '../models/player_state.dart';
import '../views/simple_player_view.dart';
import '../widgets/center_timer.dart';
import '../models/game_storage.dart';

class SimpleTrackerScreen extends StatefulWidget {
  final PlayerState? initialP1;
  final PlayerState? initialP2;
  final int? initialSeconds;
  final String? gameId;

  const SimpleTrackerScreen({
    super.key,
    this.initialP1,
    this.initialP2,
    this.initialSeconds,
    this.gameId,
  });

  @override
  State<SimpleTrackerScreen> createState() => _SimpleTrackerScreenState();
}

class _SimpleTrackerScreenState extends State<SimpleTrackerScreen> {
  late PlayerState player1;
  late PlayerState player2;
  late int secondsLeft;
  String? currentGameId;
  bool p1Flipped = false;
  bool p2Flipped = true;

  @override
  void initState() {
    super.initState();
    player1 = widget.initialP1 ?? PlayerState(name: "Giocatore 1");
    player2 = widget.initialP2 ?? PlayerState(name: "Giocatore 2");
    secondsLeft = widget.initialSeconds ?? 3000;
    currentGameId = widget.gameId;
  }

  void _saveGame() async {
    currentGameId = await GameStorage.saveSimpleGame(
      id: currentGameId,
      p1: player1,
      p2: player2,
      secondsLeft: secondsLeft,
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
            child: const Text('CHIUDI', style: TextStyle(color: Colors.blueAccent)),
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
          child: Column(
            children: [
              Expanded(
                child: RotatedBox(
                  quarterTurns: p2Flipped ? 2 : 0,
                  child: SimplePlayerView(
                    state: player2,
                    onFlip: () => setState(() => p2Flipped = !p2Flipped),
                    isFlipped: p2Flipped,
                    color: Colors.red[900]!,
                    onChanged: _saveGame,
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.blueAccent, thickness: 1),
              CenterTimer(
                onExit: () => _requestExit(),
                initialSeconds: secondsLeft,
                onChanged: (s) {
                  secondsLeft = s;
                  _saveGame();
                },
              ),
              const Divider(height: 1, color: Colors.blueAccent, thickness: 1),
              Expanded(
                child: RotatedBox(
                  quarterTurns: p1Flipped ? 2 : 0,
                  child: SimplePlayerView(
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
        ),
      ),
    );
  }
}
