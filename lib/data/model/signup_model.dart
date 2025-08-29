class SignUpModel {
  final String message;
  final String token;

  SignUpModel({required this.message, required this.token});

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(
      message: json['status'] ?? "",
      token: json['token'] ?? "",
    );
  }
}
