class UserModel {
  String status;
  String message;
  UserData data; // بدل List<UserData>

  UserModel({required this.status, required this.message, required this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      status: json['status'],
      message: json['message'],
      data: UserData.fromJson(json['data']), // Map مش List
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}

class UserData {
  int id;
  String username;
  String email;
  String phone;
  int age;
  String profile;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.age,
    required this.profile,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      age: json['age'],
      profile: json['profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'age': age,
      'profile': profile,
    };
  }
}
