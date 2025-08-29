class NotesResponse {
  final String status;
  final String message;
  final int count;
  final List<Note> data;

  NotesResponse({
    required this.status,
    required this.message,
    required this.count,
    required this.data,
  });

  factory NotesResponse.fromJson(Map<String, dynamic> json) {
    return NotesResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((item) => Note.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'count': count,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Note {
  final int notesId;
  final String titel;
  final String content;
  final String notesImage;
  final int usersId;

  Note({
    required this.notesId,
    required this.titel,
    required this.content,
    required this.notesImage,
    required this.usersId,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      notesId: int.tryParse(json['notes_id'].toString()) ?? 0,
      titel: json['titel'] ?? '',
      content: json['content'] ?? '',
      notesImage: json['notes_image'] ?? '',
      usersId: int.tryParse(json['users_id'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notes_id': notesId,
      'titel': titel,
      'content': content,
      'notes_image': notesImage,
      'users_id': usersId,
    };
  }
}
