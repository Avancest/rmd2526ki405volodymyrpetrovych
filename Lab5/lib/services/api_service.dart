import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:lab2/models/plant.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Plant>> fetchPlants() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    // друк для дебагу
    // ignore: avoid_print
    print('Response code: ${response.statusCode}');
    // ignore: avoid_print
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! List) throw Exception('Unexpected response format');
      
      return data
          .map((item) => Plant.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load plants from API: ${response.statusCode}');
    }
  }
}
