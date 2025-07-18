import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sms/models/class.dart';
import '../models/AcademicYear.dart';
import '../models/fees_structures/BulkCreateFeesStructureRequest.dart';
import '../models/fees_structures/ClassFeesStructureDto.dart';
import '../models/fees_structures/CreateFeesStructureRequest.dart';
import '../models/fees_structures/FeesStructureDto.dart';
import '../models/fees_structures/FeesStructureSummaryDto.dart';
import '../models/fees_structures/UpdateFeesStructureRequest.dart';
import '../services/web_service.dart';
import '../utils/constants.dart';

class FeesStructureRepository {
  final WebService webService;

  FeesStructureRepository({required this.webService});

  // Create single fee structure
  Future<FeesStructureDto> createFeesStructure(CreateFeesStructureRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.postData(ApiEndpoints.feesStructures, requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? response['description'] ?? 'Failed to create fee structure');
      }

      return FeesStructureDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating fee structure: $e");
      }
      throw Exception('Failed to create fee structure: $e');
    }
  }

  // Create bulk fee structures
  Future<List<FeesStructureDto>> createBulkFeesStructures(BulkCreateFeesStructureRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.postData('${ApiEndpoints.feesStructures}/bulk', requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? response['description'] ?? 'Failed to create fee structures');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error creating bulk fee structures: $e");
      }
      throw Exception('Failed to create fee structures: $e');
    }
  }

  // Get all fee structures
  Future<List<FeesStructureDto>> getAllFeesStructures() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.feesStructures);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch fee structures');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching fee structures: $e");
      }
      throw Exception('Failed to fetch fee structures: $e');
    }
  }

  // Get fee structures by academic year
  Future<List<FeesStructureDto>> getFeesStructuresByAcademicYear(String academicYearId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feesStructures}/academic-year/$academicYearId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch fee structures');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching fee structures by academic year: $e");
      }
      throw Exception('Failed to fetch fee structures: $e');
    }
  }

  // Get fee structures by class
  Future<List<FeesStructureDto>> getFeesStructuresByClass(String classId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feesStructures}/class/$classId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch fee structures');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching fee structures by class: $e");
      }
      throw Exception('Failed to fetch fee structures: $e');
    }
  }

  // Get fee structures by class and academic year
  Future<List<FeesStructureDto>> getFeesStructuresByClassAndAcademicYear(String classId, String academicYearId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feesStructures}/class/$classId/academic-year/$academicYearId');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch fee structures');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching fee structures by class and academic year: $e");
      }
      throw Exception('Failed to fetch fee structures: $e');
    }
  }

  // Get class fee structures summary
  Future<List<ClassFeesStructureDto>> getClassFeesStructures(String academicYearId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feesStructures}/academic-year/$academicYearId/class-summary');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch class fee structures');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => ClassFeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching class fee structures: $e");
      }
      throw Exception('Failed to fetch class fee structures: $e');
    }
  }

  // Get fee structure summary
  Future<FeesStructureSummaryDto> getFeesStructureSummary(String academicYearId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feesStructures}/academic-year/$academicYearId/summary');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch fee structure summary');
      }

      return FeesStructureSummaryDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching fee structure summary: $e");
      }
      throw Exception('Failed to fetch fee structure summary: $e');
    }
  }

  // Get mandatory fees
  Future<List<FeesStructureDto>> getMandatoryFees(String classId, String academicYearId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feesStructures}/class/$classId/academic-year/$academicYearId/mandatory');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch mandatory fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching mandatory fees: $e");
      }
      throw Exception('Failed to fetch mandatory fees: $e');
    }
  }

  // Get optional fees
  Future<List<FeesStructureDto>> getOptionalFees(String classId, String academicYearId) async {
    try {
      final String responseString = await webService.fetchData('${ApiEndpoints.feesStructures}/class/$classId/academic-year/$academicYearId/optional');
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch optional fees');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => FeesStructureDto.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching optional fees: $e");
      }
      throw Exception('Failed to fetch optional fees: $e');
    }
  }

  // Update fee structure
  Future<FeesStructureDto> updateFeesStructure(String id, UpdateFeesStructureRequest request) async {
    try {
      final String requestJson = jsonEncode(request.toJson());
      final responseString = await webService.putData('${ApiEndpoints.feesStructures}/$id', requestJson);

      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update fee structure');
      }

      return FeesStructureDto.fromJson(response['data']);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating fee structure: $e");
      }
      throw Exception('Failed to update fee structure: $e');
    }
  }

  // Delete fee structure
  Future<void> deleteFeesStructure(String id) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.feesStructures}/$id');

      if (responseString.isNotEmpty) {
        final Map<String, dynamic> response = jsonDecode(responseString);
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Failed to delete fee structure');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting fee structure: $e");
      }
      throw Exception('Failed to delete fee structure: $e');
    }
  }

  // Delete all fee structures for a class
  Future<void> deleteFeesStructuresByClass(String classId) async {
    try {
      final responseString = await webService.deleteData('${ApiEndpoints.feesStructures}/class/$classId');

      if (responseString.isNotEmpty) {
        final Map<String, dynamic> response = jsonDecode(responseString);
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Failed to delete fee structures');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting fee structures by class: $e");
      }
      throw Exception('Failed to delete fee structures: $e');
    }
  }

  // Get classes - This would typically come from a classes repository
  Future<List<Class>> getClasses() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.classes);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch classes');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching classes: $e");
      }
      throw Exception('Failed to fetch classes: $e');
    }
  }

  // Get academic years - This would typically come from an academic years repository
  Future<List<AcademicYear>> getAcademicYears() async {
    try {
      final String responseString = await webService.fetchData(ApiEndpoints.academicYears);
      final Map<String, dynamic> response = jsonDecode(responseString);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch academic years');
      }

      final List<dynamic> dataList = response['data'];
      return dataList.map((json) => AcademicYear.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching academic years: $e");
      }
      throw Exception('Failed to fetch academic years: $e');
    }
  }

  // Get active academic year
  Future<AcademicYear?> getActiveAcademicYear() async {
    try {
      final academicYears = await getAcademicYears();

      if (academicYears.isEmpty) return null;

      return academicYears.firstWhere(
            (year) => year.isActive,
        orElse: () => academicYears.first, // Safe now, list is not empty
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error getting active academic year: $e");
      }
      return null;
    }
  }
}