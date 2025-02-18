import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/paint/detector_view.dart';
import 'package:karposku/painter/face_detector_painter.dart';

class FaceRegisterView extends StatefulWidget {
  const FaceRegisterView({super.key});

  static String routeName = 'register-screen';

  @override
  State<FaceRegisterView> createState() => _FaceRegisterViewState();
}

class _FaceRegisterViewState extends State<FaceRegisterView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  String _generateFaceHash(Face face) {
    List<int> landmarks = [];
    // final boundingBox = face.boundingBox;
    //   final smileProbability = face.smilingProbability ?? 0.0;
    //   final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
    //   final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

    // print('Face Registered');
    // print("Face detected at: $boundingBox");
    // print("Left detected at: ${boundingBox.left}");
    // print("Top detected at: ${boundingBox.top}");
    // print("Right detected at: ${boundingBox.right}");
    // print("Bottom detected at: ${boundingBox.bottom}");

    if (face.landmarks[FaceLandmarkType.leftEye] != null) {
      landmarks.add(face.landmarks[FaceLandmarkType.leftEye]!.position.x);
      landmarks.add(face.landmarks[FaceLandmarkType.leftEye]!.position.y);
    }

    if (face.landmarks[FaceLandmarkType.rightEye] != null) {
      landmarks.add(face.landmarks[FaceLandmarkType.rightEye]!.position.x);
      landmarks.add(face.landmarks[FaceLandmarkType.rightEye]!.position.y);
    }

    if (face.landmarks[FaceLandmarkType.noseBase] != null) {
      landmarks.add(face.landmarks[FaceLandmarkType.noseBase]!.position.x);
      landmarks.add(face.landmarks[FaceLandmarkType.noseBase]!.position.y);
    }

    String data = landmarks.join(",");
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      for (final face in faces) {
        String faceData = _generateFaceHash(face);

        final boundingBox = face.boundingBox;
        //   final smileProbability = face.smilingProbability ?? 0.0;
        //   final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
        //   final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

        print('Face Registered');
        print('Face Data: $faceData');
        print("Face detected at: $boundingBox");
        print("Left detected at: ${boundingBox.left}");
        print("Top detected at: ${boundingBox.top}");
        print("Right detected at: ${boundingBox.right}");
        print("Bottom detected at: ${boundingBox.bottom}");

        //   print("Smile Probability: $smileProbability");
        //   print("Left Eye Open: $leftEyeOpen");
        //   print("Right Eye Open: $rightEyeOpen");
        //   print("File Path: ${inputImage.filePath}");
      }
      // final painter = FaceDetectorPainter(
      //   faces,
      //   inputImage.metadata!.size,
      //   inputImage.metadata!.rotation,
      //   _cameraLensDirection,
      // );
      // _customPaint = CustomPaint(painter: painter);
      // return;
    }
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: MKIColorConst.mainGoldBlueAppBar,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          DetectorView(
            title: 'Face Register',
            customPaint: _customPaint,
            text: _text,
            onImage: _processImage,
            initialCameraLensDirection: _cameraLensDirection,
            onCameraLensDirectionChanged: (value) =>
                _cameraLensDirection = value,
          ),
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
                // color: Colors.grey.withOpacity(0.2),
                // image: DecorationImage(
                //   image: AssetImage('assets/images/frame.png'),
                //   fit: BoxFit.cover,
                // ),
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Container(
                  //   height: 25,
                  //   width: screenWidth,
                  //   decoration: BoxDecoration(
                  //     color: Colors.black,
                  //     // gradient: MKIColorConst.mainGoldBlueAppBar,
                  //   ),
                  // ),
                  Image(
                    image: AssetImage(
                      'assets/images/frame.png',
                    ),
                    //   width: screenWidth,
                    //   height: screenHeight,
                  ),
                  Container(
                    height: screenHeight * 0.17,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      gradient: MKIColorConst.mainGoldBlueAppBar,
                    ),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            MKIMethods.showTopMessage(
                              context,
                              'Konfirmasi',
                              Colors.green,
                              'Simpan Data?',
                              () {
                                /* Save Data is Here */
                              },
                              () {
                                print('Batallll');
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          icon: Icon(
                            Icons.save_rounded,
                            size: 40,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
