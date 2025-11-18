import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lab2/models/plant.dart';
import 'package:lab2/models/user.dart';
import 'package:lab2/screens/profile_screen.dart';
import 'package:lab2/services/plant_storage.dart';
import 'package:provider/provider.dart';

// ==================== PROVIDER ====================
class PlantProvider extends ChangeNotifier {
  final PlantStorage storage;
  final User user;
  List<Plant> _plants = [];

  PlantProvider({required this.storage, required this.user}) {
    loadPlants();
  }

  List<Plant> get plants => _plants;

  Future<void> loadPlants() async {
    _plants = await storage.loadPlants();
    notifyListeners();
  }

  void addPlant(Plant plant) {
    _plants.add(plant);
    storage.savePlants(_plants);
    notifyListeners();
  }

  void updatePlant(Plant plant) {
    storage.savePlants(_plants);
    notifyListeners();
  }

  void removePlant(Plant plant) {
    _plants.remove(plant);
    storage.savePlants(_plants);
    notifyListeners();
  }
}

// ==================== HOMESCREEN ====================
class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlantProvider(
        storage: PlantStorage(user: user, userId: ''),
        user: user,
      ),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  void _showPlantDialog(BuildContext context,
      {required bool isEditing, Plant? plant}) {
    final provider = Provider.of<PlantProvider>(context, listen: false);
    final nameController = TextEditingController(text: plant?.name ?? '');
    double waterLevel = plant?.waterLevel ?? 0.5;
    XFile? pickedImage;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          final screenWidth = MediaQuery.of(context).size.width;
          return AlertDialog(
            title: Text(isEditing ? 'Редагувати вазонок' : 'Додати вазонок'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Назва'),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                      'Рівень поливу: ${(waterLevel * 100).toInt()}%',
                      style: TextStyle(fontSize: screenWidth * 0.045)),
                  Slider(
                    value: waterLevel,
                    onChanged: (v) => setDialogState(() => waterLevel = v),
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                          source: ImageSource.gallery);
                      if (image != null)
                        // ignore: curly_braces_in_flow_control_structures
                        setDialogState(() => pickedImage = image);
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Вибрати фото'),
                  ),
                  if (pickedImage != null)
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.03),
                      child: Image.file(
                        File(pickedImage!.path),
                        width: screenWidth * 0.4,
                        height: screenWidth * 0.4,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Скасувати')),
              if (isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: () {
                    if (plant != null) provider.removePlant(plant);
                    Navigator.pop(context);
                  },
                  child: const Text('Видалити'),
                ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty) return;
                  if (isEditing && plant != null) {
                    plant.name = nameController.text;
                    plant.waterLevel = waterLevel;
                    if (pickedImage != null) plant.image = pickedImage!.path;
                    provider.updatePlant(plant);
                  } else if (!isEditing) {
                    final imagePath = pickedImage?.path ?? 'assets/plant.png';
                    provider.addPlant(Plant(
                      name: nameController.text,
                      waterLevel: waterLevel,
                      image: imagePath,
                    ));
                  }
                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'Зберегти' : 'Додати'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth > 600 ? 3 : screenWidth > 400 ? 2 : 1;
    final provider = Provider.of<PlantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мої вазони 🌿'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final user = Provider.of<PlantProvider>
              (context, listen: false).user;
              Navigator.push(
                context,
                // ignore: inference_failure_on_instance_creation
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: user),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: GridView.builder(
          itemCount: provider.plants.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: screenWidth * 0.03,
            mainAxisSpacing: screenWidth * 0.03,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final plant = provider.plants[index];
            return GestureDetector(
              onTap: () => _showPlantDialog(
              context, plant: plant, isEditing: true
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02)),
                elevation: 4,
                child: Column(
                  children: [
                    Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(screenWidth * 0.02)),
                          child: plant.image.isNotEmpty
                              ? Image.file(
                                  File(plant.image),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Image.asset(
                                  'assets/plant.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: Column(
                        children: [
                          Text(plant.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.045)),
                          SizedBox(height: screenWidth * 0.015),
                          LinearProgressIndicator(
                            value: plant.waterLevel,
                            backgroundColor: Colors.blue.shade100,
                            color: Colors.blue.shade400,
                            minHeight: screenWidth * 0.02,
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Text('${(plant.waterLevel * 100).toInt()}%',
                              style: TextStyle(fontSize: screenWidth * 0.035)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlantDialog(context, isEditing: false),
        child: const Icon(Icons.add),
      ),
    );
  }
}
