
import '../services/web_service.dart'; // Import your WebService class

class AttendanceRepository {
  final WebService webService;

  AttendanceRepository({required this.webService});

  // Future<List<Attendance>> fetchAttendance() async {
  //   try {
  //     // Make a GET request to fetch attendance data from the web service
  //     final Map<String, dynamic> responseData = await webService.fetchData('attendance');
  //
  //     // Extract the attendance data from the response and convert it to a list of Attendance objects
  //     final List<dynamic> attendanceJsonList = responseData['data'];
  //     final List<Attendance> attendanceList = attendanceJsonList.map((json) => Attendance.fromJson(json)).toList();
  //
  //     // Return the list of Attendance objects
  //     return attendanceList;
  //   } catch (e) {
  //     // Handle errors, such as network errors or parsing errors
  //     print('Error fetching attendance: $e');
  //     throw Exception('Failed to fetch attendance');
  //   }
  // }
}
