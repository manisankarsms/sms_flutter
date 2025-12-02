import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/student_fees/student_fees_bloc.dart';
import '../bloc/student_fees/student_fees_event.dart';
import '../bloc/student_fees/student_fees_state.dart';
import '../models/fees_structures/FeePayment.dart';
import '../models/user.dart';
import '../widgets/fee_summary_card.dart';
import '../widgets/fee_chart.dart';

class FeeDashboardScreen extends StatefulWidget {
  final User user;

  const FeeDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FeeDashboardScreen> createState() => _FeeDashboardScreenState();
}

class _FeeDashboardScreenState extends State<FeeDashboardScreen> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<StudentFeesBloc>().add(LoadStudentFeesData());
    context.read<StudentFeesBloc>().add(LoadFeesSummary(
      month: _selectedMonth,
      classId: _selectedClassId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<StudentFeesBloc, StudentFeesState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(state),
                  const SizedBox(height: 20),
                  _buildSummaryCards(state),
                  const SizedBox(height: 20),
                  _buildCharts(state),
                  const SizedBox(height: 20),
                  _buildRecentActivity(state),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(StudentFeesState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
                    onChanged: (value) {
                      _selectedMonth = value;
                      _loadDashboardData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                if (state is StudentFeesLoaded) ...[
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedClassId,
                      decoration: const InputDecoration(
                        labelText: 'Class (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.class_),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Classes'),
                        ),
                        ...state.classes.map((classModel) {
                          return DropdownMenuItem<String>(
                            value: classModel.id,
                            child: Text('${classModel.className} - ${classModel.sectionName}'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        _selectedClassId = value;
                        _loadDashboardData();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(StudentFeesState state) {
    if (state is FeesSummaryLoaded) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FeeSummaryCard(
                  title: 'Total Students',
                  value: '${state.summary.paidCount}',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FeeSummaryCard(
                  title: 'Total Amount',
                  value: '₹${state.summary.totalPaid}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FeeSummaryCard(
                  title: 'Collected',
                  value: '₹${state.summary.totalPaid}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  // subtitle: '"${state.summary.collectionPercentage.toStringAsFixed(1)}%"',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FeeSummaryCard(
                  title: 'Pending',
                  // value: '₹${state.summary.pendingAmountValue.toStringAsFixed(0)}',
                  icon: Icons.pending,
                  color: Colors.red,
                  subtitle: '${state.summary.pendingCount} students', value: '',
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildCharts(StudentFeesState state) {
    if (state is FeesSummaryLoaded) {
      return Column(
        children: [
          // Collection Status Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collection Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  /*SizedBox(
                    height: 200,
                    child: FeeAmountBarChart(
                      paidAmount: state.summary.paidAmountValue,
                      pendingAmount: state.summary.pendingAmountValue,
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRecentActivity(StudentFeesState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity log
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state is StudentFeesLoaded && state.payments.isNotEmpty) ...[
              ...state.payments.take(5).map((payment) => _buildActivityItem(payment)),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No recent activity'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(FeePaymentDto payment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.payment,
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
                  '${payment.studentName} paid ₹${payment.amount}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Fee: ${payment.feeStructureName} • ${payment.paymentMode}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDateTime(payment.paymentDate),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3,
              children: [
                _buildQuickActionButton(
                  'Assign Fees',
                  Icons.assignment_add,
                  Colors.blue,
                      () {
                    // Navigate to fee assignment screen
                  },
                ),
                _buildQuickActionButton(
                  'Record Payment',
                  Icons.payment,
                  Colors.green,
                      () {
                    // Navigate to payment recording
                  },
                ),
                _buildQuickActionButton(
                  'Generate Report',
                  Icons.analytics,
                  Colors.purple,
                      () {
                    // Navigate to reports
                  },
                ),
                _buildQuickActionButton(
                  'Send Reminders',
                  Icons.notifications,
                  Colors.orange,
                      () {
                    // Navigate to reminders
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}