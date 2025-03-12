import 'package:flutter/material.dart';
import 'package:karposku/providers/items_data_provider.dart';
import 'package:karposku/providers/items_list_cart_provider.dart';
import 'package:karposku/providers/printer_provider.dart';
import 'package:karposku/screens/face_detections_old/do_face_detection.dart';
import 'package:karposku/screens/face_detections_old/face_recognition.dart';
import 'package:karposku/screens/face_detections_old/camera_initialize_screen.dart';
import 'package:karposku/screens/face_detection_old/face_signup_screen.dart';
import 'package:karposku/screens/face_detections_old/face_sign_up_screen.dart';
import 'package:karposku/screens/face_new/FaceDetectorView.dart';
import 'package:karposku/screens/face_new/FaceRegisterView.dart';
import 'package:karposku/screens/login_screen.dart';
import 'package:karposku/screens/register_screen.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:karposku/consts/mki_methods.dart';

bool isValidLogin = false;

Future<void> requestCameraPermission() async {
  await Permission.camera.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  requestCameraPermission();

  // Aktifkan auto login
  isValidLogin = await MKIMethods.autoLogin();
  if (isValidLogin) {
    MKIMethods.processGetData();
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ItemsDataProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ItemsListCartProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => PrinterProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: FaceDetectionScreeen(),
      home: isValidLogin ? const NavigationScreen() : const LoginScreen(),
      routes: {
        NavigationScreen.routeName: (_) => const NavigationScreen(),
        FaceSignUpScreeen.routeName: (_) => const FaceSignUpScreeen(),
        CameraIntializeScreeen.routeName: (_) => const CameraIntializeScreeen(),
        RecognitionScreen.routeName: (_) => const RecognitionScreen(),
        FaceRecognition.routeName: (_) => const FaceRecognition(),
        DoFaceDetection.routeName: (_) => DoFaceDetection(),
        FaceDetectorView.routeName: (_) => FaceDetectorView(),
        RegisterScreen.routeName: (_) => RegisterScreen(),
        FaceRegisterView.routeName: (_) => FaceRegisterView(),
      },
    );
  }
}
