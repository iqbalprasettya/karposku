import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceBoundingBoxPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final Size previewSize;

  FaceBoundingBoxPainter({
    required this.faces,
    required this.imageSize,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      // Convert bounding box to fit camera preview
      final double left = boundingBox.left * size.width / imageSize.width;
      final double top = boundingBox.top * size.height / imageSize.height;
      final double right = boundingBox.right * size.width / imageSize.width;
      final double bottom = boundingBox.bottom * size.height / imageSize.height;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
