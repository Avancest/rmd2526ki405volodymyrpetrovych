// ignore_for_file: avoid_print, lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lab2/models/plant.dart';
import 'package:lab2/models/user.dart';
import 'package:lab2/screens/profile_screen.dart';
import 'package:lab2/services/plant_storage.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';


class PlantProvider extends ChangeNotifier {
  final User user;
  final ApiService apiService;
  final PlantStorage storage; 

  List<Plant> _plants = [];
  bool isLoading = false;
  bool needsSave = false;
  bool _isOnline = true; 

  late MqttServerClient mqttClient;
  bool isConnected = false;

  PlantProvider({
    required this.user,
    required this.apiService,
    required this.storage,
  });

  List<Plant> get plants => _plants;
  bool get isOnline => _isOnline; 

  void setOnlineStatus(bool status) {
    if (_isOnline != status) {
      _isOnline = status;
      notifyListeners();
    }
  }

  
  // ================= INITIAL LOAD =================
  Future<void> initialize() async {
    // isLoading = true; <-- ВИДАЛИТИ
    // notifyListeners(); <-- ВИДАЛИТИ

    final connectivity = await Connectivity().checkConnectivity();
    final online = connectivity != ConnectivityResult.none;

    if (online) {
      try {
        _plants = await apiService.fetchPlants();
        await storage.savePlants(_plants);
        needsSave = false;
        setOnlineStatus(true);
        print('Plants loaded from API.');
      } catch (e) {
        print('API error: $e. Loading from local...');
        _plants = await storage.loadPlants();
        setOnlineStatus(false);
      }
    } else {
      print('No internet — loading from local storage');
      _plants = await storage.loadPlants();
      setOnlineStatus(false);
    }

  
}

  void addPlantLocal(Plant plant) {
    _plants.add(plant);
    needsSave = true;
    notifyListeners();
    storage.addPlant(plant); 
  }

  void updatePlantLocal(Plant plant) {
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      _plants[index] = plant;
    }
    needsSave = true;
    notifyListeners();
     storage.updatePlant(plant); 
  }

  void removePlantLocal(Plant plant) {
    _plants.removeWhere((p) => p.id == plant.id);
    needsSave = true;
    notifyListeners();
    storage.removePlant(plant); 
  }

  Future<void> deletePlantAndSync(Plant plant) async {
    _plants.removeWhere((p) => p.id == plant.id);
    notifyListeners(); 
    await storage.removePlant(plant);

    try {
      final isNew = int.tryParse(plant.id) == null;

      if (!isNew) {
        await apiService.deletePlant(plant.id);
      } else {
        print('Local deletion only for temporary plant ID: ${plant.id}');
      }
      publishFullDatabase();

    } catch (e) {
      print('Error during API deletion for plant ${plant.name}: $e');
    }
  }

  // ================= SAVE TO API =================
  Future<void> saveToApi() async {
     if (!isOnline) { 
       print('Offline → saveToApi skipped');
       return;
     }

     final plantsToSync = _plants.toList(); 
     bool changesOccurred = false;
      bool hasErrors = false; 

       for (final plant in plantsToSync) {
       final oldId = plant.id;
       final isNew = int.tryParse(oldId) == null;

       try {
        final updatedPlant = await apiService.saveSinglePlant(plant);

        if (isNew && updatedPlant != null && updatedPlant.id != oldId) {
          print('Local ID $oldId replaced with permanent ID ${updatedPlant.id}');

           final index = _plants.indexWhere((p) => p.id == oldId);
           if (index != -1) {
           _plants[index] = updatedPlant;
            changesOccurred = true;
          }
         }
      } catch (e) {
        print('API save error for plant ${plant.name}: $e');
         hasErrors = true;
     }
     }

     if (changesOccurred || _plants.isEmpty || !hasErrors) { 
      needsSave = hasErrors; 

     
       await storage.savePlants(_plants); 
       notifyListeners();
    }
}

  // ================= RELOAD =================
  Future<void> reloadFromApi() async {
    try {
      _plants = await apiService.fetchPlants();
      needsSave = false;
     
      await storage.savePlants(_plants);
      notifyListeners();
    } catch (e) {
      print('Reload error: $e. Attempting to load from local storage...');
      
      _plants = await storage.loadPlants();
      needsSave = false;
      notifyListeners();
    }
  }

  // ================= MQTT =================
  Future<void> publishFullDatabase() async {
    if (!isConnected) return;

    final topic = 'plants/${user.email}/full';
    final jsonData = jsonEncode(_plants.map((p) => p.toJson()).toList());
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonData);

    mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  Future<void> connectMQTT() async {
    // Створення унікального та валідного Client ID для MQTT.
    final sanitizedEmail = user.email.replaceAll(RegExp(r'[^\w]+'), '_');
    final clientId = 'flutter_plant_app_${sanitizedEmail}_${DateTime.now().millisecondsSinceEpoch}';

    mqttClient = MqttServerClient('broker.hivemq.com', clientId);
    mqttClient.port = 1883;

    try {
  
      await mqttClient.connect();
      isConnected = true;
      print('MQTT Connected with Client ID: $clientId');
      publishFullDatabase();
    } catch (e) {
      print('MQTT Connection failed: $e');
      isConnected = false;
    }
  }
}


// API SERVICE 


class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // ================= GET =================
  Future<List<Plant>> fetchPlants() async {
    final request = await HttpClient().getUrl(Uri.parse(baseUrl));
    final response = await request.close();

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch plants: ${response.statusCode}');
    }

    final body = await response.transform(utf8.decoder).join();
    final data = jsonDecode(body) as List<dynamic>;

    return data.map((e) => Plant.fromJson(e as Map<String, dynamic>)).toList();
  }
  
  

  Future<Plant?> saveSinglePlant(Plant plant) async {
    final client = HttpClient();
    final isNew = int.tryParse(plant.id) == null;

    Uri uri;
    String method;

    if (!isNew) {
      uri = Uri.parse('$baseUrl/${plant.id}');
      method = 'PUT';
    } else {
      uri = Uri.parse(baseUrl); 
      method = 'POST';
    }

    HttpClientRequest req;
    
    try {
      if (method == 'PUT') {
        req = await client.putUrl(uri);
      } else {
        req = await client.postUrl(uri);
      }
      
      req.headers.set('Content-Type', 'application/json; charset=utf-8');
      final encodedJson = utf8.encode(jsonEncode(plant.toJson()));
      req.add(encodedJson);

      print('API Sync: $method $uri (Plant ID: ${plant.id})'); 

      final res = await req.close(); 
      final statusCode = res.statusCode;

      if (statusCode >= 400) {
        final body = await res.transform(utf8.decoder).join();
        print('API $method FAILED ($statusCode) on URL: $uri. Details: $body'); 
        
        //  обробка 404 для PUT
        if (statusCode == 404 && method == 'PUT') {
           throw Exception('Save failed: 404. Resource not found for update (ID: ${plant.id})');
        }
        
        throw Exception('Save failed: $statusCode');
      }

      if (method == 'POST' && statusCode >= 200 && statusCode < 300) {
          final responseBody = await res.transform(utf8.decoder).join();
          final data = jsonDecode(responseBody) as Map<String, dynamic>;
          
          return Plant.fromJson(data); 
      }
      
      return null; 
      
    } catch (e) {
      print('Error syncing plant ${plant.name}: $e');
      rethrow; 
    }
  }

  // ================= SAVE ALL PLANTS (REF ACTORED) =================

  Future<void> savePlants(List<Plant> plants) async {

    for (final plant in plants) {
      await saveSinglePlant(plant);
    }
  }
  // ================= DELETE PLANT =================
  Future<void> deletePlant(String plantId) async {
    final client = HttpClient();
    final uri = Uri.parse('$baseUrl/$plantId');
    
    try {
      final req = await client.deleteUrl(uri);
      
      print('API Sync: DELETE $uri (Plant ID: $plantId)'); 
      
      final res = await req.close();
      final statusCode = res.statusCode;

      if (statusCode >= 400 && statusCode != 404) { 
        final body = await res.transform(utf8.decoder).join();
        print('API DELETE FAILED ($statusCode) on URL: $uri. Details: $body'); 
        throw Exception('Delete failed: $statusCode');
      }

      print('API DELETE successful ($statusCode) for ID: $plantId');

    } catch (e) {
      print('Error during API deletion for plant $plantId: $e');
      rethrow; 
    }
  }
}

// ====================================================================
// HOME SCREEN
// ====================================================================

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({required this.user, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  late PlantProvider provider;
  late PlantStorage _plantStorage;
  // поле для зберігання Future
  late Future<void> _initializationFuture; 

  @override
  void initState() {
    super.initState();

    _plantStorage = PlantStorage(userId: widget.user.email, user: widget.user);

    provider = PlantProvider(
      user: widget.user,
      apiService: ApiService(
        baseUrl: 'https://692eba9991e00bafccd50a3c.mockapi.io/plant/v1/plants',
      ),
      storage: _plantStorage,
    );
    _initializationFuture = provider.initialize(); 

    
    _checkInternet();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkInternet());
  }

  Future<void> _checkInternet() async {
     final result = await Connectivity().checkConnectivity();
    final connected = result != ConnectivityResult.none;

    provider.setOnlineStatus(connected); 

    if (connected && !provider.isConnected) {
       provider.connectMQTT();
    }


    if (connected && provider.needsSave) {
        await provider.saveToApi();
    }
}

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlantProvider>.value(
      value: provider,
      child: FutureBuilder<void>( 
        future: _initializationFuture, 
        builder: (context, snapshot) {
          // Обробка різних станів Future (Loading, Error, Done)
          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Завантаження даних...'),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {

             return Scaffold(
               body: Center(
                 child: Text('Помилка завантаження: ${snapshot.error}'),
               ),
             );
          } else {
            // Стан завершення
            return const HomeScreenContent();
          }
        },
      ),
    );
  }
}

// ====================================================================
// HOME SCREEN CONTENT (UPDATED ID GENERATION)
// ====================================================================

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});


  void _showPlantDialog(BuildContext context,
      {required bool isEditing, Plant? plant}) {
    
    final existingProvider = Provider.of<PlantProvider>(context, listen: false);

    final nameController = TextEditingController(text: plant?.name ?? '');
    double waterLevel = plant?.waterLevel ?? 0.5;

    String? imagePath = plant?.image; 
    // ignore: unused_local_variable
    XFile? pickedImage;

    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider<PlantProvider>.value(
          value: existingProvider,
          child: StatefulBuilder(
            builder: (innerContext, setDialogState) {
              return AlertDialog(
                title: Text(isEditing ? 'Редагувати вазонок' : 'Додати вазонок'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Назва'),
                      ),
                      const SizedBox(height: 10),
                      Text('Рівень поливу: ${(waterLevel * 100).toInt()}%'),
                      Slider(
                        value: waterLevel,
                        onChanged: (v) =>
                            setDialogState(() => waterLevel = v),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image =
                              await picker.pickImage(source: ImageSource.gallery);

                          if (image != null) {
                            pickedImage = image;
                            imagePath = image.path;

                            setDialogState(() {});
                          }
                        },
                        icon: const Icon(Icons.photo),
                        label: const Text('Вибрати фото'),
                      ),
                      if (imagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image(
                            image: imagePath!.startsWith('http')
                                ? NetworkImage(imagePath!)
                                : (File(imagePath!).existsSync()
                                        ? FileImage(File(imagePath!))
                                        : const AssetImage('assets/plant.png'))
                                    as ImageProvider,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        )
                    ],
                  ),
                ),
                actions: [
                  if (isEditing) 
                    Consumer<PlantProvider>(
                      builder: (_, p, __) => IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () {
                          // Викликаємо функцію видалення
                          p.deletePlantAndSync(plant!); 
                          Navigator.pop(innerContext);
                        },
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: existingProvider.reloadFromApi, 
                  ),
                  Consumer<PlantProvider>(
builder: (_, p, __) => IconButton(
 icon: Icon(Icons.save,
color: p.needsSave ? Colors.yellow : Colors.white),
 onPressed: () {
final newPlant = Plant(
    id: isEditing
  ? plant!.id
    : 'temp_${DateTime.now()
     .millisecondsSinceEpoch}',
     name: nameController.text,
     image: imagePath ?? 'assets/plant.png',
     waterLevel: waterLevel,
   );

if (isEditing) {
p.updatePlantLocal(newPlant);
 } else {
 p.addPlantLocal(newPlant);
 }

 if (p.isOnline) {
p.saveToApi();
} else {

 ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(
content: Text('Збережено локально. Синхронізація відбудеться автоматично.'),
 duration: Duration(seconds: 2),
 ),
);
 }

Navigator.pop(innerContext);
 },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildPlantImage(Plant plant) {
    final img = plant.image;

    if (img.startsWith('http')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/plant.png', fit: BoxFit.cover),
      );
    }

    if (File(img).existsSync()) {
      return Image.file(
        File(img),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return Image.asset(
      'assets/plant.png',
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }


@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final crossAxisCount =
      screenWidth > 600 ? 3 : screenWidth > 400 ? 2 : 1;

  final provider = Provider.of<PlantProvider>(context);

  final isOnline = provider.isOnline;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Мої вазони 🌿'),
      actions: [

        if (provider.needsSave && isOnline) 
          const Padding(
            // ignore: prefer_int_literals
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.sync_problem, color: Colors.yellow),
          ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              // ignore: inference_failure_on_instance_creation
              MaterialPageRoute(
                builder: (_) => ProfileScreen(user: provider.user),
              ),
            );
          },
        ),
      ],
    ),

    body: Column(
      children: [
        if (!isOnline)
          Container(
            // ignore: prefer_int_literals
            padding: const EdgeInsets.all(8.0),
            color: Colors.red.shade700,
            width: double.infinity,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Немає Інтернету. Локальний режим.',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        

        Expanded(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: GridView.builder(
              itemCount: provider.plants.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: screenWidth * 0.03,
                      mainAxisSpacing: screenWidth * 0.03,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, i) {
                      final plant = provider.plants[i];
                      return GestureDetector(
                        onTap: () => _showPlantDialog(
                          context,
                          plant: plant,
                          isEditing: true,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                          elevation: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                          screenWidth * 0.02)),
                                  child: _buildPlantImage(plant),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: Column(
                                  children: [
                                    Text(
                                      plant.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.045),
                                    ),
                                    SizedBox(height: screenWidth * 0.015),
                                    LinearProgressIndicator(
                                      value: plant.waterLevel,
                                      backgroundColor: Colors.blue.shade100,
                                      minHeight: screenWidth * 0.02,
                                    ),
                                    SizedBox(height: screenWidth * 0.01),
                                    Text(
                                      '${(plant.waterLevel * 100).toInt()}%',
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.035),
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
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () =>
          _showPlantDialog(context, isEditing: false),
      child: const Icon(Icons.add),
    ),
  );
}
// ignore: eol_at_end_of_file
}