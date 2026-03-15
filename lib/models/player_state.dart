import 'card_model.dart';

class PlayerState {
  String name;
  int chakra = 0;
  int score = 0;
  List<List<CardModel>> columns = List.generate(4, (_) => []);
  List<int?> simpleColumns = [null, null, null, null];
  PlayerState({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
        'chakra': chakra,
        'score': score,
        'columns': columns
            .map((col) => col.map((card) => card.toJson()).toList())
            .toList(),
        'simpleColumns': simpleColumns,
      };

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    final state = PlayerState(name: json['name'] ?? "");
    state.chakra = json['chakra'] ?? 0;
    state.score = json['score'] ?? 0;
    if (json['columns'] != null) {
      state.columns = (json['columns'] as List).map((col) {
        return (col as List).map((card) => CardModel.fromJson(card)).toList();
      }).toList();
    }
    if (json['simpleColumns'] != null) {
      state.simpleColumns = (json['simpleColumns'] as List).cast<int?>();
    }
    return state;
  }
}
