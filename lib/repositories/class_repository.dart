// repository/class_repository.dart
import '../models/class.dart';

// repository/class_repository.dart
import '../models/class.dart';
import '../services/web_service.dart';

class ClassRepository {
  final WebService webService;

  ClassRepository({required this.webService});

  Future<List<Class>> fetchClasses() async {
    try {
      final Map<String, dynamic> response = await webService.fetchData('admin/classes');
      print("API Response: $response"); // Debugging

      final List<dynamic> classesJson = response['classes'];
      return classesJson.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching classes: $e"); // Debugging
      throw Exception('Failed to fetch classes: $e');
    }
  }


  /*Future<void> addClass(Class newClass) async {
    try {
      await webService.postData('classes', newClass.toJson());
    } catch (e) {
      throw Exception('Failed to add class: $e');
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      await webService.deleteData('classes/$classId');
    } catch (e) {
      throw Exception('Failed to delete class: $e');
    }
  }
}*/

  Future<void> addClass(Class newClass) async {
    // Simulate adding a class to a database
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> deleteClass(String classId) async {
    // Simulate deleting a class from a database
    await Future.delayed(Duration(seconds: 1));
  }
}
