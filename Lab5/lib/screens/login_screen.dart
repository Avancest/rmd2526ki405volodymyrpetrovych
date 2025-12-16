import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lab2/screens/home_screen.dart';
import 'package:lab2/services/auth_controller.dart';
import 'package:lab2/services/local_user_storage.dart';
import 'package:lab2/services/plant_storage.dart';
import 'package:lab2/widgets/custom_button.dart';
import 'package:lab2/widgets/custom_input.dart';
import 'package:lab2/widgets/page_title.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  final AuthController auth = AuthController(
    storage: LocalUserStorage(),
  );

  String? errorMessage;
  bool isOnline = true;
  late StreamSubscription<ConnectivityResult> _connectivitySub;

  @override
  void initState() {
    super.initState();

    // Перевірка Інтернету під час запуску
    _checkInternet();

    // Підписка на зміни підключення
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = isOnline;
      isOnline = result != ConnectivityResult.none;

      if (!isOnline && wasOnline) {
        // Втрачено Інтернет
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Втрачено підключення до Інтернету'),
          ),
        );
      }
    });
  }

  Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _connectivitySub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: ListView(
            children: [
              PageTitle(
                title: 'Вхід',
                fontSize: screenWidth * 0.08,
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomInput(
                hint: 'Email',
                controller: _email,
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomInput(
                hint: 'Пароль',
                obscure: true,
                controller: _password,
              ),
              SizedBox(height: screenHeight * 0.03),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              SizedBox(height: screenHeight * 0.03),
SizedBox(
  height: screenHeight * 0.065,
  child: CustomButton(
    text: 'Увійти',
    onTap: () async {
      // 1. Отримуємо Email та Пароль
      final email = _email.text.trim();
      final password = _password.text.trim();
      
      String? err;
      

      if (isOnline) {

        err = await auth.login(email, password);
      } else {

        final localUser = await auth.loginLocal(email, password);
        if (localUser == null) {
          // ignore: lines_longer_than_80_chars
          err = 'Немає Інтернету. Локальний вхід неможливий: перевірте облікові дані або увійдіть онлайн.';
        }

      }

      if (err == null) {

        final user = await auth.getCurrentUser();
        if (user != null) {

          final plantStorage = PlantStorage(userId: user.email, user: user);
          

          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            // ignore: inference_failure_on_instance_creation
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => PlantProvider(
                  user: user,
                  apiService: ApiService(
                    baseUrl: 'https://692eba9991e00bafccd50a3c.mockapi.io/plant/v1/plants',
                  ),
                  storage: plantStorage,
                ),
                child: HomeScreen(user: user),
              ),
            ),
          );
          
        }
      } else {

        setState(() {
          errorMessage = err;
        });
      }
    },
  ),
),

              SizedBox(height: screenHeight * 0.02),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  'Створити акаунт',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
