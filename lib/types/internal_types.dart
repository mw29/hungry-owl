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
      'symptoms': symptoms, // this might also need to be handled differently
      'onboarded': onboarded,
    };
  }
}
