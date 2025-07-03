import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

import '../bloc/student_dashboard/student_dashboard_bloc.dart';
import '../bloc/student_dashboard/student_dashboard_event.dart';
import '../bloc/student_dashboard/student_dashboard_state.dart';
import '../models/student_dashboard_model.dart';
import '../models/user.dart';
import '../widgets/screen_header.dart';
import '../repositories/dashboard_repository.dart';

class StudentDashboardScreen extends StatefulWidget {
  final User user;
  const StudentDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final List<DashboardOption> dashboardOptions = [
    DashboardOption(icon: Icons.calendar_today_rounded, title: 'Calendar', color: const Color(0xFF6366F1)),
    DashboardOption(icon: Icons.how_to_reg_rounded, title: 'Attendance', color: const Color(0xFF10B981)),
    DashboardOption(icon: Icons.person_rounded, title: 'Profile', color: const Color(0xFF8B5CF6)),
    DashboardOption(icon: Icons.rule_rounded, title: 'Rules', color: const Color(0xFFF59E0B)),
    DashboardOption(icon: Icons.report_problem_rounded, title: 'Complaints', color: const Color(0xFFEF4444)),
    DashboardOption(icon: Icons.payment_rounded, title: 'Fees', color: const Color(0xFF06B6D4)),
    DashboardOption(icon: Icons.message_rounded, title: 'Messages', color: const Color(0xFF3B82F6)),
    DashboardOption(icon: Icons.more_horiz_rounded, title: 'More', color: const Color(0xFF6B7280)),
  ];

  @override
  void initState() {
    super.initState();
    // Trigger initial data fetch
    context.read<StudentDashboardBloc>().add(FetchStudentDashboardData(widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
          builder: (context, state) {
            if (state is StudentDashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF667EEA),
                ),
              );
            } else if (state is StudentDashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StudentDashboardBloc>().add(FetchStudentDashboardData(widget.user.id));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is StudentDashboardLoaded || state is StudentDashboardRefreshing) {
              final data = state is StudentDashboardLoaded
                  ? (state as StudentDashboardLoaded).data
                  : (state as StudentDashboardRefreshing).data;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StudentDashboardBloc>().add(RefreshStudentDashboardData(widget.user.id));
                },
                color: const Color(0xFF667EEA),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenHeader(
                        title: 'Dashboard',
                      ),
                      const SizedBox(height: 24),
                      _buildStudentInfoCard(data),
                      const SizedBox(height: 24),
                      _buildQuickStatsSection(data),
                      const SizedBox(height: 24),
                      _buildDashboardOptions(),
                      const SizedBox(height: 24),
                      _buildUpcomingExamsCard(data),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(StudentDashboardModel data) {
    final name = '${data.firstName} ${data.lastName}';
    final firstInitial = (data.firstName?.isNotEmpty ?? false) ? data.firstName![0] : '';
    final lastInitial = (data.lastName?.isNotEmpty ?? false) ? data.lastName![0] : '';
    final initials = '$firstInitial$lastInitial';
    final studentId = data.studentId;
    final classSection = '${data.currentAcademicYear.className} - ${data.currentAcademicYear.sectionName}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ID: $studentId...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'Class $classSection',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(StudentDashboardModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Attendance',
                '${data.attendanceStatistics.attendancePercentage}%',
                Icons.trending_up_rounded,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Present Days',
                '${data.attendanceStatistics.presentDays}/${data.attendanceStatistics.totalDays}',
                Icons.check_circle_rounded,
                const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: dashboardOptions.length,
          itemBuilder: (context, index) {
            final option = dashboardOptions[index];
            return GestureDetector(
              onTap: option.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: option.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(option.icon, color: option.color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingExamsCard(StudentDashboardModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Exams',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              if (data.upcomingExams.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No upcoming exams',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ...data.upcomingExams.take(3).map<Widget>((exam) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF59E0B).withOpacity(0.1),
                          const Color(0xFFEF4444).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.examName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                exam.subjectName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${exam.daysUntilExam} days',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardOption {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  DashboardOption({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap = _defaultOnTap,
  });

  static void _defaultOnTap() {}
}