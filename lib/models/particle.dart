import 'dart:math';

import 'package:flutter/material.dart';
class Particle {
  double x, y;
  double size;
  double speedX, speedY;
  late Color color;
  bool isDarkMode;

  Particle(this.isDarkMode)
    : x = Random().nextDouble(),
      y = Random().nextDouble(),
      size = Random().nextDouble() * 5 + 2,
      speedX = Random().nextDouble() * 0.1 - 0.05, // velocidad más lenta
      speedY = Random().nextDouble() * 0.1 - 0.05 {
    // velocidad más lenta
    _updateColor();
  }

  void _updateColor() {
    final random = Random();
    if (isDarkMode) {
      // Colores suaves y elegantes para modo oscuro
      final colors = [
        Colors.grey.shade700,
        Colors.blueGrey.shade600,
        Colors.indigo.shade400,
        Colors.teal.shade400,
        Colors.deepPurple.shade400,
        Colors.blue.shade300,
      ];
      color = colors[random.nextInt(colors.length)].withOpacity(
        0.5 + random.nextDouble() * 0.3,
      );
    } else {
      // Colores suaves y elegantes para modo claro
      final colors = [
        Colors.grey.shade300,
        Colors.blueGrey.shade200,
        Colors.indigo.shade200,
        Colors.teal.shade200,
        Colors.deepPurple.shade200,
        Colors.blue.shade100,
      ];
      color = colors[random.nextInt(colors.length)].withOpacity(
        0.4 + random.nextDouble() * 0.3,
      );
    }
  }

  void update() {
    x += speedX;
    y += speedY;

    if (x < 0 || x > 1) {
      speedX *= -1;
      _updateColor();
    }
    if (y < 0 || y > 1) {
      speedY *= -1;
      _updateColor();
    }
  }
}

// Pintor personalizado para las partículas
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}