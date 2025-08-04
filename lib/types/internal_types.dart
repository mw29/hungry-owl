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
