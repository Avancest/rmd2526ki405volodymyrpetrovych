import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lab2/models/plant.dart';
import 'package:lab2/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantStorage extends ChangeNotifier {
  final String userId;

  PlantStorage({required this.userId, required User user}) {
    loadPlants();
  }

  List<Plant> _plants = [];
  List<Plant> get plants => _plants;

  String get key => 'plants_$userId';

  // Завантаження рослин
  Future<List<Plant>> loadPlants() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = prefs.getStringList(key) ?? [];
    _plants = jsonList
    .map((s) => Plant.fromJson(jsonDecode(s) as Map<String, dynamic>))
    .toList();
  notifyListeners();
  return _plants;
}

  // Збереження рослин
  Future<void> savePlants(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _plants.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  // Додавання рослини
  Future<void> addPlant(Plant plant) async {
    _plants.add(plant);
    await savePlants(_plants);
    notifyListeners();
  }

  // Оновлення існуючої рослини
  Future<void> updatePlant(Plant plant) async {
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      _plants[index] = plant;
      await savePlants(_plants);
      notifyListeners();
    }
  }

  // Видалення рослини
  Future<void> removePlant(Plant plant) async {
    _plants.removeWhere((p) => p.id == plant.id);
    await savePlants(_plants);
    notifyListeners();
  }

  // Оновлення вологості з MQTT
  void updateHumidity(String plantId, double humidity) {
  final plant = _plants.firstWhere(
    (p) => p.id == plantId,
    orElse: () => Plant(name: '', image: '', waterLevel: 0, id: ''),
  );
  if (plant.id.isEmpty) return;

  plant.waterLevel = humidity;
  savePlants(_plants);
  notifyListeners();
  // ignore: avoid_print
  print('$plantId - waterLevel updated: ${plant.waterLevel}');
}

}
