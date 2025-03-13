import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/fees.dart';

/*class FeesRepository {
  final String baseUrl = "https://yourapi.com/api/fees";

  Future<List<Fees>> fetchFees() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Fees.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load fees data");
    }
  }

  Future<void> addFees(Fees fees) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(fees.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception("Failed to add fees");
    }
  }

  Future<void> updateFees(Fees fees) async {
    final response = await http.put(
      Uri.parse("$baseUrl/${fees.id}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(fees.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update fees");
    }
  }

  Future<void> deleteFees(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete fees");
    }
  }
}*/

import 'dart:convert';
import 'package:http/http.dart' as http;

class FeesRepository {
  final String baseUrl = "https://yourapi.com/api/fees";

  Future<Map<String, AcademicYearFees>> fetchFees() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulating API delay

    final Map<String, dynamic> sampleResponse = {
      "2024": {
        "9th Grade": {
          "totalFees": 18000,
          "breakdown": [
            { "feeType": "Tuition", "amount": 14000 },
            { "feeType": "Transport", "amount": 4000 }
          ]
        },
        "10th Grade": {
          "totalFees": 25000,
          "breakdown": [
            { "feeType": "Tuition", "amount": 17000 },
            { "feeType": "Hostel", "amount": 8000 }
          ]
        }
      },
      "2025": {
        "9th Grade": {
          "totalFees": 20000,
          "breakdown": [
            { "feeType": "Tuition", "amount": 15000 },
            { "feeType": "Transport", "amount": 5000 }
          ]
        },
        "10th Grade": {
          "totalFees": 30000,
          "breakdown": [
            { "feeType": "Tuition", "amount": 18000 },
            { "feeType": "Hostel", "amount": 12000 }
          ]
        }
      }
    };

    Map<String, AcademicYearFees> academicYearFees = {};
    sampleResponse.forEach((year, data) {
      academicYearFees[year] = AcademicYearFees.fromJson(data);
    });

    return academicYearFees;
  }
}


