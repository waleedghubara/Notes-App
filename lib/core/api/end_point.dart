class EndPoint {
  static const String baseUrl = 'http://10.191.37.149/phpapi/';
  static const String baseUrlImage = 'http://10.191.37.149/phpapi/upload/';

  //auth
  static const String login = 'auth/login.php';
  static const String logout = 'customers_logout';
  static const String signup = 'auth/signup.php';
  static const String show = 'auth/profile.php';

  // 5. notes
  static const String notesview = 'notes/view.php';
  static const String notesadd = 'notes/add.php';
  static const String notesedit = 'notes/edit.php';
  static const String notesdelete = 'notes/delete.php';
}

class ApiKey {
  static String id = 'id';
  static String token = 'token';
  static String message = 'message';
  static String status = 'status';
  static String errormessage = 'ErrorMessage';
}
