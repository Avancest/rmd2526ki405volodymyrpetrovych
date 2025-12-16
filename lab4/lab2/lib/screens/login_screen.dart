// ignore_for_file: use_build_context_synchronously

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

    
    _checkInternet();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = isOnline;
      isOnline = result != ConnectivityResult.none;

      if (!isOnline && wasOnline) {
        // Втрачено Інтернет
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
      if (!isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Немає підключення до Інтернету.'),
          ),
        );
        return;
      }

      final err = await auth.login(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (err == null) {
        final user = await auth.getCurrentUser();
        if (user != null) {
          // Створюємо провайдера і відкриваємо HomeScreen
          Navigator.pushReplacement(
            context,
            // ignore: inference_failure_on_instance_creation
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => PlantProvider(
                  storage: PlantStorage(user: user, userId: user.email),
                  user: user,
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
