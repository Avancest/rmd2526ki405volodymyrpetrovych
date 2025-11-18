import 'package:flutter/material.dart';
import 'package:lab2/screens/home_screen.dart';
import 'package:lab2/services/auth_controller.dart';
import 'package:lab2/services/local_user_storage.dart';
import 'package:lab2/widgets/custom_button.dart';
import 'package:lab2/widgets/custom_input.dart';
import 'package:lab2/widgets/page_title.dart';

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
    final err = await auth.login(
      _email.text.trim(),
      _password.text.trim(),
    );
    if (err == null) {
      final user = await auth.getCurrentUser(); // отримуємо name і email
      if (user != null) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          // ignore: inference_failure_on_instance_creation
          MaterialPageRoute(
            builder: (_) => HomeScreen(user: user),
          ),
        );
      }
          
    }
  },
  ),
              ),

              SizedBox(height: screenHeight * 0.02),

              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/register'),
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
