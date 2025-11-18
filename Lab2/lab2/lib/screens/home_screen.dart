import 'package:flutter/material.dart';

class Plant {
  Plant({
    required this.name,
    required this.image,
    required this.waterLevel,
  });

  final String name;
  final String image;
  final double waterLevel; // 0.0–1.0
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Plant> _plants = [
    Plant(name: 'Фікус', image: 'assets/ficus.jpg', waterLevel: 0.8),
    Plant(name: 'Монстера', image: 'assets/monstera.jpg', waterLevel: 0.6),
    Plant(name: 'Кактус', image: 'assets/cactus.jpg', waterLevel: 0.9),
    Plant(name: 'Папороть', image: 'assets/fern.jpg', waterLevel: 0.3),
  ];

  void _showPlantDetails(Plant plant) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plant.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  plant.image,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text('Рівень поливу: ${(plant.waterLevel * 100).toInt()}%'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _plants.remove(plant));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete),
                label: const Text('Видалити'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addPlantDialog() {
    final nameController = TextEditingController();
    double waterLevel = 0.5;
    String? imagePath;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Додати вазонок'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Назва',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Рівень поливу: ${(waterLevel * 100).toInt()}%'),
                    Slider(
                      value: waterLevel,
                      onChanged: (v) => setDialogState(() {
                        waterLevel = v;
                      }),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Тут можна додати вибір фото (image_picker)
                        setDialogState(() {
                          imagePath = 'assets/default_plant.jpg';
                        });
                      },
                      icon: const Icon(Icons.photo),
                      label: const Text('Вибрати фото'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Скасувати'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && imagePath != null) {
                      setState(() {
                        _plants.add(
                          Plant(
                            name: nameController.text,
                            image: imagePath!,
                            waterLevel: waterLevel,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Додати'),
                ),
              ],
            );
          },
        );
      },
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мої вазони 🌿')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: _plants.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final plant = _plants[index];
            return GestureDetector(
              onTap: () => _showPlantDetails(plant),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  // ignore: avoid_redundant_argument_values
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          plant.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            plant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: plant.waterLevel,
                            backgroundColor: Colors.blue.shade100,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(plant.waterLevel * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
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
      // Дві кнопки внизу екрана
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: 'profileBtn',
              backgroundColor: Colors.green,
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Icon(Icons.person),
            ),
            FloatingActionButton(
              heroTag: 'addBtn',
              backgroundColor: Colors.blueAccent,
              onPressed: _addPlantDialog,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
