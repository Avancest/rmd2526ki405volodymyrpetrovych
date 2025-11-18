// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/main.dart'; // змінити шлях, якщо назва проєкту інша

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Створюємо і рендеримо наш застосунок
    await tester.pumpWidget(const AutoWateringApp());

    // Перевіримо, що на екрані є заголовок або елемент із текстом
    expect(find.text('Вхід'), findsOneWidget);
  });
}
