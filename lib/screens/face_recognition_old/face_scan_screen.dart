import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  static String routeName = 'face-scan-screen';

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  List<Face> _faces = [];

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController?.initialize();
    setState(() {});
  }

  Future<void> _detectFaces(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
    final faces = await _faceDetector?.processImage(inputImage);

    if (faces != null && faces.isNotEmpty) {
      for (Face face in faces) {
        final faceHash = _generateFaceHash(face);
        bool isMatched = await _compareFace(faceHash);

        if (isMatched) {
          print("✅ Attendance Marked");
          await _markAttendance(faceHash);
        } else {
          print("❌ Face Not Recognized");
        }
      }
    }
    _isDetecting = false;
  }

  Future<void> _markAttendance(String faceHash) async {
    // final snapshot = await FirebaseFirestore.instance
    //     .collection('registered_faces')
    //     .where('faceHash', isEqualTo: faceHash)
    //     .get();

    // if (snapshot.docs.isNotEmpty) {
    //   String userId = snapshot.docs.first['userId'];

    // await FirebaseFirestore.instance.collection('attendance').add({
    //   'userId': userId,
    //   'timestamp': DateTime.now(),
    // });

    // print("✅ Attendance Marked for User ID: $userId");
    // }
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

  InputImage _convertCameraImage(CameraImage image) {
    final bytes = image.planes[0].bytes;
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.yuv_420_888,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<bool> _compareFace(String faceHash) async {
    // QuerySnapshot snapshot = await FirebaseFirestore.instance
    //     .collection('faces')
    //     .where('faceHash', isEqualTo: faceHash)
    //     .get();

    // return snapshot.docs.isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
