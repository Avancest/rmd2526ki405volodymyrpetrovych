// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    print('Lookup result: $result');
  } catch (e) {
    print('Error: $e');
  }
}
