class Constants {
  static const String baseUrl = 'https://mock.apidog.com/m1/820032-799426-default'; //ApiDog
  // static const String baseUrl = 'https://0ceba48b-6fa5-45d1-9520-4d0792c8d123.mock.pstmn.io'; //Postman
  // static const String baseUrl = 'https://api.mockfly.dev/mocks/8bc986d0-f33b-4f0d-80cf-a9655739a6c4'; //MockFly


  static const String student = 'student';
  static const String staff = 'staff';
  static const String admin = 'admin';
}

class ApiEndpoints {
  static const String adminDashboard = 'admin/dashboard';
  static const String login = 'login';
  static const String studentFeed = 'students/feed';
  static const String adminHolidays = 'holidays';
  static const String adminPosts = 'admin/posts';
  static const String adminStaffs = 'admin/staffs';
  static const String adminStudents = 'admin/students';
  static const String staffAttendance = 'staff/attendance';

  static const String complaints = "admin/complaints";
  static const String addComplaint = "api/complaints";
  static const String updateComplaintStatus = "api/complaints/update-status";
  static const String addComplaintComment = "api/complaints/comment";

  static const String books = 'books';
  static const String addBook = 'books/add';
  static const String issueBook = 'books/issue';
  static const String returnBook = 'books/return';
  static const String issuedBooks = 'books/issued';
}
