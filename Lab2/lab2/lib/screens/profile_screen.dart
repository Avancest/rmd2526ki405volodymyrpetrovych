import 'package:flutter/material.dart';
import 'package:lab2/widgets/page_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const PageTitle(title: 'Петрович 🌱'),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('user@example.com'),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Налаштування'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (r) => false),
              child: const Text('Вийти'),
            ),
          ],
        ),
      ),
    );
  }
}
