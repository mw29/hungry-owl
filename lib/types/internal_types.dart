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

  User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    required this.anonId,
    required this.version,
    required this.symptoms,
    required this.onboarded,
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
    };
  }
}

class SymptomCorrelation {
  final String symptom;
  final List<String> potentialCorrelations;

  SymptomCorrelation({
    required this.symptom,
    required this.potentialCorrelations,
  });

  factory SymptomCorrelation.fromJson(Map<String, dynamic> json) {
    final raw = json['potentialCorrelation'];
    return SymptomCorrelation(
      symptom: json['symptom'],
      potentialCorrelations: raw is List
          ? List<String>.from(raw)
          : raw is String
              ? [raw]
              : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'symptom': symptom,
        'potentialCorrelation': potentialCorrelations,
      };
}

class FoodCorrelationResponse {
  final String foodName;
  final List<SymptomCorrelation> symptoms;

  FoodCorrelationResponse({
    required this.foodName,
    required this.symptoms,
  });

  factory FoodCorrelationResponse.fromJson(Map<String, dynamic> json) {
    return FoodCorrelationResponse(
      foodName: json['foodName'],
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((item) => SymptomCorrelation.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'symptoms': symptoms.map((s) => s.toJson()).toList(),
      };
}
