import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/student_fees/student_fees_bloc.dart';
import '../bloc/student_fees/student_fees_event.dart';
import '../bloc/student_fees/student_fees_state.dart';
import '../models/class.dart';
import '../models/fees_structures/FeesStructureDto.dart';
import '../models/fees_structures/StudentFeeDto.dart';
import '../models/fees_structures/FeePayment.dart';
import '../models/user.dart';
import '../widgets/screen_header.dart';

class StudentFeesAssignmentScreen extends StatefulWidget {
  final User user;

  const StudentFeesAssignmentScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StudentFeesAssignmentScreen> createState() => _StudentFeesAssignmentScreenState();
}

class _StudentFeesAssignmentScreenState extends State<StudentFeesAssignmentScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  Class? _selectedClass;
  FeesStructureDto? _selectedFeeStructure;
  List<User> _selectedStudents = [];
  List<User> _allStudents = [];
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    context.read<StudentFeesBloc>().add(LoadStudentFeesData());

    // Load payment history
    context.read<StudentFeesBloc>().add(LoadPaymentHistory());

    // Listen to tab changes to load specific data
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0: // Assign Fees Tab
            context.read<StudentFeesBloc>().add(LoadStudentFeesData());
            break;
          case 1: // Fee Status Tab
            context.read<StudentFeesBloc>().add(LoadStudentFees());
            break;
          case 2: // Payment History Tab
            context.read<StudentFeesBloc>().add(LoadPaymentHistory());
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {}); // Remove listener
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fees Management'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Assign Fees'),
            Tab(icon: Icon(Icons.payment), text: 'Fee Status'),
            Tab(icon: Icon(Icons.history), text: 'Payment History'),
          ],
        ),
      ),
      body: BlocConsumer<StudentFeesBloc, StudentFeesState>(
        listener: (context, state) {
          if (state is StudentFeesOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is StudentFeesOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAssignFeesTab(state),
              _buildFeeStatusTab(state),
              _buildPaymentHistoryTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAssignFeesTab(StudentFeesState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAssignmentForm(state),
          const SizedBox(height: 24),
          if (_selectedClass != null) _buildStudentSelection(state),
          const SizedBox(height: 24),
          if (_selectedStudents.isNotEmpty) _buildAssignmentPreview(),
        ],
      ),
    );
  }

  Widget _buildAssignmentForm(StudentFeesState state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Fee Assignment Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Class Selection
            if (state is StudentFeesLoaded)
              DropdownButtonFormField<Class>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                items: state.classes.map((classModel) {
                  return DropdownMenuItem<Class>(
                    value: classModel,
                    child: Text('${classModel.className} - ${classModel.sectionName}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                    _selectedFeeStructure = null;
                    _selectedStudents.clear();
                  });
                  if (value != null) {
                    context.read<StudentFeesBloc>().add(LoadFeeStructuresByClass(value.id));
                    context.read<StudentFeesBloc>().add(LoadStudentsByClass(value.id));
                  }
                },
                validator: (value) => value == null ? 'Please select a class' : null,
              ),

            const SizedBox(height: 16),

            // Fee Structure Selection
            if (state is StudentFeesLoaded && state.feeStructures.isNotEmpty)
              DropdownButtonFormField<FeesStructureDto>(
                value: _selectedFeeStructure,
                decoration: const InputDecoration(
                  labelText: 'Select Fee Structure',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
                items: state.feeStructures.map((feeStructure) {
                  return DropdownMenuItem<FeesStructureDto>(
                    value: feeStructure,
                    child: Text('${feeStructure.name} - ₹${feeStructure.amount}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedFeeStructure = value);
                },
                validator: (value) => value == null ? 'Please select a fee structure' : null,
              ),

            const SizedBox(height: 16),

            // Month and Due Date
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Month (YYYY-MM)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    controller: TextEditingController(text: _selectedMonth),
                    onChanged: (value) => _selectedMonth = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDueDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_selectedDueDate)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelection(StudentFeesState state) {
    if (state is! StudentFeesLoaded || state.students.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No students found for selected class.'),
        ),
      );
    }

    _allStudents = state.students;
    final filteredStudents = _allStudents.where((student) {
      return student.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Select Students',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text('${_selectedStudents.length}/${filteredStudents.length} selected'),
              ],
            ),
            const SizedBox(height: 16),

            // Search and Select All
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search students...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedStudents.length == filteredStudents.length) {
                        _selectedStudents.clear();
                      } else {
                        _selectedStudents = List.from(filteredStudents);
                      }
                    });
                  },
                  icon: Icon(_selectedStudents.length == filteredStudents.length
                      ? Icons.deselect
                      : Icons.select_all),
                  label: Text(_selectedStudents.length == filteredStudents.length
                      ? 'Deselect All'
                      : 'Select All'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Students List
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  final isSelected = _selectedStudents.contains(student);

                  return CheckboxListTile(
                    title: Text('${student.firstName} ${student.lastName}'),
                    subtitle: Text(student.email),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedStudents.add(student);
                        } else {
                          _selectedStudents.remove(student);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentPreview() {
    return Card(
      elevation: 4,
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
                  'Assignment Preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            _buildInfoRow('Class:', '${_selectedClass?.className} - ${_selectedClass?.sectionName}'),
            _buildInfoRow('Fee Structure:', '${_selectedFeeStructure?.name}'),
            _buildInfoRow('Amount:', '₹${_selectedFeeStructure?.amount}'),
            _buildInfoRow('Month:', _selectedMonth),
            _buildInfoRow('Due Date:', DateFormat('dd/MM/yyyy').format(_selectedDueDate)),
            _buildInfoRow('Students:', '${_selectedStudents.length} selected'),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canAssignFees() ? _assignFees : null,
                icon: const Icon(Icons.assignment_add),
                label: const Text('Assign Fees to Students'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeStatusTab(StudentFeesState state) {
    return Column(
      children: [
        // Filter Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search students...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // Implement search filtering
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'All',
                items: ['All', 'PAID', 'PARTIALLY_PAID', 'PENDING'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  // Implement status filtering
                },
              ),
            ],
          ),
        ),

        // Fee Status List
        Expanded(
          child: state is StudentFeesLoaded
              ? ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.studentFees.length,
            itemBuilder: (context, index) {
              final studentFee = state.studentFees[index];
              return _buildFeeStatusCard(studentFee);
            },
          )
              : const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildFeeStatusCard(StudentFeeDto studentFee) {
    final statusColor = _getStatusColor(studentFee.status);
    final balanceAmount = double.parse(studentFee.amount) - double.parse(studentFee.paidAmount);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${studentFee.studentName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    studentFee.status,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${studentFee.feeStructureName}'),
                      Text('Month: ${studentFee.month}'),
                      Text('Due: ${studentFee.dueDate}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total: ₹${studentFee.amount}'),
                    Text('Paid: ₹${studentFee.paidAmount}'),
                    Text(
                      'Balance: ₹${balanceAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: balanceAmount > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (balanceAmount > 0) ...[
                  ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(studentFee),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Record Payment'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () => _showPaymentHistory(studentFee),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryTab(StudentFeesState state) {
    return Column(
      children: [
        // Filter Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by student name...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // Implement search filtering for payments
                    context.read<StudentFeesBloc>().add(SearchStudentFees(value));
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'All',
                items: ['All', 'CASH', 'ONLINE', 'BANK_TRANSFER', 'UPI', 'CARD'].map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode));
                }).toList(),
                onChanged: (value) {
                  // Load payments filtered by payment mode
                  if (value != null && value != 'All') {
                    context.read<StudentFeesBloc>().add(LoadPaymentHistory());
                  }
                },
              ),
            ],
          ),
        ),

        // Payment History List
        Expanded(
          child: state is StudentFeesLoaded && state.payments.isNotEmpty
              ? ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.payments.length,
            itemBuilder: (context, index) {
              final payment = state.payments[index];
              return _buildPaymentHistoryCard(payment);
            },
          )
              : _buildEmptyPaymentHistory(state),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryCard(FeePaymentDto payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        style: const TextStyle(fontWeight: FontWeight.w500),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPaymentInfoRow('Fee Structure', payment.feeStructureName ?? 'N/A'),
                  _buildPaymentInfoRow('Class', payment.className ?? 'N/A'),
                  _buildPaymentInfoRow('Month', payment.month ?? 'N/A'),
                  if (payment.receiptNumber?.isNotEmpty == true)
                    _buildPaymentInfoRow('Receipt No.', payment.receiptNumber!),
                  if (payment.remarks?.isNotEmpty == true)
                    _buildPaymentInfoRow('Remarks', payment.remarks!),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showPaymentDetails(payment),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showReceiptDialog(payment),
                  icon: const Icon(Icons.receipt, size: 16),
                  label: const Text('Receipt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPaymentHistory(StudentFeesState state) {
    if (state is StudentFeesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payment records will appear here once fees are paid',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Switch to fee status tab to record payments
              _tabController.animateTo(1);
            },
            icon: const Icon(Icons.payment),
            label: const Text('Record Payment'),
          ),
        ],
      ),
    );
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

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  void _showPaymentDetails(FeePaymentDto payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showReceiptDialog(payment);
            },
            child: const Text('View Receipt'),
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
            onPressed: () => _printReceipt(payment),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
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

  void _printReceipt(FeePaymentDto payment) {
    // TODO: Implement receipt printing
    // This could generate a PDF receipt or send to printer
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt printing feature will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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

  bool _canAssignFees() {
    return _selectedClass != null &&
        _selectedFeeStructure != null &&
        _selectedStudents.isNotEmpty &&
        _selectedMonth.isNotEmpty;
  }

  void _assignFees() {
    if (!_canAssignFees()) return;

    final request = BulkCreateStudentFeeRequest(
      feeStructureId: _selectedFeeStructure!.id!,
      studentIds: _selectedStudents.map((s) => s.id).toList(),
      dueDate: DateFormat('yyyy-MM-dd').format(_selectedDueDate),
      month: _selectedMonth,
    );

    context.read<StudentFeesBloc>().add(BulkCreateStudentFees(request));

    // Reset form after successful assignment
    setState(() {
      _selectedStudents.clear();
    });
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _showPaymentDialog(StudentFeeDto studentFee) {
    // Implementation for payment dialog
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(studentFee: studentFee),
    );
  }

  void _showPaymentHistory(StudentFeeDto studentFee) {
    // Implementation for payment history
    // Navigate to payment history screen or show bottom sheet
  }
}

// ================================
// lib/widgets/payment_dialog.dart
// ================================
class PaymentDialog extends StatefulWidget {
  final StudentFeeDto studentFee;

  const PaymentDialog({Key? key, required this.studentFee}) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedPaymentMode = 'CASH';
  late double _balanceAmount;

  @override
  void initState() {
    super.initState();
    _balanceAmount = double.parse(widget.studentFee.amount) -
        double.parse(widget.studentFee.paidAmount);
    _amountController.text = _balanceAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record Payment - ${widget.studentFee.studentName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Fee Structure:', widget.studentFee.feeStructureName ?? ''),
                    _buildInfoRow('Total Amount:', '₹${widget.studentFee.amount}'),
                    _buildInfoRow('Paid Amount:', '₹${widget.studentFee.paidAmount}'),
                    _buildInfoRow('Balance Amount:', '₹${_balanceAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Payment Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payment amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  if (amount > _balanceAmount) {
                    return 'Amount cannot exceed balance';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Payment Mode
              DropdownButtonFormField<String>(
                value: _selectedPaymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                ),
                items: ['CASH', 'ONLINE', 'BANK_TRANSFER', 'UPI', 'CARD'].map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode));
                }).toList(),
                onChanged: (value) => setState(() => _selectedPaymentMode = value!),
              ),

              const SizedBox(height: 16),

              // Receipt Number
              TextFormField(
                controller: _receiptController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _recordPayment,
          child: const Text('Record Payment'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _recordPayment() {
    if (_formKey.currentState!.validate()) {
      final paymentRequest = PayFeeRequest(
        amount: _amountController.text.trim(),
        paymentMode: _selectedPaymentMode,
        receiptNumber: _receiptController.text.trim().isEmpty ? null : _receiptController.text.trim(),
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      );

      // Emit the record payment event
      context.read<StudentFeesBloc>().add(RecordPayment(
        widget.studentFee.id!,
        paymentRequest,
      ));

      Navigator.of(context).pop();
    }
  }
}