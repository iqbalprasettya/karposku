import 'dart:convert';
import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:karposku/DB/DatabaseHelper.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_urls.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  static String routeName = 'face_signup-screen';

  @override
  State<RecognitionScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RecognitionScreen> {
  //TODO declare variables
  late ImagePicker imagePicker;
  File? _image;
  FaceDetector? _faceDetector;

  //TODO declare detector

  //TODO declare face recognizer

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true, // smiling, open eyes probability
      ),
    );

    //TODO initialize face detector

    //TODO initialize face recognizer
  }

  @override
  void dispose() {
    _faceDetector?.close();
    super.dispose();
  }

  String _generateFaceHash(Face face) {
    List<int> landmarks = [];

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

  //TODO capture image using camera
  _imgRegisteredFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doFaceRegistration(InputImage.fromFile(_image!));
      });
    }
  }

  _imgLoginFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doFaceLogin(InputImage.fromFile(_image!));
      });
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doFaceRegistration(InputImage.fromFile(_image!));
      });
    }
  }

  Future<bool> _compareFace(String faceHash) async {
    // QuerySnapshot snapshot = await FirebaseFirestore.instance
    //     .collection('registered_faces')
    //     .where('faceHash', isEqualTo: faceHash)
    //     .get();
    // return snapshot.docs.isNotEmpty;
    String rs = await MKIUrls.faceLogin(faceHash);
    bool isValid = false;
    if (rs == 'succeed') {
      isValid = true;
    }
    return isValid;
  }

  doFaceLogin(InputImage inputImage) async {
    // final List<Face> faces = await _faceDetector!.processImage(inputImage);
    final faces = await _faceDetector?.processImage(inputImage);

    //TODO remove rotation of camera images

    //TODO passing input to face detector and getting detected faces
    if (faces != null) {
      print('GET START :');
      for (Face face in faces) {
        final boundingBox = face.boundingBox;
        final smileProbability = face.smilingProbability ?? 0.0;
        final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
        final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

        // Capture & Save Face Image
        // final box = face.boundingBox;

        String faceHash = _generateFaceHash(face);
        bool isMatched = await _compareFace(faceHash);

        if (isMatched) {
          MKIMethods.showMessage(context, Colors.greenAccent, 'Face Detected');
        }

        // Get Face Data from SQLite
        // List<Map> dl = await DatabaseHelper().getFaceData();
        // MKIMethods.showMessage(context, Colors.greenAccent, 'Data Registered');

        // print('GET :');
        // print(dl);
        // await DatabaseHelper().insertFaceData({
        //   'left': box.left,
        //   'top': box.top,
        //   'right': box.right,
        //   'bottom': box.bottom,
        //   'imagePath': inputImage.filePath,
        // });

        // print('Face Registered');
        // print("Face detected at: $boundingBox");
        // print("Smile Probability: $smileProbability");
        // print("Left Eye Open: $leftEyeOpen");
        // print("Right Eye Open: $rightEyeOpen");
        // print("File Path: ${inputImage.filePath}");
      }
      // Navigator.pop(context);
      print('GET END :');
    }

    // if (faces != null) {
    //   /* Extract Face data */
    //   for (Face face in faces) {
    //     final boundingBox = face.boundingBox;
    //     final smileProbability = face.smilingProbability ?? 0.0;
    //     final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
    //     final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

    //     print("Face detected at: $boundingBox");
    //     print("Smile Probability: $smileProbability");
    //     print("Left Eye Open: $leftEyeOpen");
    //     print("Right Eye Open: $rightEyeOpen");
    //   }

    //   setState(() {
    //     // _faces = faces;
    //   });
    // }
    Navigator.pop(context);

    //TODO call the method to perform face recognition on detected faces
  }

  //TODO face detection code here

  doFaceRegistration(InputImage inputImage) async {
    // final List<Face> faces = await _faceDetector!.processImage(inputImage);
    final faces = await _faceDetector?.processImage(inputImage);

    //TODO remove rotation of camera images

    //TODO passing input to face detector and getting detected faces
    if (faces != null) {
      print('GET START :');
      for (Face face in faces) {
        final boundingBox = face.boundingBox;
        final smileProbability = face.smilingProbability ?? 0.0;
        final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
        final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

        // Capture & Save Face Image
        // final box = face.boundingBox;

        String faceHash = _generateFaceHash(face);
        // await MKIUrls.faceRegistration(faceHash);
        print('Facehash Registered : $faceHash');

        // Save Face Data to SQLite
        // await DatabaseHelper().insertFaceData({
        //   'left': box.left,
        //   'top': box.top,
        //   'right': box.right,
        //   'bottom': box.bottom,
        //   'imagePath': inputImage.filePath,
        // });

        // print('Face Registered');
        // print("Face detected at: $boundingBox");
        // print("Left detected at: ${box.left}");
        // print("Top detected at: ${box.top}");
        // print("Right detected at: ${box.right}");
        // print("Bottom detected at: ${box.bottom}");

        // print("Smile Probability: $smileProbability");
        // print("Left Eye Open: $leftEyeOpen");
        // print("Right Eye Open: $rightEyeOpen");
        // print("File Path: ${inputImage.filePath}");

        // List<Map> dl = await DatabaseHelper().getFaceData();

        MKIMethods.showMessage(context, Colors.greenAccent, 'Data Registered');

        // print('GET :');
        // print(dl);
      }
      print('GET END :');
    }

    Navigator.pop(context);

    //TODO call the method to perform face recognition on detected faces
  }

  //TODO remove rotation of camera images
  removeRotation(File inputImage) async {
    final img.Image? capturedImage =
        img.decodeImage(await File(inputImage.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _image != null
              ? Container(
                  margin: const EdgeInsets.only(top: 100),
                  width: screenWidth - 50,
                  height: screenWidth - 50,
                  child: Image.file(_image!),
                )
              // Container(
              //   margin: const EdgeInsets.only(
              //       top: 60, left: 30, right: 30, bottom: 0),
              //   child: FittedBox(
              //     child: SizedBox(
              //       width: image.width.toDouble(),
              //       height: image.width.toDouble(),
              //       child: CustomPaint(
              //         painter: FacePainter(
              //             facesList: faces, imageFile: image),
              //       ),
              //     ),
              //   ),
              // )
              : Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Image.asset(
                    "assets/images/karbotech.png",
                    width: screenWidth - 100,
                    height: screenWidth - 100,
                  ),
                ),

          Container(
            height: 50,
          ),

          //TODO section which displays buttons for choosing and capturing images
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Card(
                //   shape: const RoundedRectangleBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(200))),
                //   child: InkWell(
                //     onTap: () {
                //       _imgFromGallery();
                //     },
                //     child: SizedBox(
                //       width: screenWidth / 2 - 70,
                //       height: screenWidth / 2 - 70,
                //       child: Icon(Icons.image,
                //           color: Colors.blue, size: screenWidth / 7),
                //     ),
                //   ),
                // ),
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200))),
                  child: InkWell(
                    onTap: () {
                      print('SCANNNNNN :');
                      _imgRegisteredFromCamera();
                    },
                    child: SizedBox(
                      width: screenWidth / 2 - 70,
                      height: screenWidth / 2 - 70,
                      child: Icon(Icons.scanner,
                          color: Colors.blue, size: screenWidth / 7),
                    ),
                  ),
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200))),
                  child: InkWell(
                    onTap: () {
                      print('SCANNNNNN :');
                      _imgLoginFromCamera();
                    },
                    child: SizedBox(
                      width: screenWidth / 2 - 70,
                      height: screenWidth / 2 - 70,
                      child: Icon(Icons.camera,
                          color: Colors.blue, size: screenWidth / 7),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// class FacePainter extends CustomPainter {
//   List<Face> facesList;
//   dynamic imageFile;
//   FacePainter({required this.facesList, @required this.imageFile});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (imageFile != null) {
//       canvas.drawImage(imageFile, Offset.zero, Paint());
//     }
//
//     Paint p = Paint();
//     p.color = Colors.red;
//     p.style = PaintingStyle.stroke;
//     p.strokeWidth = 3;
//
//     for (Face face in facesList) {
//       canvas.drawRect(face.boundingBox, p);
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }

//   'left': box.left,
//   'top': box.top,
//   'right': box.right,
//   'bottom': box.bottom,
//   'imagePath': inputImage.filePath,

class FaceData {
  final int id;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final String imagePath;

  FaceData({
    required this.id,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.imagePath,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
      'imagePath': imagePath,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Face{id: $id, left: $left, top: $top, right: $right, bottom: $bottom, imagePath: $imagePath}';
  }
}
