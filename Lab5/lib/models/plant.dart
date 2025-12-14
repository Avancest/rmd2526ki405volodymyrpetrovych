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

  // =======================================================
  // ВИПРАВЛЕНО: Нормалізація шляху для JSON
  // =======================================================
  Map<String, dynamic> toJson() {
    String cleanImagePath = image;

    // Перевіряємо, чи це не URL (тобто локальний шлях) і чи містить
    // зворотні слеші (\), які викликають помилки у JSON-серіалізації.
    // Замінюємо їх на прямі слеші (/).
    if (!cleanImagePath.startsWith('http') && cleanImagePath.contains('\\')) {
      cleanImagePath = cleanImagePath.replaceAll('\\', '/');
    }

    return {
      'id': id,
      'name': name,
      'image': cleanImagePath, // Використовуємо очищений шлях
      'waterLevel': waterLevel,
    };
  }
  // =======================================================

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id']?.toString() ?? DateTime.now()
    .millisecondsSinceEpoch.toString(),
    name: json['name']?.toString() ?? 'Без назви',
    image: json['image']?.toString() ?? 'assets/images/plant.png',
    waterLevel: (json['waterLevel'] != null)
        ? (json['waterLevel'] as num).toDouble()
        : 0.5, 
  );
// ignore: eol_at_end_of_file
}