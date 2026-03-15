class SharedCardModel {
  int score;
  SharedCardModel({this.score = 0});

  Map<String, dynamic> toJson() => {'score': score};
  factory SharedCardModel.fromJson(Map<String, dynamic> json) =>
      SharedCardModel(score: json['score'] ?? 0);
}

class CardModel {
  String name;
  int power;
  int cost;
  bool isFacedown;
  bool isCollapsed;
  CardModel({
    this.name = "",
    this.power = 0,
    this.cost = 0,
    this.isFacedown = false,
    this.isCollapsed = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'power': power,
        'cost': cost,
        'isFacedown': isFacedown,
        'isCollapsed': isCollapsed,
      };

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        name: json['name'] ?? "",
        power: json['power'] ?? 0,
        cost: json['cost'] ?? 0,
        isFacedown: json['isFacedown'] ?? false,
        isCollapsed: json['isCollapsed'] ?? false,
      );
}
