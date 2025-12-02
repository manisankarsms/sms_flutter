import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../bloc/student_fees/student_fees_bloc.dart';
import '../bloc/student_fees/student_fees_event.dart';
import '../bloc/student_fees/student_fees_state.dart';
import '../models/class.dart';
import '../models/user.dart';
import '../utils/fee_report_generator.dart';

class FeeReportsScreen extends StatefulWidget {
  final User user;

  const FeeReportsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FeeReportsScreen> createState() => _FeeReportsScreenState();
}

class _FeeReportsScreenState extends State<FeeReportsScreen> {
  String _selectedReportType = 'monthly';
  Class? _selectedClass;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  DateTimeRange? _selectedDateRange;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    context.read<StudentFeesBloc>().add(LoadStudentFeesData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Reports'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportTypeSelection(),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 20),
            _buildReportPreview(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _buildReportTypeChip('monthly', 'Monthly Report'),
                _buildReportTypeChip('class', 'Class-wise Report'),
                _buildReportTypeChip('student', 'Student Report'),
                _buildReportTypeChip('defaulters', 'Defaulters Report'),
                _buildReportTypeChip('collection', 'Collection Report'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeChip(String type, String label) {
    final isSelected = _selectedReportType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedReportType = type);
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Class Selection
            BlocBuilder<StudentFeesBloc, StudentFeesState>(
              builder: (context, state) {
                if (state is StudentFeesLoaded) {
                  return DropdownButtonFormField<Class>(
                    value: _selectedClass,
                    decoration: const InputDecoration(
                      labelText: 'Select Class (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                    ),
                    items: [
                      const DropdownMenuItem<Class>(
                        value: null,
                        child: Text('All Classes'),
                      ),
                      ...state.classes.map((classModel) {
                        return DropdownMenuItem<Class>(
                          value: classModel,
                          child: Text('${classModel.className} - ${classModel.sectionName}'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedClass = value);
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),

            const SizedBox(height: 16),

            // Month Selection (for monthly reports)
            if (_selectedReportType == 'monthly') ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Month (YYYY-MM)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                controller: TextEditingController(text: _selectedMonth),
                onChanged: (value) => _selectedMonth = value,
              ),
              const SizedBox(height: 16),
            ],

            // Date Range Selection (for collection reports)
            if (_selectedReportType == 'collection') ...[
              InkWell(
                onTap: _selectDateRange,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Range',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(
                    _selectedDateRange == null
                        ? 'Select date range'
                        : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status Filter
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Payment Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: ['All', 'PAID', 'PARTIALLY_PAID', 'PENDING'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Report Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            BlocBuilder<StudentFeesBloc, StudentFeesState>(
              builder: (context, state) {
                if (state is StudentFeesLoaded) {
                  return _buildPreviewContent(state);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(StudentFeesLoaded state) {
    // Filter data based on current selections
    var filteredFees = state.studentFees;

    // Apply class filter
    if (_selectedClass != null) {
      filteredFees = filteredFees.where((fee) =>
      fee.className?.contains(_selectedClass!.className) == true).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filteredFees = filteredFees.where((fee) => fee.status == _selectedStatus).toList();
    }

    // Apply month filter for monthly reports
    if (_selectedReportType == 'monthly') {
      filteredFees = filteredFees.where((fee) => fee.month == _selectedMonth).toList();
    }

    // Calculate summary
    final totalAmount = filteredFees.fold<double>(0, (sum, fee) => sum + double.parse(fee.amount));
    final paidAmount = filteredFees.fold<double>(0, (sum, fee) => sum + double.parse(fee.paidAmount));
    final pendingAmount = totalAmount - paidAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Total Records', '${filteredFees.length}'),
              ),
              Expanded(
                child: _buildSummaryItem('Total Amount', '₹${totalAmount.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Collected', '₹${paidAmount.toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildSummaryItem('Pending', '₹${pendingAmount.toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            'Collection %',
            totalAmount > 0 ? '${(paidAmount / totalAmount * 100).toStringAsFixed(1)}%' : '0%',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generatePdfReport,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateExcelReport,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _previewReport,
                icon: const Icon(Icons.visibility),
                label: const Text('Preview Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _generatePdfReport() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating PDF report...'),
            ],
          ),
        ),
      );

      final state = context.read<StudentFeesBloc>().state;
      if (state is StudentFeesLoaded) {
        final reportGenerator = FeeReportGenerator();
        final pdf = await reportGenerator.generatePdfReport(
          reportType: _selectedReportType,
          data: state.studentFees,
          filters: {
            'class': _selectedClass,
            'month': _selectedMonth,
            'status': _selectedStatus,
            'dateRange': _selectedDateRange,
          },
        );

        Navigator.of(context).pop(); // Close loading dialog

        // Show print preview
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Fee_Report_${_selectedReportType}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _generateExcelReport() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating Excel report...'),
            ],
          ),
        ),
      );

      final state = context.read<StudentFeesBloc>().state;
      if (state is StudentFeesLoaded) {
        final reportGenerator = FeeReportGenerator();
        await reportGenerator.generateExcelReport(
          reportType: _selectedReportType,
          data: state.studentFees,
          filters: {
            'class': _selectedClass,
            'month': _selectedMonth,
            'status': _selectedStatus,
            'dateRange': _selectedDateRange,
          },
        );

        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previewReport() {
    // Navigate to report preview screen or show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Report Preview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildDetailedPreview(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedPreview() {
    return BlocBuilder<StudentFeesBloc, StudentFeesState>(
      builder: (context, state) {
        if (state is StudentFeesLoaded) {
          var filteredFees = state.studentFees;

          // Apply filters (same logic as preview)
          if (_selectedClass != null) {
            filteredFees = filteredFees.where((fee) =>
            fee.className?.contains(_selectedClass!.className) == true).toList();
          }

          if (_selectedStatus != 'All') {
            filteredFees = filteredFees.where((fee) => fee.status == _selectedStatus).toList();
          }

          if (_selectedReportType == 'monthly') {
            filteredFees = filteredFees.where((fee) => fee.month == _selectedMonth).toList();
          }

          return Column(
            children: [
              // Report header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Fee Report - ${_selectedReportType.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Generated on: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Student')),
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Fee Structure')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Paid')),
                    DataColumn(label: Text('Balance')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Month')),
                  ],
                  rows: filteredFees.map((fee) {
                    final balance = double.parse(fee.amount) - double.parse(fee.paidAmount);
                    return DataRow(
                      cells: [
                        DataCell(Text(fee.studentName ?? '')),
                        DataCell(Text(fee.className ?? '')),
                        DataCell(Text(fee.feeStructureName ?? '')),
                        DataCell(Text('₹${fee.amount}')),
                        DataCell(Text('₹${fee.paidAmount}')),
                        DataCell(Text('₹${balance.toStringAsFixed(2)}')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(fee.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getStatusColor(fee.status)),
                            ),
                            child: Text(
                              fee.status,
                              style: TextStyle(
                                color: _getStatusColor(fee.status),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(fee.month)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'PARTIALLY_PAID':
        return Colors.orange;
      case 'PENDING':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}