import '../models/attendance.dart';
import '../models/user.dart';

class MockAuthRepository {
  Future<User?> signInWithMobileAndPassword(String email, String password) async {
    // Simulate authentication locally
    /*if (email == 'student' && password == 'password') {
      // Return a user object if authentication succeeds
      return User(id: '1', email: email, displayName: 'Test User', userType: 'Student');
    } else if (email == 's' && password == 's') {
      // Return a user object if authentication succeeds
      return User(id: '1', email: email, displayName: 'Test Staff', userType: 'Staff');
    } else if (email == 'a' && password == 'a') {
      // Return a user object if authentication succeeds
      return User(id: '1', email: email, displayName: 'Test Admin', userType: 'Admin');
    } else {
      // Return null if authentication fails
      return Future.error("Invalid");
    }*/
  }

 /* Future<List<Attendance>> fetchAttendance() async {
    return Future.delayed(Duration(milliseconds: 500), () {
      return [
        Attendance(date: DateTime(2024, 7, 10), eventName: 'Present'),
        Attendance(date: DateTime(2024, 7, 15), eventName: 'Absent'),
        Attendance(date: DateTime(2024, 7, 18), eventName: 'Leave'),
        Attendance(date: DateTime(2024, 7, 20), eventName: 'Present'),
      ];
    });
  }*/
}
