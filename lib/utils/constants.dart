class Constants {
  static String baseUrl = "https://web-production-28310.up.railway.app/api/v1";
  static const String prodBaseUrl = 'https://web-production-28310.up.railway.app/api/v1'; //Zoho Catalyst
  static const String mockBaseUrl = 'https://mock.apidog.com/m1/820032-799426-default'; //ApiDog

  // Tenant/Client ID
  static String tenantId = '';

  // User roles
  static const String student = 'student';
  static const String staff = 'staff';
  static const String admin = 'admin';
}

class ApiEndpoints {
  static const String adminLogin = 'users/login';
  static const String loginWithFCM = 'users/login-fcm';
  static const String studentLogin = 'users/login';
  static const String staffLogin = 'users/login';

  static const String loginGetOtp = 'users/login/send-otp';
  static const String loginVerifyOtp = 'users/login/verify-otp';

  static const String adminDashboard = 'dashboard/complete';
  static const String studentDashboard = 'dashboard/students/complete';
  static const String login = 'login';
  static const String studentFeed = 'students/feed';
  static const String adminHolidays = 'holidays';
  static const String adminPosts = 'posts';
  static const String adminStaffs = 'admin/staffs';
  static const String staffUsers = 'users/role/STAFF';
  static const String adminStudents = 'student-assignments/academic-year/active/unassigned-students';
  static const String adminStudentsClass = 'student-assignments/class';
  static const String staffAttendance = 'staff/attendance';

  static const String complaints = "complaints";
  static const String addComplaint = "complaints";
  static const String updateComplaintStatus = "complaints/status";
  static const String addComplaintComment = "complaints/comment";

  static const String books = 'books';
  static const String addBook = 'books/add';
  static const String issueBook = 'books/issue';
  static const String returnBook = 'books/return';
  static const String issuedBooks = 'books/issued';

  static const String studentAdmission = 'users';
  static const String staffRegistration = 'users';
  static const String staffDelete = 'admin/staff/delete';

  static const String subjects = 'subjects';
  static const String exams = 'exams';
  static const String examsClass = 'exams/class';
  static const String examsByName = 'exams/examsByName';
  static const String classByExamsName = 'exams/classByExamName';
  static const String examsByClassAndExamsName = 'exams/examsByClassAndExamName';

  static const String configuration = 'school-config/1';

  static const String features = 'admin/features';
  static const String staff = 'admin/staffs/permissions';

  static const String rules = 'rules-and-regulations';
  static const String uploadLogo = 'files/upload/profile';

  static const String userProfile = 'users';
  static const String feesStructures = 'fees-structures';
  static const String classes = 'classes';
  static const String academicYears = 'academic-years';
  static const String studentFees = 'student-fees';
  static const String feePayments = 'fee-payments';
}