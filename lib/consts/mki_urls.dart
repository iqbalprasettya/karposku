import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:karposku/consts/mki_variabels.dart';
import 'package:karposku/models/invoice_data.dart';
import 'package:karposku/models/items_category.dart';
import 'package:karposku/models/items_data.dart';
import 'package:karposku/models/user_data.dart';
import 'package:karposku/utilities/local_storage.dart';
import 'package:karposku/models/items_cart_data.dart';

class MKIUrls {
  // static const String baseUrl = 'https://sangati-server.herokuapp.com/mobile';
  // static const String baseUrl = 'http://192.168.10.46:8888/mobile';

  static String transUrl = MKIVariabels.transUrl;
  // static Future<http.Response> loginAuth(
  //   String phoneNo,
  //   String password,s
  // ) async {
  //   var url = Uri.parse('$baseUrl/login');
  //   var response = await http.post(
  //     url,
  //     body: {
  //       'username': phoneNo,
  //       'password': password,
  //     },
  //   );
  //   return response;
  // }

  static Future<String> faceRegistration(
    String phone,
    String pass,
    String deviceId,
    String hashface,
  ) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    // final uri = Uri.parse('${MKIUrls.transUrl}/partner/profile/me');
    // const String loginUrlNew =
    // 'http://141.11.190.114:30038/karposku_api/company/mobile';
    // print(MKIUrls.transUrl);
    String url =
        'http://141.11.190.114:30038/karposku_api/mobile/register/recordnation';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll(
      {
        'phone': phone,
        'password': pass,
        // 'confirmpassword': confirmPass,
        'imei': deviceId,
        'face_recognition': hashface,
      },
    );
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String result;
    if (response.statusCode == 200) {
      result = 'succeed';
      print(await response.stream.bytesToString());
    } else {
      result = 'failed';
      print(response.reasonPhrase);
    }
    return result;
  }

  static Future<String> faceLogin(String hashface) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    String url =
        'http://141.11.190.114:30038/karposku_api/mobile/login/recordnation';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll({'face_recognition': hashface});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String rs = '';
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      var dataResponse = await response.stream.bytesToString();
      var result = jsonDecode(dataResponse);

      if (response.statusCode == 200) {
        if (result['status'] == 'success' && result['data']['phone'] != '') {
          rs = 'succeed';
        }
      } else {
        rs = 'failed';
      }
    } else {
      rs = 'failed';
      print(response.reasonPhrase);
    }
    return rs;
  }

  static Future<UserData> fetchUser(String phoneNo, String password) async {
    // const String loginUrlNew = 'https://karboe.tech/api/mobile/'; // live
    // const String loginUrlNew =
    // 'https://karbo.my.id/karposku_api/mobile'; // live

    const String loginUrlNew =
        'http://141.11.190.114:30038/karposku_api/company/mobile'; // dev
    // const String loginUrlNew = 'http://213.190.4.80/user/mobile';
    // const String loginUrlNew = 'http://213.190.4.80:8020/api/company/mobile';
    // const String loginUrlNew = 'https://karbo-api.my.id:8888/mobile'; // live

    UserData userData;
    // var dataProvider = Provider.of<UserProvider>(context, listen: false);
    final url = Uri.parse('$loginUrlNew/login');
    print(url);
    final response = await http.post(
      url,
      body: {
        'username': phoneNo,
        'password': password,
        // 'username': '123',
        // 'password': '123456',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var myJson = jsonDecode(response.body);
      // print(myJson);
      if (myJson['status'] == 'success') {
        userData = UserData.fromJson(myJson['data']);
        MKIVariabels.transUrl = myJson['url_transaction'].toString();
        // print('Url Main:  $loginUrlNew');
        print('Url Trans:  ${MKIVariabels.transUrl}');
        // MKIMethods.processGetData();

        return userData;
      } else {
        return UserData(
          phoneNo: '',
          userName: '',
          token: '',
          picPath: '',
          companyId: '',
        );
      }
      // return myJson;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load user');
    }
  }

  static Future<String> uploadMultipartImg(String filepath) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    final uri = Uri.parse('${MKIUrls.transUrl}/partner/profile');
    print(uri);
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile('partner_pict',
          File(filepath).readAsBytes().asStream(), File(filepath).lengthSync(),
          filename: filepath.split("/").last),
    );
    var res = await request.send();
    String result = await res.stream.bytesToString();
    // print(response.statusCode);
    if (res.statusCode == 200) {
      // print(result);
    } else {
      // print(res.reasonPhrase);
    }
    return result;
  }

  static Future<String> profileImage() async {
    String token = await LocalStorage.load(MKIVariabels.token);
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    final uri = Uri.parse('${MKIUrls.transUrl}/partner/profile/me');
    // print(MKIUrls.transUrl);
    print('My URI : ');
    print(uri);
    var request = http.Request('GET', uri);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    var dataResponse = await response.stream.bytesToString();

    // print(dataResponse);
    // final response = await http.post(
    //   uri,
    //   headers: headers,
    // );
    // response.body;
    var result = jsonDecode(dataResponse);
    // print(result);
    String imgUrl = '';
    if (response.statusCode == 200) {
      String fileName = result['data']['avatar'];
      print('Base Url : ${MKIUrls.transUrl}');
      print('Base Url : $fileName');
      // print(fileName);
      if (result['status'] == 'success' &&
          fileName != 'null' &&
          fileName != '') {
        imgUrl = '$transUrl$fileName';
      }
      // print('Uploaded!');
      // jsonStatus = 'succes';
    } else {
      // jsonStatus = 'failed';
    }
    // print('Hallloooooo');
    // var jsonData = (response.body);
    print("Final : $imgUrl");
    return imgUrl;
  }

  static Future<List<ItemsCategory>> getItemsCategory() async {
    String token = await LocalStorage.load(MKIVariabels.token);
    // print("TOKEN :");
    // print(token);
    List<ItemsCategory> categoryList = [];

    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    final url = Uri.parse('$transUrl/master/category');

    final response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200) {
      var myJson = response.body;
      // print(myJson);
      List jsonResponse = jsonDecode(myJson)['data'];
      if (jsonResponse.isNotEmpty) {
        categoryList = jsonResponse
            .map((catList) => ItemsCategory.fromJson(catList))
            .toList();
      } else {
        categoryList = [];
      }
      print(jsonResponse);
    } else {
      // print("Phrase: ");
      print(response.reasonPhrase);
    }
    return categoryList;
  }

  static Future<List<ItemsData>> getItemsList() async {
    String token = await LocalStorage.load(MKIVariabels.token);
    List<ItemsData> itemsList = [];

    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    final url = Uri.parse('$transUrl/master/items');
    // print(url);
    final response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200) {
      var myJson = response.body;
      // print('Items Data');
      // print(myJson);
      List jsonResponse = jsonDecode(myJson)['data'];
      if (jsonResponse.isNotEmpty) {
        itemsList =
            jsonResponse.map((catList) => ItemsData.fromJson(catList)).toList();
      } else {
        itemsList = [];
      }

      //
    } else {
      // print(response.reasonPhrase);
    }
    return itemsList;
  }

  // static Future<List<ItemsDataSample>> getDoItemsListImage() async {
  //   String token = await LocalStorage.load(MKIVariabels.token);
  //   List<ItemsDataSample> itemsList = [];

  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     // 'Content-Type': 'application/json'
  //   };
  //   final url = Uri.parse('$transUrl/item/listimage');
  //   // print(url);
  //   final response = await http.get(
  //     url,
  //     headers: headers,
  //   );
  //   if (response.statusCode == 200) {
  //     var myJson = response.body;
  //     // print(myJson);
  //     List jsonResponse = jsonDecode(myJson)['data'];
  //     if (jsonResponse.isNotEmpty) {
  //       itemsList = jsonResponse
  //           .map((itemsList) => ItemsDataSample.fromJson(itemsList))
  //           .toList();
  //     } else {
  //       itemsList = [];
  //     }

  //     //
  //   } else {
  //     // print(response.reasonPhrase);
  //   }
  //   return itemsList;
  // }

  // static Future<List<ItemData>> getDoItemsListImage() async {
  //   String token = await LocalStorage.load(MKIVariabels.token);
  //   List<ItemData> itemsList = [];

  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     // 'Content-Type': 'application/json'
  //   };
  //   final url = Uri.parse('$transUrl/item/listimage');
  //   // print(url);
  //   final response = await http.get(
  //     url,
  //     headers: headers,
  //   );
  //   if (response.statusCode == 200) {
  //     var myJson = response.body;
  //     // print(myJson);
  //     List jsonResponse = jsonDecode(myJson)['data'];
  //     if (jsonResponse.isNotEmpty) {
  //       itemsList = jsonResponse
  //           .map((itemsList) => ItemData.fromJson(itemsList))
  //           .toList();
  //     } else {
  //       itemsList = [];
  //     }

  //     //
  //   } else {
  //     // print(response.reasonPhrase);
  //   }
  //   return itemsList;
  // }

  static Future<String?> updatePass(
      String oldPass, String newPass, String confPass) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    String? jsonStatus;
    final url = Uri.parse('${MKIUrls.transUrl}/partner/change_password');

    final response = await http.post(
      url,
      headers: headers,
      body: {
        'old_password': oldPass,
        'new_password': newPass,
        'confirm_password': confPass,
      },
    );
    var myJson = jsonDecode(response.body);
    // print(myJson);
    jsonStatus = myJson['status'];
    // print(jsonStatus);

    if (response.statusCode == 200) {
      // print(oldPass);
      // print(newPass);
      // print(confPass);
      if (myJson['status'] == 'success') {
        jsonStatus = 'success';
        // print('Sukses...');
      }
    } else {
      jsonStatus = 'failed';
      // print('Gagal...');
    }
    return jsonStatus;
  }

  static Future<dynamic> createNewInvoice(
    var detailData,
  ) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    String status = 'Gagal akses ke server';
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    final url = Uri.parse('$transUrl/invoice/create');
    // final url = Uri.parse('http://192.168.10.46:8888/mobile/invoice/create');
    final response = await http.post(
      url,
      headers: headers,
      body: {
        'list_product': detailData,
      },
    );
    // print(response.statusCode);
    if (response.statusCode == 200) {
      var dataJson = response.body;
      // print(dataJson);
      // status = dataJson['status'];
      status = dataJson;
    } else {
      // print(response.reasonPhrase);
    }

    return status;
  }

  static Future<String> createOfflineInvoice(
    var invHeader,
    var invDetail,
  ) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    String status = 'Gagal akses ke server';
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };
    // print('$transUrl/invoice/create/offline/v3');
    final url = Uri.parse('$transUrl/invoice/create/offline/v3');
    final response = await http.post(
      url,
      headers: headers,
      body: {
        'header': invHeader,
        'detail': invDetail,
      },
    );
    if (response.statusCode == 200) {
      var dataJson = jsonDecode(response.body);
      status = dataJson['status'];
    } else {
      // print(response.reasonPhrase);
    }

    return status;
  }

  static Future<InvoiceData> fetchInvoiceList(String period) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    // String strDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    var headers = {
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'application/json'
    };

    final url = Uri.parse('$transUrl/invoice');
    // final url = Uri.parse('$baseUrl/invoice/v2');
    // final connResult = await InternetAddress.lookup(url.toString());
    // try {
    //   if (connResult.isNotEmpty && connResult[0].rawAddress.isNotEmpty) {
    //     print('connected');
    //   }
    // } on SocketException catch (_) {
    //   print('not connected');
    // }
    print(period);

    final response = await http.post(
      url,
      headers: headers,
      body: {
        // 'date': strDate,
        'period': period,
      },
    );
    InvoiceData invoiceData = InvoiceData('', '', '', []);
    if (response.statusCode >= 400) {
      invoiceData = InvoiceData('', '', '', []);
    } else if (response.statusCode == 200) {
      var dataJson = jsonDecode(response.body);
      if (dataJson['status'] == 'success' && dataJson['data'] != []) {
        invoiceData = InvoiceData.fromJson(dataJson);
        print(invoiceData.total);
      }
    } else {
      print(response.reasonPhrase);
    }
    return invoiceData;
  }

  static Future<String> invoiceRejection(
    String invoiceId,
  ) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$transUrl/invoice/reject/$invoiceId');

    var request = http.Request('POST', url);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    // final response = await http.post(
    //   url,
    //   headers: headers,
    //   body: {
    //     "return_no": invoiceId,
    //   },
    // );

    // var dataJson = jsonDecode(response.body);

    var dataResponse = await response.stream.bytesToString();
    var result = jsonDecode(dataResponse);
    String rs = '';
    if (response.statusCode == 200) {
      rs = result['status'];
    } else {
      rs = 'failed';
    }
    return rs;
  }

  static Future<String> createTempPacking(
    double total,
    String customerName,
    double price,
    List<ItemsCartData> items,
  ) async {
    String token = await LocalStorage.load(MKIVariabels.token);
    String status = 'Gagal akses ke server';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    // Menyiapkan detail items
    List<Map<String, dynamic>> details = items.map((item) {
      double itemPrice = double.parse(item.itemsPrice);
      return {
        'items_id': item.itemsId,
        'price': itemPrice,
        'qty': item.qty,
        'subtotal': itemPrice * item.qty,
      };
    }).toList();

    // Menyiapkan body request
    Map<String, dynamic> body = {
      'total': total,
      'customer_name': customerName,
      'price': price,
      'remarks': 'Pesanan dalam proses',
      'detail': details,
    };

    // Perbaikan URL endpoint
    final url = Uri.parse('$transUrl/invoice_temp');

    try {
      print('Request URL: $url');
      print('Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var dataJson = jsonDecode(response.body);
        status = dataJson['status'] ?? 'failed';
        print('Parsed Status: $status');
      } else {
        status = 'failed';
        print('Error Response: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error creating temp packing: $e');
      status = 'failed';
    }

    return status;
  }

  static Future<Map<String, dynamic>?> getInvoicePacking() async {
    String token = await LocalStorage.load(MKIVariabels.token);
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    final url = Uri.parse('$transUrl/invoice_temp');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
