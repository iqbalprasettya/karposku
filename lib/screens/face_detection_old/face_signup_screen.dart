import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:karposku/DB/DatabaseHelper.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:path_provider/path_provider.dart';

class FaceSignUpScreeen extends StatefulWidget {
  const FaceSignUpScreeen({super.key});

  static String routeName = 'registration-screen';

  @override
  State<FaceSignUpScreeen> createState() => _FaceSignUpScreeenState();
}

class _FaceSignUpScreeenState extends State<FaceSignUpScreeen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    // Find the front camera
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          cameras.first, // Fallback to first camera if front is not found
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController?.initialize();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true, // smiling, open eyes probability
      ),
    );

    _cameraController?.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _detectFaces(image);
        // _registrationFaces(image);
      }
    });

    setState(() {});
  }

  Future<void> _detectFaces(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
    final faces = await _faceDetector?.processImage(inputImage);

    if (faces != null) {
      /* Extract Face data */
      for (Face face in faces) {
        final boundingBox = face.boundingBox;
        final smileProbability = face.smilingProbability ?? 0.0;
        final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
        final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

        print("Face detected at: $boundingBox");
        print("Smile Probability: $smileProbability");
        print("Left Eye Open: $leftEyeOpen");
        print("Right Eye Open: $rightEyeOpen");
      }

      setState(() {
        _faces = faces;
      });
    }
    _isDetecting = false;
  }

  Future<void> _registrationFaces(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
    final fileImg = inputImage.filePath!;
    final faces = await _faceDetector?.processImage(inputImage);

    if (faces != null) {
      AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Simpan Scan Wajah?'),
        actions: [
          IconButton(
            onPressed: () async {
              /* Extract Face data */
              for (Face face in faces) {
                final boundingBox = face.boundingBox;
                final smileProbability = face.smilingProbability ?? 0.0;
                final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
                final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

                // Capture & Save Face Image
                final box = face.boundingBox;

                // Save Face Data to SQLite
                await DatabaseHelper().insertFaceData({
                  'left': box.left,
                  'top': box.top,
                  'right': box.right,
                  'bottom': box.bottom,
                  'imagePath': fileImg,
                });

                print("Face detected at: $boundingBox");
                print("Smile Probability: $smileProbability");
                print("Left Eye Open: $leftEyeOpen");
                print("Right Eye Open: $rightEyeOpen");

                List<Map> dl = await DatabaseHelper().getFaceData();

                print('GET :');
                print(dl);
              }

              setState(() {
                _faces = faces;
              });
              _isDetecting = false;
              MKIMethods.showMessage(
                  context, Colors.greenAccent, 'Data Registered');
              Navigator.pop(context);
            },
            icon: Icon(Icons.check_circle),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.cancel_rounded),
          ),
        ],
      );
    }
  }

  Future<void> _captureAndSaveFace() async {
    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/${DateTime.now()}.jpg';
      final File savedImage = File(filePath);
      await imageFile.saveTo(savedImage.path);

      print("Face Image saved: $filePath");

      // // Upload image to Firestore storage
      // await FirebaseFirestore.instance.collection('faces').add({
      //   'imagePath': filePath,
      //   'timestamp': DateTime.now(),
      // });
    } catch (e) {
      print("Error saving image: $e");
    }
  }

  Future<void> saveFaceData(Face face) async {
    // await FirebaseFirestore.instance.collection('faces').add({
    //   'left': face.boundingBox.left,
    //   'top': face.boundingBox.top,
    //   'right': face.boundingBox.right,
    //   'bottom': face.boundingBox.bottom,
    //   'smileProbability': face.smilingProbability ?? 0.0,
    //   'leftEyeOpen': face.leftEyeOpenProbability ?? 0.0,
    //   'rightEyeOpen': face.rightEyeOpenProbability ?? 0.0,
    //   'timestamp': DateTime.now(),
    // });
  }

  InputImage _convertCameraImage(CameraImage image) {
    final bytes = image.planes[0].bytes;
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.yuv_420_888,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: Stack(children: [
        _cameraController?.value.isInitialized ?? false
            ? CameraPreview(_cameraController!)
            : Center(
                child: CircularProgressIndicator(),
              ),
        _faces.isNotEmpty
            ? Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.black12,
                    child: Text(
                      "Faces detected: ${_faces.length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ]),
    );
  }
}
