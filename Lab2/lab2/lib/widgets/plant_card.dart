import 'package:flutter/material.dart';

class PlantCard extends StatelessWidget {
  final String name;
  final String status;
  final String image;
  final double waterLevel; // значення 0.0–1.0

  const PlantCard({
    super.key,
    required this.name,
    required this.status,
    required this.image,
    required this.waterLevel,
  });

  Color getWaterColor() {
    if (waterLevel < 0.3) {
      return Colors.redAccent;
    } else if (waterLevel < 0.7) {
      return Colors.amber;
    } else {
      return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFE8F5E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Фото вазона
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                // Рівень поливу
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double barWidth =
                        constraints.maxWidth * waterLevel.clamp(0, 1);
                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        ColoredBox(
                          color: Colors.grey[300]!,
                          child: SizedBox(
                            height: 10,
                            width: constraints.maxWidth,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          height: 10,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: getWaterColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  '${(waterLevel * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
