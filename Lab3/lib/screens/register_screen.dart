import 'package:flutter/material.dart';
import 'package:lab2/services/auth_controller.dart';
import 'package:lab2/services/local_user_storage.dart';
import 'package:lab2/widgets/custom_button.dart';
import 'package:lab2/widgets/custom_input.dart';
import 'package:lab2/widgets/page_title.dart';
import 'package:lab2/models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
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
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: screenWidth * 0.07),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  PageTitle(
                    title: 'Реєстрація',
                    fontSize: screenWidth * 0.08,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              CustomInput(hint: 'Імʼя', controller: _name),
              SizedBox(height: screenHeight * 0.02),

              CustomInput(hint: 'Email', controller: _email),
              SizedBox(height: screenHeight * 0.02),

              CustomInput(hint: 'Пароль', obscure: true, controller: _password),
              SizedBox(height: screenHeight * 0.03),

              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),

              SizedBox(
                height: screenHeight * 0.065,
                child: CustomButton(
                  text: 'Зареєструватись',
                  onTap: () async {
                    final err = await auth.register(
                      _name.text,
                      _email.text,
                      _password.text,
                    );

                   if (err != null) {
                      setState(() => errorMessage = err);
                    } else {
                      // Припустимо, ви можете отримати створеного користувача з auth
                      final currentUser = User(name: _name.text, email: _email.text); 
                      
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(
                        context, 
                        '/home', 
                        arguments: currentUser, // <-- Передаємо об'єкт User
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
