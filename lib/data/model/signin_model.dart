class SigninModel {
  final String message;
  final String status;
  final String token;
  final int id;

  SigninModel({
    required this.message,
    required this.id,
    required this.token,
    required this.status,
  });

  factory SigninModel.fromJson(Map<String, dynamic> json) {
    return SigninModel(
      message: json['message'] ?? "",
      id: json['data'] != null ? json['data']['id'] ?? 0 : 0,
      token: json['token'] ?? "",
      status: json['status'] ?? "",
    );
  }
}
