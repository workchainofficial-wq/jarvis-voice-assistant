import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceWaveAnimation extends StatelessWidget {
  final AnimationController controller;
  
  const VoiceWaveAnimation({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 200,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(
              animation: controller.value,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  
  WavePainter({required this.animation, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final waveHeight = 30.0;
    final waveLength = size.width / 4;
    
    path.moveTo(0, size.height / 2);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x / waveLength + animation * 2 * math.pi)) * waveHeight *
              (0.5 + 0.5 * math.sin(animation * 2 * math.pi));
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
