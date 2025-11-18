import 'package:flutter/material.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/page_title.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const PageTitle(title: 'Реєстрація'),
              const CustomInput(hint: 'Ім’я'),
              const CustomInput(hint: 'Email'),
              const CustomInput(hint: 'Пароль', obscure: true),
              CustomButton(
                text: 'Зареєструватись',
                onTap: () => Navigator.pushNamed(context, '/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
