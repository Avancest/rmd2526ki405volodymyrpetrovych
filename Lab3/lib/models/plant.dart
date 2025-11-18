class Plant {
  Plant({
    required this.name,
    required this.image,
    required this.waterLevel,
  });

  String name;
  String image;
  double waterLevel;

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'waterLevel': waterLevel,
      };

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    name: json['name'] as String,
    image: json['image'] as String,
    waterLevel: (json['waterLevel'] as num).toDouble(),
  );

}
