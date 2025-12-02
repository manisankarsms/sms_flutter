import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sms/screens/ModernFeesStructuresScreen.dart';
import 'package:sms/screens/modern_student_fees_assignment_screen.dart';

import '../bloc/student_fees/student_fees_bloc.dart';
import '../bloc/student_fees/student_fees_event.dart';
import '../bloc/student_fees/student_fees_state.dart';
import '../models/user.dart';
import 'fee_dashboard_screen.dart';
import 'fee_report_screen.dart';
import 'fees_structures_screen.dart';
import 'student_fees_assignment_screen.dart';

class FeesManagementScreen extends StatefulWidget {
  final User user;

  const FeesManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<FeesManagementScreen> createState() => _FeesManagementScreenState();
}

class _FeesManagementScreenState extends State<FeesManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentFeesBloc>().add(LoadFeesSummary());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildCompactHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompactStats(),
                    const SizedBox(height: 16),
                    _buildCompactManagementGrid(),
                    const SizedBox(height: 16),
                    _buildCompactRecentActivity(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fees Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage structures & collections',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<StudentFeesBloc>().add(LoadFeesSummary());
            },
            icon: const Icon(Icons.refresh, size: 20),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStats() {
    return BlocBuilder<StudentFeesBloc, StudentFeesState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: _buildCompactStatCard(
                title: 'Collection',
                value: state is FeesSummaryLoaded ? '₹${_formatAmount(state.summary.totalPaid)}' : '₹0',
                icon: Icons.trending_up,
                color: Colors.green,
                subtitle: state is FeesSummaryLoaded ? '${state.summary.paidCount} paid' : '',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompactStatCard(
                title: 'Pending',
                value: state is FeesSummaryLoaded
                    ? '₹${_formatAmount((double.parse(state.summary.totalFees) - double.parse(state.summary.totalPaid)).toString())}'
                    : '₹0',
                icon: Icons.pending_actions,
                color: Colors.orange,
                subtitle: state is FeesSummaryLoaded ? '${state.summary.pendingCount} due' : '',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactManagementGrid() {
    final managementOptions = [
      {
        'title': 'Structures',
        'icon': Icons.receipt_long,
        'color': Colors.blue,
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ModernFeesStructureScreen()),
        ),
      },
      {
        'title': 'Assignment',
        'icon': Icons.assignment_add,
        'color': Colors.green,
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModernStudentFeesAssignmentScreen(user: widget.user),
          ),
        ),
      },
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'color': Colors.purple,
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeeDashboardScreen(user: widget.user),
          ),
        ),
      },
      {
        'title': 'Reports',
        'icon': Icons.analytics,
        'color': Colors.orange,
        'route': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeeReportsScreen(user: widget.user),
          ),
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: managementOptions.length,
          itemBuilder: (context, index) {
            final option = managementOptions[index];
            return _buildCompactManagementCard(
              title: option['title'] as String,
              icon: option['icon'] as IconData,
              color: option['color'] as Color,
              onTap: option['route'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompactManagementCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRecentActivity() {
    return BlocBuilder<StudentFeesBloc, StudentFeesState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Recent Payments',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentFeesAssignmentScreen(user: widget.user),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('View All', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state is StudentFeesLoaded && state.payments.isNotEmpty) ...[
                ...state.payments.take(4).map((payment) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.studentName.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${payment.feeStructureName} • ${payment.paymentMode}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${_formatAmount(payment.amount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDateTime(payment.paymentDate),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No recent payments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatAmount(String amount) {
    try {
      final num = double.parse(amount);
      if (num >= 100000) {
        return '${(num / 100000).toStringAsFixed(1)}L';
      } else if (num >= 1000) {
        return '${(num / 1000).toStringAsFixed(1)}K';
      }
      return num.toStringAsFixed(0);
    } catch (e) {
      return amount;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM dd').format(dateTime);
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}