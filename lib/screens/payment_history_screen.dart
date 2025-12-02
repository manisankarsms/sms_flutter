// ================================
// lib/screens/payment_history_screen.dart
// ================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/student_fees/student_fees_bloc.dart';
import '../bloc/student_fees/student_fees_event.dart';
import '../bloc/student_fees/student_fees_state.dart';
import '../models/fees_structures/FeePayment.dart';
import '../models/user.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final User user;
  final String? studentId;
  final String? studentFeeId;

  const PaymentHistoryScreen({
    Key? key,
    required this.user,
    this.studentId,
    this.studentFeeId,
  }) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPaymentMode = 'All';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPaymentHistory() {
    context.read<StudentFeesBloc>().add(LoadPaymentHistory(
      studentId: widget.studentId,
      studentFeeId: widget.studentFeeId,
      startDate: _selectedDateRange?.start.toIso8601String(),
      endDate: _selectedDateRange?.end.toIso8601String(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentId != null
            ? 'Student Payment History'
            : 'All Payment History'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadPaymentHistory,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: BlocBuilder<StudentFeesBloc, StudentFeesState>(
              builder: (context, state) {
                if (state is StudentFeesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StudentFeesLoaded) {
                  final filteredPayments = _filterPayments(state.payments);

                  if (filteredPayments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadPaymentHistory(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPayments.length,
                      itemBuilder: (context, index) {
                        return _buildPaymentCard(filteredPayments[index]);
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate back to fee assignment to record new payment
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.add),
        tooltip: 'Record New Payment',
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search payments...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              hintText: 'Student name, receipt number, etc.',
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPaymentMode,
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All', 'CASH', 'ONLINE', 'BANK_TRANSFER', 'UPI', 'CARD']
                      .map((mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPaymentMode = value!);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date Range',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    child: Text(
                      _selectedDateRange == null
                          ? 'All Dates'
                          : '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                      style: TextStyle(
                        color: _selectedDateRange == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedDateRange != null || _selectedPaymentMode != 'All' || _searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Active Filters: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_selectedPaymentMode != 'All')
                        Chip(
                          label: Text(_selectedPaymentMode),
                          onDeleted: () => setState(() => _selectedPaymentMode = 'All'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ),
                      if (_selectedDateRange != null)
                        Chip(
                          label: const Text('Date Range'),
                          onDeleted: () => setState(() => _selectedDateRange = null),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ),
                      if (_searchQuery.isNotEmpty)
                        Chip(
                          label: Text('Search: $_searchQuery'),
                          onDeleted: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(FeePaymentDto payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showPaymentDetails(payment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPaymentModeIcon(payment.paymentMode),
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${payment.amount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          payment.studentName ?? 'Unknown Student',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          payment.feeStructureName ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          payment.paymentMode,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(payment.paymentDate),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (payment.className?.isNotEmpty == true)
                          _buildInfoChip('Class', payment.className!),
                        if (payment.month?.isNotEmpty == true)
                          _buildInfoChip('Month', payment.month!),
                      ],
                    ),
                  ),
                  if (payment.receiptNumber?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Receipt: ${payment.receiptNumber}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (payment.remarks?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          payment.remarks!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Records',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedPaymentMode != 'All' || _selectedDateRange != null
                ? 'No payments found matching your filters'
                : 'Payment history will appear here once fees are paid',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedPaymentMode != 'All' || _selectedDateRange != null) ...[
            ElevatedButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.payment),
              label: const Text('Record Payment'),
            ),
          ],
        ],
      ),
    );
  }

  List<FeePaymentDto> _filterPayments(List<FeePaymentDto> payments) {
    var filtered = payments;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((payment) {
        final query = _searchQuery.toLowerCase();
        return payment.studentName?.toLowerCase().contains(query) == true ||
            payment.feeStructureName?.toLowerCase().contains(query) == true ||
            payment.receiptNumber?.toLowerCase().contains(query) == true ||
            payment.remarks?.toLowerCase().contains(query) == true ||
            payment.className?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Payment mode filter
    if (_selectedPaymentMode != 'All') {
      filtered = filtered.where((payment) =>
      payment.paymentMode == _selectedPaymentMode).toList();
    }

    // Date range filter
    if (_selectedDateRange != null) {
      filtered = filtered.where((payment) {
        try {
          final paymentDate = DateTime.parse(payment.paymentDate.split('T')[0]);
          return paymentDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
              paymentDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Sort by payment date (newest first)
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.paymentDate);
        final dateB = DateTime.parse(b.paymentDate);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return filtered;
  }

  IconData _getPaymentModeIcon(String paymentMode) {
    switch (paymentMode) {
      case 'CASH':
        return Icons.money;
      case 'ONLINE':
        return Icons.computer;
      case 'BANK_TRANSFER':
        return Icons.account_balance;
      case 'UPI':
        return Icons.qr_code;
      case 'CARD':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      helpText: 'Select Payment Date Range',
      cancelText: 'Clear',
      confirmText: 'Apply',
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedPaymentMode = 'All';
      _selectedDateRange = null;
      _searchQuery = '';
    });
    _searchController.clear();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Date Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickDateFilter('Today', DateTime.now(), DateTime.now()),
                  _buildQuickDateFilter('Yesterday',
                      DateTime.now().subtract(const Duration(days: 1)),
                      DateTime.now().subtract(const Duration(days: 1))),
                  _buildQuickDateFilter('This Week',
                      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
                      DateTime.now()),
                  _buildQuickDateFilter('This Month',
                      DateTime(DateTime.now().year, DateTime.now().month, 1),
                      DateTime.now()),
                  _buildQuickDateFilter('Last 30 Days',
                      DateTime.now().subtract(const Duration(days: 30)),
                      DateTime.now()),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Amount Range:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Coming soon...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateFilter(String label, DateTime start, DateTime end) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() => _selectedDateRange = DateTimeRange(start: start, end: end));
        Navigator.pop(context);
      },
    );
  }

  void _showPaymentDetails(FeePaymentDto payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getPaymentModeIcon(payment.paymentMode), color: Colors.green),
            const SizedBox(width: 8),
            const Text('Payment Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Student', payment.studentName ?? 'N/A'),
              _buildDetailRow('Amount', '₹${payment.amount}'),
              _buildDetailRow('Payment Mode', payment.paymentMode),
              _buildDetailRow('Payment Date', _formatDateTime(payment.paymentDate)),
              _buildDetailRow('Fee Structure', payment.feeStructureName ?? 'N/A'),
              _buildDetailRow('Class', payment.className ?? 'N/A'),
              _buildDetailRow('Month', payment.month ?? 'N/A'),
              if (payment.receiptNumber?.isNotEmpty == true)
                _buildDetailRow('Receipt Number', payment.receiptNumber!),
              if (payment.remarks?.isNotEmpty == true)
                _buildDetailRow('Remarks', payment.remarks!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showReceiptDialog(payment);
            },
            icon: const Icon(Icons.receipt),
            label: const Text('View Receipt'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showReceiptDialog(FeePaymentDto payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Receipt'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Receipt Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'PAYMENT RECEIPT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (payment.receiptNumber?.isNotEmpty == true)
                      Text(
                        'Receipt #: ${payment.receiptNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    Text(
                      'Date: ${_formatDateTime(payment.paymentDate)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Receipt Details
              Column(
                children: [
                  _buildReceiptRow('Student Name', payment.studentName ?? 'N/A'),
                  _buildReceiptRow('Fee Structure', payment.feeStructureName ?? 'N/A'),
                  _buildReceiptRow('Class', payment.className ?? 'N/A'),
                  _buildReceiptRow('Month', payment.month ?? 'N/A'),
                  _buildReceiptRow('Payment Mode', payment.paymentMode),
                  const Divider(),
                  _buildReceiptRow(
                    'Amount Paid',
                    '₹${payment.amount}',
                    isAmount: true,
                  ),
                  if (payment.remarks?.isNotEmpty == true)
                    _buildReceiptRow('Remarks', payment.remarks!),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () => _downloadReceipt(payment),
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
          ElevatedButton.icon(
            onPressed: () => _shareReceipt(payment),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
                color: isAmount ? Colors.green : null,
                fontSize: isAmount ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(FeePaymentDto payment) {
    // TODO: Implement receipt download as PDF
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt download feature will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _shareReceipt(FeePaymentDto payment) {
    // TODO: Implement receipt sharing
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt sharing feature will be implemented'),
        backgroundColor: Colors.green,
      ),
    );
  }
}