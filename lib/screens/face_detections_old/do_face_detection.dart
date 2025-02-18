import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DoFaceDetection extends StatefulWidget {
  const DoFaceDetection({super.key});

  static String routeName = 'face-scan-screen';

  @override
  State<DoFaceDetection> createState() => _DoFaceDetectionState();
}

class _DoFaceDetectionState extends State<DoFaceDetection> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  // late List<Face> _faces;
  // late Size _cameraImageSize;
  final FaceDetectorOptions _faceDetectorOptions = FaceDetectorOptions(
    enableContours: true,
    enableLandmarks: true,
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(options: _faceDetectorOptions);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // Future<void> _initialController() async {
  //   final frontCamera = _cameras.firstWhere(
  //     (camera) => camera.lensDirection == CameraLensDirection.front,
  //     orElse: () => _cameras.first,
  //   );
  //   _cameraController = CameraController(frontCamera, ResolutionPreset.high);
  //   await _cameraController.initialize();
  // }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    final frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
    _cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await _cameraController.initialize();
    _cameraController.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;
      _processCameraImage(image);
    });

    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage =
        _convertCameraImageToInputImage(image, _cameraController);
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

      for (Face face in faces) {
        // final Rect boundingBox = face.boundingBox;

        // final double left = boundingBox.left * size.width / image.width;
        // final double top = boundingBox.top * size.height / image.height;
        // final double right = boundingBox.right * size.width / image.width;
        // final double bottom = boundingBox.bottom * size.height / image.height;

        // canvas!.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

        // final boundingBox = face.boundingBox;
        // final double left = boundingBox.left * size.width / imageSize.width;
        // final double top = boundingBox.top * size.height / imageSize.height;
        // final double right = boundingBox.right * size.width / imageSize.width;
        // final double bottom =
        //     boundingBox.bottom * size.height / imageSize.height;

        // canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
        // final faceContours = face.contours;

        // if (faceContours[FaceContourType.face] != null) {
        //   List<Point<int>> faceOutline =
        //       faceContours[FaceContourType.face]!.points;
        //   print("Face outline points: $faceOutline");
        // }

        // if (faceContours[FaceContourType.leftEye] != null) {
        //   List<Point<int>> leftEyeOutline =
        //       faceContours[FaceContourType.leftEye]!.points;
        //   print("Left Eye Contour: $leftEyeOutline");
        // }

        // if (faceContours[FaceContourType.rightEye] != null) {
        //   List<Point<int>> rightEyeOutline =
        //       faceContours[FaceContourType.rightEye]!.points;
        //   print("Right Eye Contour: $rightEyeOutline");
        // }

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
      _isDetecting = false;
    }
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

  @override
  Widget build(BuildContext context) {
    // if (!_cameraController.value.isInitialized) {
    //   return Center(child: CircularProgressIndicator());
    // }
    return !_cameraController.value.isInitialized
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              CameraPreview(_cameraController),
              // Positioned.fill(
              //   child: CustomPaint(
              //     painter: FaceBoundingBoxPainter(
              //         faces: _faces, imageSize: _cameraImageSize),
              //   ),
              // ),
            ],
          );
  }
}

// class FaceBoundingBoxPainter extends CustomPainter {
//   final List<Face> faces;
//   final Size imageSize;

//   FaceBoundingBoxPainter({required this.faces, required this.imageSize});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;

//     for (Face face in faces) {
//       final Rect boundingBox = face.boundingBox;

//       final double left = boundingBox.left * size.width / imageSize.width;
//       final double top = boundingBox.top * size.height / imageSize.height;
//       final double right = boundingBox.right * size.width / imageSize.width;
//       final double bottom = boundingBox.bottom * size.height / imageSize.height;

//       canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
