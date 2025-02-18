import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karposku/consts/mki_colors.dart';
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
      appBar: AppBar(
        // backgroundColor: MKIColorConst.mainToscaBlue,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: MKIColorConst.mainGoldBlueAppBar,
          ),
        ),
        centerTitle: true,
        title: Text(
          'PROFILE',
          style: TextStyle(color: MKIColorConst.mainBlue),
        ),
        actions: [
          Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              Semantics(
                  label: 'Action to adding new data',
                  button: true,
                  child: InkWell(
                    splashColor: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
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
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Semantics(
                        label: 'Icon with InkWell for adding new data',
                        child: Icon(
                          Icons.logout,
                          color: MKIColorConst.mkiSilver,
                          size: 45,
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
      // body: FutureBuilder(
      //   future: getUserProfile(),
      //   builder: (BuildContext context, AsyncSnapshot<UserData> snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //     return Column(
      //       children: [
      //         Container(
      //           width: screenWidth,
      //           child: Center(
      //             child: InkWell(
      //               onTap: pickImage,
      //               child: tmpImgFile != null
      //                   ? CircleAvatar(
      //                       backgroundImage: FileImage(tmpImgFile!),
      //                     )
      //                   : snapshot.data!.picPath != ''
      //                       ? CircleAvatar(
      //                           minRadius: 30,
      //                           maxRadius: 60,
      //                           backgroundImage: NetworkImage(
      //                             snapshot.data!.picPath,
      //                             // scale: 20,
      //                           ),
      //                           // NetworkImage(),
      //                         )
      //                       : Image.asset(
      //                           'assets/images/camera.png',
      //                           width: 80,
      //                         ),
      //               // : ClipRRect(
      //               //     child: Image.asset('assets/images/person.png'),
      //               //   ),
      //             ),
      //           ),
      //         )
      //       ],
      //     );
      //   },
      // )
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder(
            future: getUserProfile(),
            builder: (BuildContext context, AsyncSnapshot<UserData> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return ListView(
                  children: ListTile.divideTiles(
                    color: Colors.grey,
                    tiles: [
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        // padding: const EdgeInsets.only(top: 13),
                        child: InkWell(
                          onTap: pickImage,
                          child: tmpImgFile != null
                              ? CircleAvatar(
                                  minRadius: 40,
                                  maxRadius: 70,
                                  backgroundImage: FileImage(tmpImgFile!),
                                )
                              : snapshot.data!.picPath != ''
                                  ? CircleAvatar(
                                      minRadius: 40,
                                      maxRadius: 70,

                                      backgroundImage: NetworkImage(
                                        snapshot.data!.picPath,
                                        // scale: 10,
                                      ),
                                      // NetworkImage(),
                                    )
                                  : Image.asset(
                                      'assets/images/camera.png',
                                      width: 80,
                                    ),
                          // : ClipRRect(
                          //     child: Image.asset('assets/images/person.png'),
                          //   ),
                        ),
                      ),
                      // ListTile(
                      //   leading: Text(
                      //     'Photo',
                      //     style: TextStyle(color: MKIColorConst.mainBlue),
                      //   ),
                      //   trailing: InkWell(
                      //     onTap: pickImage,
                      //     child: tmpImgFile != null
                      //         ? CircleAvatar(
                      //             backgroundImage: FileImage(tmpImgFile!),
                      //           )
                      //         : snapshot.data!.picPath != ''
                      //             ? CircleAvatar(
                      //                 backgroundImage: NetworkImage(
                      //                   snapshot.data!.picPath,
                      //                   // scale: 10,
                      //                 ),
                      //                 // NetworkImage(),
                      //               )
                      //             : Image.asset(
                      //                 'assets/images/camera.png',
                      //                 width: 80,
                      //               ),
                      //   ),
                      // ),
                      ListTile(
                        leading: Text(
                          'Name',
                          style: TextStyle(
                            color: MKIColorConst.mainBlue,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Text(
                          snapshot.data!.userName,
                          style: TextStyle(
                            color: MKIColorConst.mainBlue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Text(
                          'Phone',
                          style: TextStyle(
                            color: MKIColorConst.mainBlue,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Text(
                          snapshot.data!.phoneNo,
                          style: TextStyle(
                            color: MKIColorConst.mainBlue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      // const ListTile(
                      //   leading: Text('Email'),
                      //   trailing: Text('andarussa@gmail.com'),
                      // ),
                      ListTile(
                        leading: Text(
                          'Password',
                          style: TextStyle(
                            color: MKIColorConst.mainBlue,
                            fontSize: 15,
                          ),
                        ),
                        trailing: IconButton(
                          alignment: Alignment.centerRight,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding: EdgeInsets.zero,
                                    content: Stack(
                                      // overflow: Overflow.visible,
                                      children: <Widget>[
                                        Form(
                                          key: _formKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const SizedBox(height: 60),
                                                getTextPadding(
                                                  "Old Password",
                                                  Icons.key,
                                                  Colors.grey.withOpacity(0.4),
                                                  _oldPassController,
                                                  _focusNodeOldPass,
                                                ),
                                                getTextPadding(
                                                  "New Password",
                                                  Icons.key,
                                                  Colors.grey.withOpacity(0.4),
                                                  _newPassController,
                                                  _focusNodeNewPass,
                                                ),
                                                getTextPadding(
                                                  "Confirm Password",
                                                  Icons.key,
                                                  Colors.grey.withOpacity(0.4),
                                                  _confirmPassController,
                                                  _focusNodeConfirmPass,
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  // padding: EdgeInsets.all(10),
                                                  margin: const EdgeInsets.only(
                                                      right: 10, bottom: 5),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      // primary: MKIColorConst
                                                      // .mainLightBlue,
                                                      backgroundColor:
                                                          MKIColorConst
                                                              .mkiDeepBlue
                                                              .withOpacity(0.7),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      "Submit",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    onPressed: () async {
                                                      String oldPass =
                                                          _oldPassController
                                                              .text;
                                                      String newPass =
                                                          _newPassController
                                                              .text;
                                                      String confPass =
                                                          _confirmPassController
                                                              .text;

                                                      // print(oldPass);
                                                      // print(newPass);
                                                      // print(confPass);

                                                      if (oldPass.trim() ==
                                                          '') {
                                                        textValidation(
                                                          "Password lama harus diisi",
                                                          _focusNodeOldPass,
                                                          Colors.redAccent,
                                                        );
                                                      } else if (newPass
                                                              .trim() ==
                                                          '') {
                                                        textValidation(
                                                          "Password baru harus diisi",
                                                          _focusNodeNewPass,
                                                          Colors.redAccent,
                                                        );
                                                      } else if (newPass !=
                                                          confPass) {
                                                        textValidation(
                                                          'Password baru dan konfirmasi tidak sama',
                                                          _focusNodeConfirmPass,
                                                          Colors.redAccent,
                                                        );
                                                      } else {
                                                        String? passMessage;
                                                        passMessage =
                                                            await MKIUrls
                                                                .updatePass(
                                                          oldPass,
                                                          newPass,
                                                          confPass,
                                                        );

                                                        // print(
                                                        //     'Message : $passMessage');

                                                        if (passMessage ==
                                                            'success') {
                                                          textValidation(
                                                            'Password Berhasil Diupdate',
                                                            _focusNodeConfirmPass,
                                                            Colors.green,
                                                          );
                                                          // ignore: use_build_context_synchronously
                                                          Navigator.pop(
                                                              // ignore: use_build_context_synchronously
                                                              context);
                                                          // ignore: use_build_context_synchronously
                                                          Navigator
                                                              .pushReplacementNamed(
                                                            // ignore: use_build_context_synchronously
                                                            context,
                                                            LoginScreen
                                                                .routeName,
                                                          );
                                                        } else {
                                                          textValidation(
                                                            'Password lama salah',
                                                            _focusNodeConfirmPass,
                                                            Colors.redAccent,
                                                          );
                                                        }
                                                      }
                                                      // if (_formKey.currentState
                                                      //     .validate()) {
                                                      //   _formKey.currentState.save();
                                                      // }
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: Container(
                                            height: 60,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                gradient: MKIColorConst
                                                    .mainGoldBlueAppBar,
                                                // color:
                                                // MKIColorConst.mainToscaBlue,
                                                // color: Colors.yellow
                                                //     .withOpacity(0.2),
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey
                                                            .withOpacity(
                                                                0.3)))),
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 30),
                                              alignment: Alignment.centerLeft,
                                              child: const Text(
                                                "Change Password",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 20,
                                                    fontStyle: FontStyle.italic,
                                                    fontFamily: "Helvetica"),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 12,
                                          top: 15.0,
                                          child: InkResponse(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor: MKIColorConst
                                                  .mkiDeepBlue
                                                  .withOpacity(0.7),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).then((value) {
                              _oldPassController.clear();
                              _newPassController.clear();
                              _confirmPassController.clear();
                            });
                          },
                          icon: const Icon(Icons.navigate_next),
                        ),
                      ),
                      // ListTile(
                      //   leading: Text(
                      //     'Reseller',
                      //     style: TextStyle(color: MKIColorConst.mainBlue),
                      //   ),
                      //   trailing: Text(
                      //     'CHANGE THIS',
                      //     style: TextStyle(color: MKIColorConst.mainBlue),
                      //   ),
                      // ),
                      ListTile(
                        leading: InkWell(
                          onTap: () {
                            // LocalStorage.remove(MKIVariabels.IS_VALID_LOGIN);
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
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 10,
                              bottom: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: MKIColorConst.mkiDeepBlue.withOpacity(0.7),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                // color: MKIColorConst.mainBlue,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // tiles: _profile.map(
                    // (item) => ListTile(
                    // leading: Text(item['title']),
                    // leading: CircleAvatar(
                    //   backgroundColor: Colors.amber,
                    //   child: Text(item['id'].toString()),
                    // ),
                    // title: Text(item['title']),
                    // subtitle: Text(item['subtitle']),
                    // trailing: Image.asset('assets/images/eye.png'),
                    // trailing: IconButton(
                    //   icon: Icon(Icons.delete),
                    //   onPressed: () {},
                    // ),
                    // ),
                    // ),
                  ).toList(),
                );
              } else {
                return Center(
                  child: Text(
                    'Data Tidak Ditemukan',
                    style:
                        TextStyle(fontSize: 20, color: MKIColorConst.mainBlue),
                  ),
                );
              }
            },
          ),
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
