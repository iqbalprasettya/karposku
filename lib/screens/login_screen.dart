import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_styles.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/user_data.dart';
import 'package:karposku/screens/face_new/FaceDetectorView.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:karposku/screens/register_screen.dart';
import 'package:karposku/utilities/local_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String routeName = 'login-screen';
  final imageIwidth = 210.0;
  final buttonHeight = 50.0;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late FocusNode _focusNodeUserName;
  late FocusNode _focusNodePassword;

  bool isVisibleText = true;

  @override
  void initState() {
    super.initState();
    _focusNodeUserName = FocusNode();
    _focusNodePassword = FocusNode();
    // MKIMethods.processGetData();
  }

  @override
  void dispose() {
    _focusNodeUserName.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    void phoneValidation() {
      String value = _phoneController.text;
      if (value.trim() == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Phone cannot be empty'),
          ),
        );
        _focusNodeUserName.requestFocus();
      }
    }

    void passwordValidation() {
      String value = _passwordController.text;
      if (value.trim().length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Password length at least 6 characters'),
          ),
        );
        _focusNodePassword.requestFocus();
      }
    }

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MKIColorConstv2.secondaryDark,
              MKIColorConstv2.secondary.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  // Logo or App Name
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 45,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      'KARPOSKU',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Masuk untuk melanjutkan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),

                  // Login Form
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: MKIColorConstv2.secondaryDark,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Phone Field
                        Container(
                          decoration: BoxDecoration(
                            color: MKIColorConstv2.neutral200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _phoneController,
                            focusNode: _focusNodeUserName,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 16,
                              color: MKIColorConstv2.secondaryDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nomor Telepon',
                              hintStyle: TextStyle(
                                color: MKIColorConstv2.neutral400,
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: MKIColorConstv2.secondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: MKIColorConstv2.neutral200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            focusNode: _focusNodePassword,
                            obscureText: isVisibleText,
                            style: TextStyle(
                              fontSize: 16,
                              color: MKIColorConstv2.secondaryDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: MKIColorConstv2.neutral400,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: MKIColorConstv2.secondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isVisibleText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: MKIColorConstv2.neutral400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isVisibleText = !isVisibleText;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MKIColorConstv2.secondary,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              UserData userData;

                              if (_phoneController.text.trim() == '') {
                                phoneValidation();
                              } else if (_passwordController.text
                                      .trim()
                                      .length <
                                  3) {
                                passwordValidation();
                              } else {
                                userData = await MKIUrls.fetchUser(
                                  _phoneController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                if (userData.userName != '' &&
                                    userData.token != '') {
                                  LocalStorage.save(
                                    MKIVariabels.userPhone,
                                    _phoneController.text.trim(),
                                  );
                                  LocalStorage.save(
                                    MKIVariabels.userPassword,
                                    _passwordController.text.trim(),
                                  );
                                  LocalStorage.save(
                                    MKIVariabels.profileName,
                                    userData.userName,
                                  );
                                  LocalStorage.save(
                                    MKIVariabels.picPath,
                                    userData.picPath,
                                  );
                                  LocalStorage.save(
                                    MKIVariabels.token,
                                    userData.token,
                                  );
                                  LocalStorage.save(
                                    MKIVariabels.IS_VALID_LOGIN,
                                    '1',
                                  );

                                  MKIMethods.processGetData();
                                  setState(() {});
                                  Navigator.pushReplacementNamed(
                                    context,
                                    NavigationScreen.routeName,
                                  );
                                } else {
                                  MKIMethods.showMessage(
                                    context,
                                    Colors.redAccent,
                                    'User atau Password salah',
                                  );
                                }
                              }
                            },
                            child: Text(
                              'MASUK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Register and Face Scan Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const RegisterScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Daftar Akun',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        height: 15,
                        width: 1,
                        color: Colors.white.withOpacity(0.5),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(FaceDetectorView.routeName);
                        },
                        child: Text(
                          'Face Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
