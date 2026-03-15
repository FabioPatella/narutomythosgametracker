import 'package:flutter/material.dart';
import 'simple_tracker_screen.dart';
import 'game_board.dart';
import '../models/game_storage.dart';
import '../models/card_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> simpleGames = [];
  List<Map<String, dynamic>> extendedGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGames();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    final simple = await GameStorage.loadSimpleGames();
    final extended = await GameStorage.loadExtendedGames();
    setState(() {
      simpleGames = simple;
      extendedGames = extended;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlowCircle(Colors.orange[900]!.withOpacity(0.15), 300),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: _buildGlowCircle(Colors.blue[900]!.withOpacity(0.15), 350),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildModeSelector(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildGameList(simpleGames, isSimple: true),
                            _buildGameList(extendedGames, isSimple: false),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _shouldShowFAB()
          ? FloatingActionButton.extended(
              onPressed: () => _onFabPressed(),
              backgroundColor: _tabController.index == 0 ? Colors.blue[700] : Colors.orange[800],
              icon: const Icon(Icons.add_rounded, size: 28),
              label: const Text(
                "NEW GAME",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            )
          : null,
    );
  }

  bool _shouldShowFAB() {
    if (_tabController.index == 0) return simpleGames.isNotEmpty;
    return extendedGames.isNotEmpty;
  }

  void _onFabPressed() {
    if (_tabController.index == 0) {
      _startSimple(null);
    } else {
      _startExtended(null);
    }
  }

  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "NARUTO MYTHOS",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.orangeAccent.withOpacity(0.8),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Game Tracker",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: _tabController.index == 0
                ? [Colors.blue[800]!, Colors.blue[600]!]
                : [Colors.orange[800]!, Colors.orange[600]!],
          ),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelColor: Colors.white54,
        onTap: (_) => setState(() {}),
        tabs: const [
          Tab(text: "SIMPLE MODE"),
          Tab(text: "EXTENDED MODE"),
        ],
      ),
    );
  }

  Widget _buildGameList(List<Map<String, dynamic>> games, {required bool isSimple}) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSimple ? Icons.speed_rounded : Icons.dashboard_rounded,
              size: 80,
              color: Colors.white12,
            ),
            const SizedBox(height: 16),
            const Text(
              "No saved games",
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => isSimple ? _startSimple(null) : _startExtended(null),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  "NEW GAME",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSimple ? Colors.blue[700] : Colors.orange[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: (isSimple ? Colors.blue : Colors.orange).withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final g = games[index];
        return _buildModernGameCard(g, isSimple: isSimple);
      },
    );
  }

  Widget _buildModernGameCard(Map<String, dynamic> game, {required bool isSimple}) {
    final timestamp = game['timestamp'] as DateTime;
    final timeStr = "${timestamp.day}/${timestamp.month} • ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    final color = isSimple ? Colors.blueAccent : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => isSimple ? _startSimple(game) : _startExtended(game),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isSimple ? Icons.speed_rounded : Icons.grid_view_rounded,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSimple
                              ? "Score: ${game['p1'].score} - ${game['p2'].score}"
                              : "${game['p1'].name} vs ${game['p2'].name}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCardActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    onTap: () => _confirmAndDelete(game['id'], isSimple, game['p1'].name, game['p2'].name),
                  ),
                  const SizedBox(width: 8),
                  _buildCardActionButton(
                    icon: Icons.play_arrow_rounded,
                    color: Colors.greenAccent,
                    onTap: () => isSimple ? _startSimple(game) : _startExtended(game),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _startSimple(Map<String, dynamic>? data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleTrackerScreen(
          gameId: data?['id'],
          initialP1: data?['p1'],
          initialP2: data?['p2'],
          initialSeconds: data?['secondsLeft'],
        ),
      ),
    ).then((_) => _loadGames());
  }

  void _startExtended(Map<String, dynamic>? data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameBoard(
          gameId: data?['id'],
          initialP1: data?['p1'],
          initialP2: data?['p2'],
          initialShared: data?['sharedCards']?.cast<SharedCardModel?>(),
        ),
      ),
    ).then((_) => _loadGames());
  }

  Future<void> _confirmAndDelete(String id, bool simple, String p1, String p2) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete saved game?', style: TextStyle(color: Colors.white)),
        content: Text(
          simple 
            ? 'Are you sure you want to delete this saved game?'
            : 'Are you sure you want to delete the challenge between $p1 and $p2?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await GameStorage.deleteGame(id, simple);
      _loadGames();
    }
  }
}
