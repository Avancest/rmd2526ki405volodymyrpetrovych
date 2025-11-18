import 'dart:convert';

import 'package:lab2/models/plant.dart';
import 'package:lab2/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantStorage {
  final String userId; // email або інший унікальний ідентифікатор

  PlantStorage({required this.userId, required User user});

  String get key => 'plants_$userId';

  Future<void> savePlants(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = plants.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

 Future<List<Plant>> loadPlants() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = prefs.getStringList(key) ?? [];
  return jsonList.map((s) {
    final Map<String, dynamic> map = jsonDecode(s) as Map<String, dynamic>;
    return Plant.fromJson(map);
  }).toList();
}
}
