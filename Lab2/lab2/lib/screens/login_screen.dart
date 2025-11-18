import 'package:flutter/material.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/page_title.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PageTitle(title: 'Вхід'),
              const SizedBox(height: 20),
              const CustomInput(hint: 'Email'),
              const SizedBox(height: 12),
              const CustomInput(hint: 'Пароль', obscure: true),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Увійти',
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Створити акаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
