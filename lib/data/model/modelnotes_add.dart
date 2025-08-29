class ModelnotesAdd {
  final String status;
  final String message;

  ModelnotesAdd({required this.status, required this.message});

  factory ModelnotesAdd.fromJson(Map<String, dynamic> json) {
    return ModelnotesAdd(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
