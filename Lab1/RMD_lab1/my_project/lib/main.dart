// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: MoodCircleApp()));
}

class MoodCircleApp extends StatefulWidget {
  const MoodCircleApp({super.key});

  @override
  State<MoodCircleApp> createState() => _MoodCircleAppState();
}

class _MoodCircleAppState extends State<MoodCircleApp>
    with TickerProviderStateMixin {
  double _radius = 80;
  Color _color = Colors.blue;
  Color _bgColor = Colors.black;

  String _appBarTitle = '🌈 Mood Circle Playground';
  Color _appBarColor = Colors.deepPurple;

  Timer? _effectTimer;
  Timer? _symbolTimer;
  final Random _random = Random();
  final TextEditingController _controller = TextEditingController();

  final List<_FallingSymbol> _symbols = [];
  List<String> _currentSymbols = ['⋆'];

  void _onInput(String value) {
    _effectTimer?.cancel();
    _symbolTimer?.cancel();

    setState(() {
      switch (value.toLowerCase()) {
        case 'fire':
          _appBarTitle = '🔥 Fire Mood';
          _appBarColor = Colors.red.shade700;
          _currentSymbols = ['⋆', '✦', '✧', '🔥'];
          _startFireEffect();
          break;
        case 'aqua':
          _appBarTitle = '💧 Aqua Mood';
          _appBarColor = Colors.cyan.shade700;
          _currentSymbols = ['💧', '❈', '🫧', '•'];
          _startAquaEffect();
          break;
        case 'calm':
          _appBarTitle = '☁️ Calm Mood';
          _appBarColor = Colors.lightBlue.shade700;
          _currentSymbols = ['~', '⋯', '☁️', '˘'];
          _startCalmEffect();
          break;
        case 'storm':
          _appBarTitle = '⚡ Storm Mood';
          _appBarColor = Colors.grey.shade800;
          _currentSymbols = ['⚡', '/', '\\', '—'];
          _startStormEffect();
          break;
        case 'party':
          _appBarTitle = '🎉 Party Mood';
          _appBarColor = Colors.purple.shade700;
          _currentSymbols = ['✦', '❉', '⭐', '🎈'];
          _startPartyEffect();
          break;
        case 'sleep':
          _appBarTitle = '🌙 Sleep Mood';
          _appBarColor = Colors.indigo.shade900;
          _currentSymbols = ['⋆', '⁕', '✩', '🌙'];
          _startSleepEffect();
          break;
        case 'random':
          const effects = ['fire', 'aqua', 'calm', 'storm', 'party', 'sleep'];
          _onInput(effects[_random.nextInt(effects.length)]);
          return;
        default:
          final numValue = double.tryParse(value);
          if (numValue != null) {
            _radius = 30 + numValue.clamp(0, 200);
            _color = Colors.blueAccent;
            _bgColor = Colors.black;
            _appBarTitle = '🌈 Mood Circle Playground';
            _appBarColor = Colors.deepPurple;
            _currentSymbols = ['⋆'];
          } else {
            _color = Colors.grey;
            _bgColor = Colors.black;
            _appBarTitle = '🌈 Mood Circle Playground';
            _appBarColor = Colors.deepPurple;
          }
      }
    });

    _startSymbolRain();
  }

  void _startSymbolRain() {
    if (_controller.text.isEmpty) return;

    _symbolTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (_controller.text.isEmpty) return;

      final symbol = _currentSymbols[_random.nextInt(_currentSymbols.length)];
      final left = _random.nextDouble() * 350;
      final size = 14 + _random.nextDouble() * 26;
      final opacity = 0.3 + _random.nextDouble() * 0.5;
      final phase = _random.nextDouble() * 2 * pi;

      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 4000 + _random.nextInt(4000)),
      );

      final fallingSymbol = _FallingSymbol(
        symbol: symbol,
        left: left,
        size: size,
        opacity: opacity,
        color: _color.withOpacity(0.7),
        controller: controller,
        phase: phase,
      );

      controller.forward();

      setState(() {
        _symbols.add(fallingSymbol);
      });

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.dispose();
          setState(() {
            _symbols.remove(fallingSymbol);
          });
        }
      });
    });
  }

  // === ЕФЕКТИ ===
  void _startFireEffect() {
    _effectTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      setState(() {
        _color = Color.lerp(Colors.red, Colors.orange, _random.nextDouble())!;
        _radius = 80 + _random.nextDouble() * 20;
        _bgColor = Colors.black;
      });
    });
  }

  void _startAquaEffect() {
    _effectTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _color = Color.lerp(
          Colors.cyanAccent,
          Colors.blueAccent,
          sin(DateTime.now().millisecond / 1000 * pi).abs(),
        )!;
        _bgColor = Colors.blueGrey.shade900;
        _radius = 70 + 20 * sin(DateTime.now().second / 2);
      });
    });
  }

  void _startCalmEffect() {
    _effectTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      setState(() {
        _color = Colors.lightBlueAccent;
        _bgColor = Colors.blueGrey.shade800;
        _radius = 80 + 10 * sin(DateTime.now().millisecond / 200);
      });
    });
  }

  void _startStormEffect() {
    _effectTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _color = Colors.grey.shade400;
        _bgColor = _random.nextBool() ? Colors.black : Colors.blueGrey.shade700;
        _radius = 70 + _random.nextDouble() * 20;
      });
    });
  }

  void _startPartyEffect() {
    _effectTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      setState(() {
        _color = Color.fromARGB(
          255,
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        );
        _radius = 60 + _random.nextDouble() * 60;
      });
    });
  }

  void _startSleepEffect() {
    _effectTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      setState(() {
        _color = Colors.blueGrey.shade900;
        _bgColor = Colors.black;
        _radius = max(0, _radius - 5);
      });
    });
  }

  @override
  void dispose() {
    _effectTimer?.cancel();
    _symbolTimer?.cancel();
    for (var s in _symbols) {
      s.controller.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: _appBarColor,
      ),
      body: Stack(
        children: [
          // падаючі символи
          ..._symbols.map((s) => s.buildWidget(context)),

          // центроване коло
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _radius * 2,
              height: _radius * 2,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _color.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // текстове поле
          Positioned(
            bottom: 50,
            left: 25,
            right: 25,
            child: TextField(
              controller: _controller,
              onChanged: _onInput,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                hintText: 'Введи: fire, aqua, calm, storm, party, sleep...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallingSymbol {
  final String symbol;
  final double left;
  final double size;
  final double opacity;
  final Color color;
  final AnimationController controller;
  final double phase;

  _FallingSymbol({
    required this.symbol,
    required this.left,
    required this.size,
    required this.opacity,
    required this.color,
    required this.controller,
    required this.phase,
  });

  Widget buildWidget(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;
        final verticalPosition = value * (screenHeight + 50) - 50;
        final horizontalShift = sin(verticalPosition / 80 + phase) * 10;

        return Positioned(
          top: verticalPosition,
          left: left + horizontalShift,
          child: Opacity(
            opacity: opacity,
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: size,
                color: color.withOpacity(opacity),
              ),
            ),
          ),
        );
      },
    );
  }
}
