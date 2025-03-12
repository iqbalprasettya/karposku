import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karposku/consts/mki_colors.dart';
import 'package:karposku/consts/mki_colorsv2.dart';
import 'package:karposku/consts/mki_methods.dart';
import 'package:karposku/consts/mki_urls.dart';
import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/user_data.dart';
import 'package:karposku/screens/login_screen.dart';
import 'package:karposku/utilities/local_storage.dart';

// final List<Map<String, dynamic>> _items = List.generate(
//     10,
//     (index) =>
//         {"id": index, "title": "Item $index", "subtitle": "Subtitle $index"});

// final List<Map<String, dynamic>> _profile = [
//   {'title': 'Photo'},
//   {'title': 'Name'},
//   {'title': 'Phone'},
//   {'title': 'Email'},
//   {'title': 'Password'},
//   {'title': 'Info'},
//   {'title': 'Logout'},
// ];
TextEditingController _oldPassController = TextEditingController();
TextEditingController _newPassController = TextEditingController();
TextEditingController _confirmPassController = TextEditingController();

late FocusNode _focusNodeOldPass;
late FocusNode _focusNodeNewPass;
late FocusNode _focusNodeConfirmPass;

File? tmpImgFile;
late XFile? pickedImgFile;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static String routeName = 'profile-screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imgPicker = ImagePicker();
  String profileName = "";
  String phoneNo = "";
  String pass = "";
  String imgPath = "";
  dynamic pickImageError;

  final _formKey = GlobalKey<FormState>();

  Future<UserData> getUserProfile() async {
    final String? phoneNo = await LocalStorage.load(MKIVariabels.userPhone);
    // final String? password = await LocalStorage.load(MKIVariabels.userPassword);
    final String? profileName =
        await LocalStorage.load(MKIVariabels.profileName);
    imgPath = await MKIUrls.profileImage();

    // UserData userData = await MKIUrls.fetchUser(phoneNo!, password!);
    UserData userData = UserData(
      phoneNo: phoneNo!,
      userName: MKIMethods.capitalizeFirstChar(profileName!),
      token: 'Maurice',
      picPath: imgPath,
      companyId: '',
    );
    return userData;
  }

  Future<void> pickImage() async {
    try {
      final XFile? tmpPickedFile = await _imgPicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 100,
      );
      if (tmpPickedFile != null) {
        setState(() {
          pickedImgFile = tmpPickedFile;
          imgPath = pickedImgFile!.path;
          tmpImgFile = File(pickedImgFile!.path);
          // MKIUrls.updateProfileImg(imgPath);
          MKIUrls.uploadMultipartImg(imgPath);
          // print("Path : $imgPath");
        });
      }
    } catch (e) {
      pickImageError = e;
    }
  }

  // void pickUploadProfileImg() async {
  //   pickImage();
  //   if (tmpImgFile != null) {
  //     print('Eksekusi');
  //     VSAUrls.updateProfileImg(tmpImgFile!.path);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _focusNodeOldPass = FocusNode();
    _focusNodeNewPass = FocusNode();
    _focusNodeConfirmPass = FocusNode();
    // setUserData();
  }

  @override
  void dispose() {
    _focusNodeOldPass.dispose();
    _focusNodeNewPass.dispose();
    _focusNodeConfirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // var profileData = Provider.of<UserProvider>(context, listen: false);
    // profileData.getExistsData();
    // UserData userData = profileData.userData;
    // print(userData.userName);

    void textValidation(
        String textMessage, FocusNode focusNode, Color messageColor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: messageColor,
          content: Text(textMessage),
        ),
      );
      focusNode.requestFocus();
    }

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          color: MKIColorConstv2.neutral200,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              Container(
                padding: EdgeInsets.only(top: 50, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MKIColorConstv2.secondaryDark,
                      MKIColorConstv2.secondary.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MKIColorConstv2.neutral100,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              LocalStorage.remove(MKIVariabels.userPhone);
                              LocalStorage.remove(MKIVariabels.userPassword);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            icon: Icon(
                              Icons.logout,
                              color: MKIColorConstv2.neutral100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: FutureBuilder(
                  future: getUserProfile(),
                  builder:
                      (BuildContext context, AsyncSnapshot<UserData> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      return Column(
                        children: [
                          // Profile Image
                          InkWell(
                            onTap: pickImage,
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: MKIColorConstv2.secondary,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: MKIColorConstv2.neutral100,
                                child: tmpImgFile != null
                                    ? ClipOval(
                                        child: Image.file(
                                          tmpImgFile!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : snapshot.data!.picPath != ''
                                        ? ClipOval(
                                            child: Image.network(
                                              snapshot.data!.picPath,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: MKIColorConstv2
                                                      .neutral400,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt,
                                            size: 40,
                                            color: MKIColorConstv2.neutral400,
                                          ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Profile Info Cards
                          _buildProfileCard(
                            'Nama',
                            snapshot.data!.userName,
                            Icons.person_outline,
                          ),
                          SizedBox(height: 15),
                          _buildProfileCard(
                            'No. Telepon',
                            snapshot.data!.phoneNo,
                            Icons.phone_outlined,
                          ),
                          SizedBox(height: 15),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.lock_outline,
                                          color: MKIColorConstv2.secondary,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Ubah Password',
                                          style: TextStyle(
                                            color: MKIColorConstv2.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildPasswordField(
                                            "Password Lama",
                                            _oldPassController,
                                            _focusNodeOldPass,
                                          ),
                                          SizedBox(height: 15),
                                          _buildPasswordField(
                                            "Password Baru",
                                            _newPassController,
                                            _focusNodeNewPass,
                                          ),
                                          SizedBox(height: 15),
                                          _buildPasswordField(
                                            "Konfirmasi Password",
                                            _confirmPassController,
                                            _focusNodeConfirmPass,
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Batal',
                                          style: TextStyle(
                                            color: MKIColorConstv2.neutral500,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              MKIColorConstv2.secondary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () async {
                                          String oldPass =
                                              _oldPassController.text;
                                          String newPass =
                                              _newPassController.text;
                                          String confPass =
                                              _confirmPassController.text;

                                          if (oldPass.trim() == '') {
                                            textValidation(
                                              "Password lama harus diisi",
                                              _focusNodeOldPass,
                                              Colors.redAccent,
                                            );
                                          } else if (newPass.trim() == '') {
                                            textValidation(
                                              "Password baru harus diisi",
                                              _focusNodeNewPass,
                                              Colors.redAccent,
                                            );
                                          } else if (newPass != confPass) {
                                            textValidation(
                                              'Password baru dan konfirmasi tidak sama',
                                              _focusNodeConfirmPass,
                                              Colors.redAccent,
                                            );
                                          } else {
                                            String? passMessage =
                                                await MKIUrls.updatePass(
                                              oldPass,
                                              newPass,
                                              confPass,
                                            );

                                            if (passMessage == 'success') {
                                              textValidation(
                                                'Password Berhasil Diupdate',
                                                _focusNodeConfirmPass,
                                                Colors.green,
                                              );
                                              Navigator.pop(context);
                                              Navigator.pushReplacementNamed(
                                                context,
                                                LoginScreen.routeName,
                                              );
                                            } else {
                                              textValidation(
                                                'Password lama salah',
                                                _focusNodeConfirmPass,
                                                Colors.redAccent,
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          'Simpan',
                                          style: TextStyle(
                                            color: MKIColorConstv2.neutral100,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ).then((value) {
                                _oldPassController.clear();
                                _newPassController.clear();
                                _confirmPassController.clear();
                              });
                            },
                            child: _buildProfileCard(
                              'Password',
                              '••••••••',
                              Icons.lock_outline,
                              showArrow: true,
                            ),
                          ),
                          SizedBox(height: 30),

                          // Logout Button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MKIColorConstv2.secondary,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                LocalStorage.remove(MKIVariabels.userPhone);
                                LocalStorage.remove(MKIVariabels.userPassword);
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
                                'Keluar',
                                style: TextStyle(
                                  color: MKIColorConstv2.neutral100,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Text(
                          'Data Tidak Ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: MKIColorConstv2.neutral500,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String label, String value, IconData icon,
      {bool showArrow = false}) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: MKIColorConstv2.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MKIColorConstv2.neutral300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MKIColorConstv2.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: MKIColorConstv2.secondary,
              size: 20,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: MKIColorConstv2.neutral500,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: MKIColorConstv2.secondaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            Icon(
              Icons.arrow_forward_ios,
              color: MKIColorConstv2.neutral400,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
      String hint, TextEditingController controller, FocusNode focusNode) {
    return Container(
      decoration: BoxDecoration(
        color: MKIColorConstv2.neutral200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: MKIColorConstv2.neutral400,
            fontSize: 14,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        ),
      ),
    );
  }
}

// InputDecoration getInputDecoration(String hintText) {
//   return InputDecoration(
//     hintText: hintText,
//     contentPadding: const EdgeInsets.only(left: 20),
//     border: InputBorder.none,
//     focusedBorder: InputBorder.none,
//     errorBorder: InputBorder.none,
//     hintStyle: const TextStyle(
//         color: Colors.black26, fontSize: 18, fontWeight: FontWeight.w500),
//   );
// }

Padding getTextPadding(String hintText, IconData icon, Color iconColor,
    TextEditingController textController, FocusNode focusNode) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Container(
      height: 40,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.2)))),
              child: Center(
                child: Icon(
                  icon,
                  size: 25,
                  // color: Colors.grey.withOpacity(0.4),
                  color: iconColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: textController,
              focusNode: focusNode,
              obscureText: true,
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding: const EdgeInsets.only(left: 20),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                hintStyle: const TextStyle(
                    color: Colors.black26,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
