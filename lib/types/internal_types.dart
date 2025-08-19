class FoodIdResponseData {
  String name;
  String? time;
  String? notes;

  FoodIdResponseData({
    required this.name,
    this.time,
    this.notes,
  });

  factory FoodIdResponseData.fromJson(Map<String, dynamic> json) {
    return FoodIdResponseData(
        name: json['name'], time: json['time'], notes: json['notes']);
  }
}

class Document {
  final String id;
  final int createdAt;
  final int updatedAt;
  int? deletedAt;

  Document({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

class User extends Document {
  final String anonId;
  final int version;
  final List<String> symptoms;
  final bool onboarded;
  final bool leftReview;

  User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required this.anonId,
    required this.version,
    required this.symptoms,
    required this.onboarded,
    required this.leftReview,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'anonId': anonId,
      'version': version,
      'symptoms': symptoms,
      'onboarded': onboarded,
      'leftReview': leftReview,
    };
  }
}

class SymptomInfo {
  final String symptomName;
  final int symptomRiskScore;
  final List<String> information;

  SymptomInfo({
    required this.symptomName,
    required this.symptomRiskScore,
    required this.information,
  });

  factory SymptomInfo.fromJson(Map<String, dynamic> json) {
    return SymptomInfo(
        symptomName: json['symptomName'],
        symptomRiskScore: json['symptomRiskScore'],
        information: List<String>.from(json['information']));
  }

  Map<String, dynamic> toJson() => {
        'symptomName': symptomName,
        'symptomRiskScore': symptomRiskScore,
        'information': information,
      };
}

class IngredientInfo {
  final String ingredientName;
  final String emoji;
  final List<SymptomInfo> relatedSymptoms;

  IngredientInfo(
      {required this.ingredientName,
      required this.emoji,
      required this.relatedSymptoms});

  factory IngredientInfo.fromJson(Map<String, dynamic> json) {
    return IngredientInfo(
        ingredientName: json['ingredientName'],
        emoji: json['emoji'],
        relatedSymptoms: (json['relatedSymptoms'] as List<dynamic>)
            .map((item) => SymptomInfo.fromJson(item))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'ingredientName': ingredientName,
        'emoji': emoji,
        'relatedSymptoms': relatedSymptoms.map((r) => r.toJson()).toList(),
      };
}

class FoodSymptomInfo {
  final String foodName;
  final String foodEmoji;
  final int overallRiskScore;
  final String overview;
  final List<IngredientInfo> relevantIngredients;

  FoodSymptomInfo({
    required this.foodName,
    required this.foodEmoji,
    required this.overallRiskScore,
    required this.overview,
    required this.relevantIngredients,
  });

  factory FoodSymptomInfo.fromJson(Map<String, dynamic> json) {
    return FoodSymptomInfo(
      foodName: json['foodName'],
      foodEmoji: json['foodEmoji'],
      overallRiskScore: json['overallRiskScore'],
      overview: json['overview'],
      relevantIngredients: (json['relevantIngredients'] as List<dynamic>)
          .map((item) => IngredientInfo.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'foodEmoji': foodEmoji,
        'overallRiskScore': overallRiskScore,
        'overview': overview,
        'relevantIngredients':
            relevantIngredients.map((i) => i.toJson()).toList(),
      };
}
