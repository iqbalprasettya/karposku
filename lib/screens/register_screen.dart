import 'package:flutter/material.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_styles.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/user_data.dart';
import 'package:karposku/screens/face_new/FaceRegisterView.dart';
import 'package:karposku/screens/login_screen.dart';
import 'package:karposku/screens/navigation_screen.dart';
import 'package:karposku/utilities/local_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static String routeName = 'register-screen';
  final imageIwidth = 210.0;
  final buttonHeight = 50.0;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  // final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late FocusNode _focusNodeUserPhone;
  // late FocusNode _focusNodeUserName;
  late FocusNode _focusNodePassword;
  late FocusNode _focusNodeConfirmPassword;

  bool isVisibleText = true;

  @override
  void initState() {
    super.initState();
    _focusNodeUserPhone = FocusNode();
    // _focusNodeUserName = FocusNode();
    _focusNodePassword = FocusNode();
    _focusNodeConfirmPassword = FocusNode();

    // MKIMethods.processGetData();
  }

  @override
  void dispose() {
    _focusNodeUserPhone.dispose();
    // _focusNodeUserName.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
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
        _focusNodeUserPhone.requestFocus();
      }
    }

    // void nameValidation() {
    //   String value = _nameController.text;
    //   if (value.trim() == '') {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         backgroundColor: Colors.redAccent,
    //         content: Text('Name cannot be empty'),
    //       ),
    //     );
    //     _focusNodeUserName.requestFocus();
    //   }
    // }

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

    void confirmPasswordValidation() {
      String value1 = _passwordController.text;
      String value2 = _confirmPasswordController.text;
      if (value1.trim() != value2.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Password & Confirm does not match'),
          ),
        );
        _focusNodeConfirmPassword.requestFocus();
      }
    }

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: MKIColorConst.mainGoldBlueAppBarAlt,
          // color: MKIColorConst.mainOrange,
        ),
        child: Semantics(
          label: 'Login screen for users auth',
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.1),
                  child: const Text(
                    'Welcome to \n KARPOSKU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: screenWidth,
                  // margin: const EdgeInsets.only(left: 20),
                  // color: Colors.yellow,
                  child: const Text(
                    'Fill your details to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                /* User Phone TextField */
                MKIStyles.textFieldCustomImage(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  controller: _phoneController,
                  textHint: 'Phone',
                  assetPath: 'assets/images/username.png',
                  inputType: TextInputType.number,
                  validationFunc: phoneValidation,
                  focusNode: _focusNodeUserPhone,
                ),
                const SizedBox(height: 15),
                /* User Name TextField */
                // MKIStyles.textFieldCustomImage(
                //   width: MediaQuery.of(context).size.width * 0.9,
                //   height: 50,
                //   controller: _nameController,
                //   textHint: 'Name',
                //   assetPath: 'assets/images/username.png',
                //   inputType: TextInputType.text,
                //   validationFunc: nameValidation,
                //   focusNode: _focusNodeUserName,
                // ),
                const SizedBox(height: 15),
                /* Password TextField */
                Container(
                  width: screenWidth * 0.9,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: TextFormField(
                    focusNode: _focusNodePassword,
                    textInputAction: TextInputAction.next,
                    controller: _passwordController,
                    obscureText: isVisibleText,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/password.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Material(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            splashColor: Colors.grey,
                            onTap: () {
                              setState(() {
                                isVisibleText = !isVisibleText;
                              });
                            },
                            child: Image.asset(
                              'assets/images/eye.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                /* Confirm Password TextField */
                Container(
                  width: screenWidth * 0.9,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: TextFormField(
                    focusNode: _focusNodeConfirmPassword,
                    textInputAction: TextInputAction.next,
                    controller: _confirmPasswordController,
                    obscureText: isVisibleText,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/password.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Material(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            splashColor: Colors.grey,
                            onTap: () {
                              setState(() {
                                isVisibleText = !isVisibleText;
                              });
                            },
                            child: Image.asset(
                              'assets/images/eye.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                // MoStyles.setTextFieldCustomImage(
                //   width: MediaQuery.of(context).size.width * 0.9,
                //   height: 50,
                //   controller: _passwordController,
                //   textHint: 'Password',
                //   assetPath: 'assets/images/password.png',
                //   inputType: TextInputType.text,
                //   validationFunc: _passwordValidation,
                //   focusNode: _focusNodePassword,
                //   isObsecureText: true,
                // ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: MKIStyles.getButtonStyle(
                      Colors.white, screenWidth * 0.9, 50),
                  onPressed: () async {
                    UserData userData;

                    if (_phoneController.text.trim() == '') {
                      phoneValidation();
                    } else if (_passwordController.text.trim().length < 3) {
                      passwordValidation();
                    } else if (_passwordController.text.trim() !=
                        _confirmPasswordController.text.trim()) {
                      confirmPasswordValidation();
                    } else {
                      // isValidData = true;
                      userData = await MKIUrls.fetchUser(
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      if (userData.userName != '' && userData.token != '') {
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

                        // LocalStorage.save(
                        //   MKIVariabels.IS_VALID_LOGIN,
                        //   '1',
                        // );

                        MKIMethods.processGetData();

                        setState(() {});

                        // Future.delayed(
                        //   Duration.zero,
                        //   (() async {

                        //   }),
                        // );

                        // var tmp =
                        //     await LocalStorage.load(MKIVariabels.IS_VALID_LOGIN);
                        // String isValidUser = tmp.toString();
                        // print('Is Valid User : $isValidUser');
                        // Navigator.pushNamed(context, BottomMenu.routeName);
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(
                            // ignore: use_build_context_synchronously
                            context,
                            NavigationScreen.routeName);
                      } else {
                        // ignore: use_build_context_synchronously
                        MKIMethods.showMessage(
                            // ignore: use_build_context_synchronously
                            context,
                            Colors.redAccent,
                            'User Password salah');
                      }
                    }

                    /*  Next Step If Data is Valid */
                  },
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          FaceRegisterView.routeName,
                        );
                      },
                      child: Text(
                        'Face Scan',
                        style: TextStyle(
                          color: Colors.white,
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
    );
  }
}
