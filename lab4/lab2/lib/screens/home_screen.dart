  // ignore_for_file: avoid_print, lines_longer_than_80_chars, use_build_context_synchronously

  import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lab2/models/plant.dart';
import 'package:lab2/models/user.dart';
import 'package:lab2/screens/profile_screen.dart';
import 'package:lab2/services/plant_storage.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

  /// ==================== PROVIDER ====================
  class PlantProvider extends ChangeNotifier {
    final PlantStorage storage;
    final User user;
    List<Plant> _plants = [];
    late MqttServerClient mqttClient;

    bool isConnected = false; // статус MQTT

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
      publishFullDatabase();
    }

    void updatePlant(Plant plant) {
      final index = _plants.indexWhere((p) => p.id == plant.id);
      if (index != -1) _plants[index] = plant;
      storage.savePlants(_plants);
      notifyListeners();
      publishFullDatabase();
    }

    void removePlant(Plant plant) {
      _plants.removeWhere((p) => p.id == plant.id);
      storage.savePlants(_plants);
      notifyListeners();
      publishFullDatabase();
    }

    Future<void> publishFullDatabase() async {
      if (!isConnected) return;

      final topic = 'plants/${user.email}/full';
      final jsonData = jsonEncode(_plants.map((p) => p.toJson()).toList());
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonData);

      mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    
      print('Published full database to $topic');
    }

    /// ==================== MQTT ====================
    Future<void> connectMQTT() async {
      mqttClient = MqttServerClient('broker.hivemq.com', '');
      mqttClient.port = 1883;
      mqttClient.keepAlivePeriod = 20;
      mqttClient.logging(on: false);

      mqttClient.connectionMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          // ignore: deprecated_member_use
          .keepAliveFor(20);

      try {
        await mqttClient.connect();
      } catch (e) {
        print('MQTT connection error: $e');
        isConnected = false;
        return;
      }

      if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
        print('MQTT connected');
        isConnected = true;
        _subscribeToHumidityTopic();
        await publishFullDatabase();
      }
    }

    void _subscribeToHumidityTopic() {
      final topic = 'plants/${user.email}/humidity';
      mqttClient.subscribe(topic, MqttQos.atLeastOnce);

      mqttClient.updates!.listen((event) {
        final MqttPublishMessage msg = event.first.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
        print('Humidity received: $payload');
      });
    }
  }

  /// ==================== HOMESCREEN ====================
class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkInternet();

    // постійна перевірка підключення кожні 5 секунд
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkInternet());
  }

  Future<void> _checkInternet() async {
    bool connected = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      connected = false;
    }

    if (mounted) setState(() => isOnline = connected);

    if (connected) {
      final provider = Provider.of<PlantProvider>(context, listen: false);
      if (!provider.isConnected) {
        provider.connectMQTT();
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Провайдера не створюємо тут – він передається з логіну
    return const HomeScreenContent();
  }
}

  /// ==================== HOME SCREEN CONTENT ====================
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
                      if (image != null) {
                        setDialogState(() => pickedImage = image);
                      }
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
                    final imagePath = pickedImage?.path ?? '';
                    provider.addPlant(Plant(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
              final user = provider.user;
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
                context,
                plant: plant,
                isEditing: true,
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
