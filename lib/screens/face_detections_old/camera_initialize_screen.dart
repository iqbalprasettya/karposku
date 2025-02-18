import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:karposku/painter/face_detector_painter.dart';

class CameraIntializeScreeen extends StatefulWidget {
  const CameraIntializeScreeen({super.key});

  static String routeName = 'camera-initialize-screen';

  @override
  State<CameraIntializeScreeen> createState() => _CameraIntializeScreeenState();
}

class _CameraIntializeScreeenState extends State<CameraIntializeScreeen> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  List<Rect> _faceRects = [];
  List<Face> _faceList = [];
  // var _cameraLensDirection = CameraLensDirection.front;
  // CustomPaint? _customPaint;

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }

  void _initializeFaceDetector() {
    final FaceDetectorOptions faceDetectorOptions = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    );
    _faceDetector = FaceDetector(options: faceDetectorOptions);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // final camera = cameras.first;
    // Find the front camera
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          cameras.first, // Fallback to first camera if front is not found
    );
    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController?.initialize();

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;
      _processCameraImage(image);
      /* START BUFFER */
      // try {
      //   final WriteBuffer buffer = WriteBuffer();
      //   for (Plane plane in image.planes) {
      //     buffer.putUint8List(plane.bytes);
      //   }
      //   final bytes = buffer.done().buffer.asUint8List();

      //   final inputImage = InputImage.fromBytes(
      //     bytes: bytes,
      //     metadata: InputImageMetadata(
      //       size: Size(image.width.toDouble(), image.height.toDouble()),
      //       rotation: InputImageRotation.rotation0deg,
      //       format: InputImageFormat.nv21,
      //       bytesPerRow: image.planes[0].bytesPerRow,
      //     ),
      //   );

      //   final List<Face> faces = await _faceDetector.processImage(inputImage);
      //   setState(() {
      //     _faceList = faces;
      //   });
      // } catch (e) {
      //   print("Error detecting faces: $e");
      // } finally {
      //   _isDetecting = false;
      // }
      /* END BUFFER */
    });

    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage =
        _convertCameraImageToInputImage(image, _cameraController!);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isNotEmpty) {
      /* Painter */
      // final Paint paint = Paint()
      //   ..color = Colors.green
      //   ..strokeWidth = 3
      //   ..style = PaintingStyle.stroke;
      // Size _cameraImageSize =
      //     Size(image.width.toDouble(), image.height.toDouble());
      // List<Face> _faces = faces;
      // Canvas? canvas;

      _faceRects = faces.map((face) => face.boundingBox).toList();
      // setState(() {
      _faceList = faces;
      // });

      // final painter = FaceDetectorPainter(
      //   faces,
      //   inputImage.metadata!.size,
      //   inputImage.metadata!.rotation,
      //   _cameraLensDirection,
      // );
      // _customPaint = CustomPaint(painter: painter);

      for (Face face in faces) {
        final box = face.boundingBox;
        final smileProbability = face.smilingProbability ?? 0.0;
        final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
        final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

        print('Face Registered');
        print("Face detected at: $box");
        print("Left detected at: ${box.left}");
        print("Top detected at: ${box.top}");
        print("Right detected at: ${box.right}");
        print("Bottom detected at: ${box.bottom}");

        print("Smile Probability: $smileProbability");
        print("Left Eye Open: $leftEyeOpen");
        print("Right Eye Open: $rightEyeOpen");
        // print("File Path: ${inputImage.filePath}");
      }
    } else {
      _faceRects.clear();
      _faceList.clear();
    }
    _isDetecting = false;
  }

  InputImage _convertCameraImageToInputImage(
    CameraImage image,
    CameraController controller,
  ) {
    final WriteBuffer writeBuffer = WriteBuffer();
    for (var plane in image.planes) {
      writeBuffer.putUint8List(plane.bytes);
    }

    final Uint8List bytes = writeBuffer.done().buffer.asUint8List();
    final rotation = _getRotation(controller.description.sensorOrientation);

    final InputImageMetadata metadata = InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow);

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  InputImageRotation _getRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  String _generateFaceHash(Face face) {
    List<double> landmarks = [];

    if (face.landmarks[FaceLandmarkType.leftEye] != null) {
      landmarks
          .add(face.landmarks[FaceLandmarkType.leftEye]!.position.x as double);
      landmarks
          .add(face.landmarks[FaceLandmarkType.leftEye]!.position.y as double);
    }

    if (face.landmarks[FaceLandmarkType.rightEye] != null) {
      landmarks
          .add(face.landmarks[FaceLandmarkType.rightEye]!.position.x as double);
      landmarks
          .add(face.landmarks[FaceLandmarkType.rightEye]!.position.y as double);
    }

    if (face.landmarks[FaceLandmarkType.noseBase] != null) {
      landmarks
          .add(face.landmarks[FaceLandmarkType.noseBase]!.position.x as double);
      landmarks
          .add(face.landmarks[FaceLandmarkType.noseBase]!.position.y as double);
    }

    String data = landmarks.join(",");
    return sha256.convert(utf8.encode(data)).toString();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // return DetectorView(
    //   title: 'Face Detector',
    //   customPaint: _customPaint,
    //   text: 'Face Detection',
    //   onImage: _processCameraImage,
    //   initialCameraLensDirection: _cameraLensDirection,
    //   onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    // );
    return Scaffold(
      body: _cameraController?.value.isInitialized ?? false
          ? Container(
              width: screenHeight,
              height: screenHeight,
              child: Stack(
                children: [
                  CameraPreview(_cameraController!),
                  Image(
                    image: AssetImage(
                      'assets/images/frame.png',
                    ),
                    width: screenHeight,
                    height: screenHeight,
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Face> faces;

  FacePainter({required this.faces});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var face in faces) {
      final rect = face.boundingBox;
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
