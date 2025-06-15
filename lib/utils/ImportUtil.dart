import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class ImportUtil {
  /// Pick and read Excel/CSV file for student data
  static Future<List<Map<String, dynamic>>?> pickAndReadStudentFile() async {
    try {
      // Use withData: true for web compatibility
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
        withData: true, // This ensures bytes are available on web
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        if (kDebugMode) {
          print('File picked: $fileName, Size: ${bytes.length} bytes');
        }

        if (fileName.toLowerCase().endsWith('.csv')) {
          return _parseCSVData(bytes);
        } else if (fileName.toLowerCase().endsWith('.xlsx') ||
            fileName.toLowerCase().endsWith('.xls')) {
          return _parseExcelData(bytes);
        } else {
          throw Exception('Unsupported file format. Please use CSV or Excel files.');
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('File picking error: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>?> pickAndReadStudentFileForWeb() async {
    final completer = Completer<List<Map<String, dynamic>>?>();

    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv, .xlsx, .xls';
    uploadInput.multiple = false;
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();

        reader.onLoadEnd.listen((event) {
          final result = reader.result;
          if (result is Uint8List || result is List<int>) {
            final bytes = Uint8List.fromList(result as List<int>);
            final fileName = file.name.toLowerCase();

            if (kDebugMode) {
              print('File picked: $fileName, Size: ${bytes.length} bytes');
            }

            if (fileName.endsWith('.csv')) {
              completer.complete(_parseCSVData(bytes));
            } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
              completer.complete(_parseExcelData(bytes));
            } else {
              completer.completeError(Exception('Unsupported file format.'));
            }
          } else {
            completer.completeError(Exception('Invalid file data.'));
          }
        });

        reader.readAsArrayBuffer(file);
      } else {
        completer.complete(null); // User cancelled
      }
    });

    return completer.future;
  }

  /// Parse Excel data to student format
  static List<Map<String, dynamic>>? _parseExcelData(Uint8List bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];

      if (sheet == null || sheet.rows.isEmpty) return null;

      // Extract headers from first row - properly get cell values
      final headers = sheet.rows.first
          .map((cell) => _getCellValue(cell)?.toString().toLowerCase().trim() ?? '')
          .toList();

      if (kDebugMode) {
        print('Excel headers found: $headers');
      }

      final students = <Map<String, dynamic>>[];

      // Process data rows (skip header)
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        // Convert Data objects to actual values
        final rowValues = row.map((cell) => _getCellValue(cell)).toList();

        if (kDebugMode) {
          print('Processing row $i: $rowValues');
        }

        final studentData = _mapRowToStudent(headers, rowValues);
        if (studentData != null) {
          students.add(studentData);
          if (kDebugMode) {
            print('Successfully mapped student: $studentData');
          }
        } else {
          if (kDebugMode) {
            print('Failed to map student data for row $i');
          }
        }
      }

      return students;
    } catch (e) {
      if (kDebugMode) print('Excel parsing error: $e');
      rethrow;
    }
  }

  /// Extract actual value from Excel Data cell
  static dynamic _getCellValue(Data? cell) {
    if (cell == null) return null;

    // Handle different cell value types
    final value = cell.value;
    if (value == null) return null;

    // Convert to string and trim
    return value.toString().trim();
  }

  /// Parse CSV data to student format
  static List<Map<String, dynamic>>? _parseCSVData(Uint8List bytes) {
    try {
      final csvString = utf8.decode(bytes);
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty) return null;

      // First row as headers
      final headers = csvData.first
          .map((cell) => cell?.toString().toLowerCase().trim() ?? '')
          .toList();

      if (kDebugMode) {
        print('CSV headers found: $headers');
      }

      final students = <Map<String, dynamic>>[];

      // Process data rows
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];

        if (kDebugMode) {
          print('Processing CSV row $i: $row');
        }

        final studentData = _mapRowToStudent(headers, row);
        if (studentData != null) {
          students.add(studentData);
          if (kDebugMode) {
            print('Successfully mapped student: $studentData');
          }
        }
      }

      return students;
    } catch (e) {
      if (kDebugMode) print('CSV parsing error: $e');
      rethrow;
    }
  }

  /// Map row data to student object based on headers
  static Map<String, dynamic>? _mapRowToStudent(List<String> headers, List<dynamic> row) {
    try {
      final studentData = <String, dynamic>{};

      for (int i = 0; i < headers.length && i < row.length; i++) {
        final header = headers[i];
        final value = row[i]?.toString().trim();

        if (value == null || value.isEmpty) continue;

        // Map headers to student fields
        switch (header) {
          case 'first name':
          case 'firstname':
          case 'first_name':
            studentData['firstName'] = value;
            break;
          case 'last name':
          case 'lastname':
          case 'last_name':
            studentData['lastName'] = value;
            break;
          case 'email':
          case 'email address':
          case 'email_address':
            studentData['email'] = value;
            break;
          case 'mobile':
          case 'mobile number':
          case 'mobile_number':
          case 'phone':
          case 'phone number':
            studentData['mobileNumber'] = value;
            break;
          case 'class':
          case 'grade':
          case 'standard':
            studentData['class'] = value;
            break;
          case 'password':
            studentData['password'] = value;
            break;
        }
      }

      if (kDebugMode) {
        print('Mapped student data: $studentData');
      }

      // Validate required fields
      if (studentData.containsKey('firstName') &&
          studentData.containsKey('lastName') &&
          studentData.containsKey('email')) {

        // Validate email format
        final email = studentData['email'] as String;
        if (!_isValidEmail(email)) {
          if (kDebugMode) {
            print('Invalid email format: $email');
          }
          return null;
        }

        // Set default values
        studentData['role'] = 'STUDENT';
        if (!studentData.containsKey('password')) {
          studentData['password'] = _generateDefaultPassword();
        }

        return studentData;
      } else {
        if (kDebugMode) {
          print('Missing required fields. Available fields: ${studentData.keys}');
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('Row mapping error: $e');
      return null;
    }
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Generate a short random string for uniqueness
  static String _generateUniqueId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generate default password for students
  static String _generateDefaultPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create sample template for download
  static List<List<dynamic>> getSampleStudentTemplate() {
    return [
      ['First Name', 'Last Name', 'Email', 'Mobile Number', 'Class', 'Password'],
      ['John', 'Doe', 'john.doe@example.com', '9876543210', '10', 'password123'],
      ['Jane', 'Smith', 'jane.smith@example.com', '9876543211', '11', 'password456'],
      ['Mike', 'Johnson', 'mike.johnson@example.com', '9876543212', '12', 'password789'],
    ];
  }
}