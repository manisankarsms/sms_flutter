import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/fees_structures/StudentFeeDto.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class StudentFeesRepository {
  final WebService webService;

  StudentFeesRepository({required this.webService});

  // Create single student fee
  Future<StudentFeeDto> createStudentFee(CreateStudentFeeRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.postData(ApiEndpoints.studentFees, requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? response['description'] ?? 'Failed to create student fee');
      }

      return StudentFeeDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating student fee: $e");
      }
      throw Exception('Failed to create student fee: $e');
    }
  }

  // Create bulk student fees
  Future<List<StudentFeeDto>> createBulkStudentFees(BulkCreateStudentFeeRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.postData('${ApiEndpoints.studentFees}/bulk', requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? response['description'] ?? 'Failed to create student fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error creating bulk student fees: $e");
      }
      throw Exception('Failed to create student fees: $e');
    }
  }

  // Get all student fees
  Future<List<StudentFeeDto>> getAllStudentFees() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.studentFees);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch student fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching student fees: $e");
      }
      throw Exception('Failed to fetch student fees: $e');
    }
  }

  // Get student fee by ID
  Future<StudentFeeDto?> getStudentFeeById(String id) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/$id');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch student fee');
      }

      return StudentFeeDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching student fee by ID: $e");
      }
      return null;
    }
  }

  // Update student fee
  Future<StudentFeeDto> updateStudentFee(String id, UpdateStudentFeeRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.putData('${ApiEndpoints.studentFees}/$id', requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update student fee');
      }

      return StudentFeeDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating student fee: $e");
      }
      throw Exception('Failed to update student fee: $e');
    }
  }

  // Delete student fee
  Future<void> deleteStudentFee(String id) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.studentFees}/$id');

      if (responseString.isNotEmpty) {
        final Map<String, dynamic> response = jsonDecode(responseString);
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Failed to delete student fee');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting student fee: $e");
      }
      throw Exception('Failed to delete student fee: $e');
    }
  }

  // Pay student fee
  Future<StudentFeeDto> payStudentFee(String id, PayFeeRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.postData('${ApiEndpoints.studentFees}/$id/pay', requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to record payment');
      }

      return StudentFeeDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error recording payment: $e");
      }
      throw Exception('Failed to record payment: $e');
    }
  }

  // Get student fees by student ID
  Future<List<StudentFeeDto>> getStudentFeesByStudentId(String studentId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/student/$studentId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch student fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching student fees by student ID: $e");
      }
      throw Exception('Failed to fetch student fees: $e');
    }
  }

  // Get student fees by class ID
  Future<List<StudentFeeDto>> getStudentFeesByClassId(String classId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/class/$classId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch student fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching student fees by class ID: $e");
      }
      throw Exception('Failed to fetch student fees: $e');
    }
  }

  // Get student fees by month
  Future<List<StudentFeeDto>> getStudentFeesByMonth(String month) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/month/$month');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch student fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching student fees by month: $e");
      }
      throw Exception('Failed to fetch student fees: $e');
    }
  }

  // Get student fees by status
  Future<List<StudentFeeDto>> getStudentFeesByStatus(String status) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/status/$status');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch student fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching student fees by status: $e");
      }
      throw Exception('Failed to fetch student fees: $e');
    }
  }

  // Get student fees summary
  Future<StudentFeesSummaryDto?> getStudentFeesSummary(String studentId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/student/$studentId/summary');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch student fees summary');
      }

      return StudentFeesSummaryDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching student fees summary: $e");
      }
      return null;
    }
  }

  // Get monthly fee report
  Future<MonthlyFeeReportDto> getMonthlyFeeReport(String month) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/reports/monthly/$month');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch monthly fee report');
      }

      return MonthlyFeeReportDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching monthly fee report: $e");
      }
      throw Exception('Failed to fetch monthly fee report: $e');
    }
  }

  // Get class fees summary
  Future<ClassFeesSummaryDto?> getClassFeesSummary(String classId, String month) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/class/$classId/month/$month/summary');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch class fees summary');
      }

      return ClassFeesSummaryDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching class fees summary: $e");
      }
      return null;
    }
  }

  // Search student fees
  Future<List<StudentFeeDto>> searchStudentFees(String query) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.studentFees}/search?q=${Uri.encodeComponent(query)}');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to search student fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error searching student fees: $e");
      }
      throw Exception('Failed to search student fees: $e');
    }
  }

  // Get defaulters
  Future<List<StudentFeeDto>> getDefaulters({String? classId, String? month}) async {
    try {
      String endpoint = '${ApiEndpoints.studentFees}/defaulters';
      List<String> queryParams = [];

      if (classId != null) {
        queryParams.add('classId=${Uri.encodeComponent(classId)}');
      }
      if (month != null) {
        queryParams.add('month=${Uri.encodeComponent(month)}');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final String responseString = await webService.fetchData(endpoint);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch defaulters');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => StudentFeeDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching defaulters: $e");
      }
      throw Exception('Failed to fetch defaulters: $e');
    }
  }

  // Remove student fees (bulk delete)
  Future<int> removeStudentFees(String studentId) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.studentFees}/student/$studentId');

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to remove student fees');
      }

      return response['data']['deletedCount'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("Error removing student fees: $e");
      }
      throw Exception('Failed to remove student fees: $e');
    }
  }

  // Remove fees by structure
  Future<int> removeFeesByStructure(String feeStructureId) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.studentFees}/structure/$feeStructureId');

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to remove fees by structure');
      }

      return response['data']['deletedCount'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("Error removing fees by structure: $e");
      }
      throw Exception('Failed to remove fees by structure: $e');
    }
  }
}