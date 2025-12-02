import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/class.dart';
import '../models/fees_structures/StudentFeeDto.dart';

class FeeReportGenerator {
  Future<pw.Document> generatePdfReport({
    required String reportType,
    required List<StudentFeeDto> data,
    required Map<String, dynamic> filters,
  }) async {
    final pdf = pw.Document();

    // Filter data based on provided filters
    final filteredData = _filterData(data, filters);

    // Calculate summary
    final summary = _calculateSummary(filteredData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildPdfHeader(reportType, filters),
            pw.SizedBox(height: 20),
            _buildPdfSummary(summary),
            pw.SizedBox(height: 20),
            _buildPdfTable(filteredData),
          ];
        },
      ),
    );

    return pdf;
  }

  Future<void> generateExcelReport({
    required String reportType,
    required List<StudentFeeDto> data,
    required Map<String, dynamic> filters,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Fee Report'];

    // Filter data
    final filteredData = _filterData(data, filters);

    // Add headers
    final headers = [
      'Student Name',
      'Student Email',
      'Class',
      'Fee Structure',
      'Amount',
      'Paid Amount',
      'Balance',
      'Status',
      'Month',
      'Due Date',
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
    }

    // Add data rows
    for (int i = 0; i < filteredData.length; i++) {
      final fee = filteredData[i];
      final balance = double.parse(fee.amount) - double.parse(fee.paidAmount);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = fee.studentName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = fee.studentEmail;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = fee.className;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = fee.feeStructureName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = double.parse(fee.amount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = double.parse(fee.paidAmount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = balance;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = fee.status;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1)).value = fee.month;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1)).value = fee.dueDate;
    }

    // Save and share file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'Fee_Report_${reportType}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    // Share the file
    await Share.shareXFiles([XFile(filePath)], text: 'Fee Report');
  }

  List<StudentFeeDto> _filterData(List<StudentFeeDto> data, Map<String, dynamic> filters) {
    var filtered = data;

    // Apply class filter
    final Class? selectedClass = filters['class'];
    if (selectedClass != null) {
      filtered = filtered.where((fee) =>
      fee.className?.contains(selectedClass.className) == true).toList();
    }

    // Apply status filter
    final String status = filters['status'] ?? 'All';
    if (status != 'All') {
      filtered = filtered.where((fee) => fee.status == status).toList();
    }

    // Apply month filter
    final String? month = filters['month'];
    if (month != null && month.isNotEmpty) {
      filtered = filtered.where((fee) => fee.month == month).toList();
    }

    // Apply date range filter
    final DateTimeRange? dateRange = filters['dateRange'];
    if (dateRange != null) {
      filtered = filtered.where((fee) {
        final dueDate = DateTime.parse(fee.dueDate);
        return dueDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            dueDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  Map<String, dynamic> _calculateSummary(List<StudentFeeDto> data) {
    final totalAmount = data.fold<double>(0, (sum, fee) => sum + double.parse(fee.amount));
    final paidAmount = data.fold<double>(0, (sum, fee) => sum + double.parse(fee.paidAmount));
    final pendingAmount = totalAmount - paidAmount;

    final paidCount = data.where((fee) => fee.status == 'PAID').length;
    final partiallyPaidCount = data.where((fee) => fee.status == 'PARTIALLY_PAID').length;
    final pendingCount = data.where((fee) => fee.status == 'PENDING').length;

    return {
      'totalRecords': data.length,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'paidCount': paidCount,
      'partiallyPaidCount': partiallyPaidCount,
      'pendingCount': pendingCount,
      'collectionPercentage': totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0,
    };
  }

  pw.Widget _buildPdfHeader(String reportType, Map<String, dynamic> filters) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Fee Report - ${reportType.toUpperCase()}',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          if (filters['class'] != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Class: ${(filters['class'] as Class).className} - ${(filters['class'] as Class).sectionName}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
          if (filters['month'] != null && (filters['month'] as String).isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Month: ${filters['month']}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(Map<String, dynamic> summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildPdfSummaryItem('Total Records', '${summary['totalRecords']}'),
              _buildPdfSummaryItem('Total Amount', '₹${(summary['totalAmount'] as double).toStringAsFixed(2)}'),
              _buildPdfSummaryItem('Collected', '₹${(summary['paidAmount'] as double).toStringAsFixed(2)}'),
              _buildPdfSummaryItem('Pending', '₹${(summary['pendingAmount'] as double).toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTable(List<StudentFeeDto> data) {
    return pw.Table.fromTextArray(
      headers: [
        'Student',
        'Class',
        'Fee Structure',
        'Amount',
        'Paid',
        'Balance',
        'Status',
        'Month',
      ],
      data: data.map((fee) {
        final balance = double.parse(fee.amount) - double.parse(fee.paidAmount);
        return [
          fee.studentName ?? '',
          fee.className ?? '',
          fee.feeStructureName ?? '',
          '₹${fee.amount}',
          '₹${fee.paidAmount}',
          '₹${balance.toStringAsFixed(2)}',
          fee.status,
          fee.month,
        ];
      }).toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
      },
    );
  }
}