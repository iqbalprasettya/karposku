class UserData {
  final String phoneNo;
  final String userName;
  final String token;
  final String picPath;
  final String companyId;

  UserData({
    required this.phoneNo,
    required this.userName,
    required this.token,
    required this.picPath,
    required this.companyId,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      phoneNo: json['phone'],
      userName: json['partner_name'],
      token: json['token'],
      picPath: json['partner_pic'],
      companyId: json['company_id'],
    );
  }

  Map toJson() => {
        'phone': phoneNo,
        'partner_name': userName,
        'token': token,
        'partner_pic': picPath,
        'company_id': companyId,
      };
}
