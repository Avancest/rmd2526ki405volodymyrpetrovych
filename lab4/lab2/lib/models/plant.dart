class Plant {
  String id;
  String name;
  String image;
  double waterLevel;

  Plant({
    required this.id,
    required this.name,
    required this.image,
    required this.waterLevel,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'waterLevel': waterLevel,
  };

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'] as String,
    name: json['name'] as String,
    image: json['image'] as String,
    waterLevel: (json['waterLevel'] as num).toDouble(),
  );
}
