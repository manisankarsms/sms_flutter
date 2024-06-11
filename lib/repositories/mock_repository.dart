import '../models/attendance.dart';
import '../models/user.dart';

class MockAuthRepository {
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // Simulate authentication locally
    if (email == 'student' && password == 'password') {
      // Return a user object if authentication succeeds
      return User(id: '1', email: email, displayName: 'Test User');
    } else {
      // Return null if authentication fails
      return Future.error("Invalid");
    }
  }

  Future<List<Attendance>> fetchAttendance() async {
    // Simulate fetching data from a local source (e.g., hardcoded list)
    return Future.delayed(Duration(milliseconds: 0), () {
      return [
        Attendance(date: DateTime(2024, 2, 10), eventName: 'Event 1'),
        Attendance(date: DateTime(2024, 2, 15), eventName: 'Event 2'),
        Attendance(date: DateTime(2024, 2, 18), eventName: 'Event 3'),
        Attendance(date: DateTime(2024, 2, 20), eventName: 'Event 4'),
        // Add more sample data as needed
      ];
    });
  }
}
