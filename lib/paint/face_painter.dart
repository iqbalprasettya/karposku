import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;

  FacePainter({required this.faces, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    for (Face face in faces) {
      final Rect rect = face.boundingBox;
      final scaledRect = Rect.fromLTRB(
        rect.left * size.width / imageSize.width,
        rect.top * size.height / imageSize.height,
        rect.right * size.width / imageSize.width,
        rect.bottom * size.height / imageSize.height,
      );
      canvas.drawRect(scaledRect, paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}
