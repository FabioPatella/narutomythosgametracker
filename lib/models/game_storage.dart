import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_state.dart';
import '../models/card_model.dart';

class GameStorage {
  static const String _extendedGamesKey = 'extended_games_list';
  static const String _simpleGamesKey = 'simple_games_list';

  // --- EXTENDED GAMES ---

  static Future<String> saveExtendedGame({
    String? id,
    required PlayerState p1,
    required PlayerState p2,
    required List<SharedCardModel?> sharedCards,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadRawList(_extendedGamesKey);
    
    final newId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final gameData = {
      'id': newId,
      'p1': p1.toJson(),
      'p2': p2.toJson(),
      'sharedCards': sharedCards.map((c) => c?.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    final index = list.indexWhere((g) => g['id'] == newId);
    if (index != -1) {
      list[index] = gameData;
    } else {
      list.insert(0, gameData);
    }

    await prefs.setString(_extendedGamesKey, jsonEncode(list));
    return newId;
  }

  static Future<List<Map<String, dynamic>>> loadExtendedGames() async {
    final list = await _loadRawList(_extendedGamesKey);
    return list.map((data) => {
      'id': data['id'],
      'p1': PlayerState.fromJson(data['p1']),
      'p2': PlayerState.fromJson(data['p2']),
      'sharedCards': (data['sharedCards'] as List).map((c) {
        return c != null ? SharedCardModel.fromJson(c) : null;
      }).toList(),
      'timestamp': DateTime.parse(data['timestamp']),
    }).toList();
  }

  // --- SIMPLE GAMES ---

  static Future<String> saveSimpleGame({
    String? id,
    required PlayerState p1,
    required PlayerState p2,
    required int secondsLeft,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadRawList(_simpleGamesKey);

    final newId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final gameData = {
      'id': newId,
      'p1': p1.toJson(),
      'p2': p2.toJson(),
      'secondsLeft': secondsLeft,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final index = list.indexWhere((g) => g['id'] == newId);
    if (index != -1) {
      list[index] = gameData;
    } else {
      list.insert(0, gameData);
    }

    await prefs.setString(_simpleGamesKey, jsonEncode(list));
    return newId;
  }

  static Future<List<Map<String, dynamic>>> loadSimpleGames() async {
    final list = await _loadRawList(_simpleGamesKey);
    return list.map((data) => {
      'id': data['id'],
      'p1': PlayerState.fromJson(data['p1']),
      'p2': PlayerState.fromJson(data['p2']),
      'secondsLeft': data['secondsLeft'] ?? 3000,
      'timestamp': DateTime.parse(data['timestamp']),
    }).toList();
  }

  // --- HELPERS ---

  static Future<List<dynamic>> _loadRawList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final stringData = prefs.getString(key);
    if (stringData == null) return [];
    try {
      return jsonDecode(stringData) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteGame(String id, bool simple) async {
    final key = simple ? _simpleGamesKey : _extendedGamesKey;
    final prefs = await SharedPreferences.getInstance();
    final list = await _loadRawList(key);
    list.removeWhere((g) => g['id'] == id);
    await prefs.setString(key, jsonEncode(list));
  }
}
