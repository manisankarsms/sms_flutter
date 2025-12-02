import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/fees_structures/FeePayment.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class FeePaymentsRepository {
  final WebService webService;

  FeePaymentsRepository({required this.webService});

  // Create fee payment
  Future<FeePaymentDto> createFeePayment(CreateFeePaymentRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.postData(ApiEndpoints.feePayments, requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create fee payment');
      }

      return FeePaymentDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating fee payment: $e");
      }
      throw Exception('Failed to create fee payment: $e');
    }
  }

  // Get all fee payments
  Future<List<FeePaymentDto>> getAllFeePayments() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.feePayments);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch fee payments');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeePaymentDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching fee payments: $e");
      }
      throw Exception('Failed to fetch fee payments: $e');
    }
  }

  // Get fee payment by ID
  Future<FeePaymentDto?> getFeePaymentById(String id) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/$id');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch fee payment');
      }

      return FeePaymentDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching fee payment by ID: $e");
      }
      return null;
    }
  }

  // Update fee payment
  Future<FeePaymentDto> updateFeePayment(String id, UpdateFeePaymentRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.putData('${ApiEndpoints.feePayments}/$id', requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update fee payment');
      }

      return FeePaymentDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating fee payment: $e");
      }
      throw Exception('Failed to update fee payment: $e');
    }
  }

  // Delete fee payment
  Future<void> deleteFeePayment(String id) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.feePayments}/$id');

      if (responseString.isNotEmpty) {
        final Map<String, dynamic> response = jsonDecode(responseString);
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Failed to delete fee payment');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting fee payment: $e");
      }
      throw Exception('Failed to delete fee payment: $e');
    }
  }

  // Get payments by student fee ID
  Future<List<FeePaymentDto>> getPaymentsByStudentFeeId(String studentFeeId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/student-fee/$studentFeeId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch payments');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeePaymentDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching payments by student fee ID: $e");
      }
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Get payments by student ID
  Future<List<FeePaymentDto>> getPaymentsByStudentId(String studentId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/student/$studentId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch payments');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeePaymentDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching payments by student ID: $e");
      }
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Get payments by class ID
  Future<List<FeePaymentDto>> getPaymentsByClassId(String classId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/class/$classId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch payments');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeePaymentDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching payments by class ID: $e");
      }
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Get payments by date range
  Future<List<FeePaymentDto>> getPaymentsByDateRange(String startDate, String endDate) async {
    try {
      final String responseString = await webService.fetchData(
          '${ApiEndpoints.feePayments}/date-range?startDate=${Uri.encodeComponent(startDate)}&endDate=${Uri.encodeComponent(endDate)}'
      );
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch payments');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeePaymentDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching payments by date range: $e");
      }
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Get payments by payment mode
  Future<List<FeePaymentDto>> getPaymentsByPaymentMode(String paymentMode) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/payment-mode/$paymentMode');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch payments');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeePaymentDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching payments by payment mode: $e");
      }
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Search payments
  Future<List<FeePaymentDto>> searchPayments(String query) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/search?q=${Uri.encodeComponent(query)}');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to search payments');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeePaymentDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error searching payments: $e");
      }
      throw Exception('Failed to search payments: $e');
    }
  }

  // Get daily payment report
  Future<DailyPaymentReportDto> getDailyPaymentReport(String date) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/reports/daily/$date');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch daily payment report');
      }

      return DailyPaymentReportDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching daily payment report: $e");
      }
      throw Exception('Failed to fetch daily payment report: $e');
    }
  }

  // Get monthly payment report
  Future<MonthlyPaymentReportDto> getMonthlyPaymentReport(String month) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feePayments}/reports/monthly/$month');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch monthly payment report');
      }

      return MonthlyPaymentReportDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching monthly payment report: $e");
      }
      throw Exception('Failed to fetch monthly payment report: $e');
    }
  }

  // Get class payment summary
  Future<ClassPaymentSummaryDto?> getClassPaymentSummary(String classId, String startDate, String endDate) async {
    try {
      final String responseString = await webService.fetchData(
          '${ApiEndpoints.feePayments}/class/$classId/summary?startDate=${Uri.encodeComponent(startDate)}&endDate=${Uri.encodeComponent(endDate)}'
      );
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch class payment summary');
      }

      return ClassPaymentSummaryDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching class payment summary: $e");
      }
      return null;
    }
  }

  // Bulk delete payments by student fee ID
  Future<int> deletePaymentsByStudentFeeId(String studentFeeId) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.feePayments}/student-fee/$studentFeeId/bulk');

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete payments');
      }

      return response['data']['deletedCount'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting payments by student fee ID: $e");
      }
      throw Exception('Failed to delete payments: $e');
    }
  }

  // Bulk delete payments by student ID
  Future<int> deletePaymentsByStudentId(String studentId) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.feePayments}/student/$studentId/bulk');

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete payments');
      }

      return response['data']['deletedCount'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting payments by student ID: $e");
      }
      throw Exception('Failed to delete payments: $e');
    }
  }

  // Get payment statistics
  Future<PaymentStatisticsDto> getPaymentStatistics({
    String? classId,
    String? month,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String endpoint = '${ApiEndpoints.feePayments}/statistics';
      List<String> queryParams = [];

      if (classId != null) {
        queryParams.add('classId=${Uri.encodeComponent(classId)}');
      }
      if (month != null) {
        queryParams.add('month=${Uri.encodeComponent(month)}');
      }
      if (startDate != null) {
        queryParams.add('startDate=${Uri.encodeComponent(startDate)}');
      }
      if (endDate != null) {
        queryParams.add('endDate=${Uri.encodeComponent(endDate)}');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final String responseString = await webService.fetchData(endpoint);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch payment statistics');
      }

      return PaymentStatisticsDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching payment statistics: $e");
      }
      throw Exception('Failed to fetch payment statistics: $e');
    }
  }
}