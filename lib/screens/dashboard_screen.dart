import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/widgets/section_header.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../models/dashboard_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    context.read<DashboardBloc>().add(FetchDashboardData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Reset and restart animation when app resumes
      _resetAndStartAnimation();
    }
  }

  // Add this method to handle navigation back
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This gets called every time the widget's dependencies change,
    // including when navigating back to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<DashboardBloc>().state;
        if (state is DashboardLoaded) {
          _resetAndStartAnimation();
        }
      }
    });
  }

// Enhanced reset and start animation method
  void _resetAndStartAnimation() {
    print('Resetting animation - Controller status: ${_animationController.status}');
    if (mounted) {
      // Always reset the controller first
      _animationController.reset();

      // Use a small delay to ensure the widget tree is ready
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _animationController.forward();
          print('Animation restarted');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade600,
            ),
          );
        } else if (state is DashboardLoaded) {
          // Always restart animation when data is loaded
          _resetAndStartAnimation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) => _buildContent(state),
        ),
      ),
    );
  }

  Widget _buildContent(DashboardState state) {
    if (state is DashboardLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading dashboard data...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    if (state is DashboardError) {
      return _buildErrorState(state.message);
    }

    if (state is DashboardLoaded) {
      return _buildDashboard(state.data);
    }

    return Center(
      child: Text(
        AppLocalizations.of(context)?.no_data_available ?? 'No data available',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<DashboardBloc>().add(FetchDashboardData()),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again', style: TextStyle(fontSize: 16)), // AppLocalizations.of(context)?.try_again ?? 'Try Again'
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(DashboardModel dashboardModel) {
    final data = dashboardModel.data;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(data),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildChartsSection(data),
            const SizedBox(height: 16),
            _buildRecentActivities(data),
            const SizedBox(height: 16),
            _buildUpcomingEvents(data.holidayStatistics),
          ],
        ),
      ),
    );
  }

// Updated _buildOverviewCards method with larger text sizes
  Widget _buildOverviewCards(DashboardData data) {
    final cards = [
      _CardData(
        AppLocalizations.of(context)?.total_students ?? 'Total Students',
        data.overview.totalStudents.toString(),
        Icons.people,
        Colors.blue,
        '${data.studentStatistics.recentEnrollments.length} recent',
      ),
      _CardData(
        'Total Staff',
        data.overview.totalStaff.toString(),
        Icons.school,
        Colors.purple,
        '${data.staffStatistics.classTeachers} teachers',
      ),
      _CardData(
        'Today\'s Attendance',
        '${data.overview.todayAttendanceRate.toStringAsFixed(1)}%',
        Icons.check_circle,
        data.overview.todayAttendanceRate >= 80 ? Colors.green : Colors.orange,
        'Daily rate',
      ),
      _CardData(
        'Pending Complaints',
        data.overview.pendingComplaints.toString(),
        Icons.report_problem,
        data.overview.pendingComplaints > 5 ? Colors.red : Colors.amber,
        '${data.overview.totalComplaints} total',
      ),
      _CardData(
        'Total Classes',
        data.overview.totalClasses.toString(),
        Icons.class_,
        Colors.indigo,
        '${data.overview.totalSubjects} subjects',
      ),
      _CardData(
        'Upcoming Exams',
        data.overview.upcomingExams.toString(),
        Icons.quiz,
        Colors.teal,
        '${data.examStatistics.totalExams} total',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Overview'),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // More precise responsive breakpoints with better aspect ratios
            int crossAxisCount;
            double childAspectRatio;

            if (constraints.maxWidth > 1200) {
              // Large desktop - 3 columns
              crossAxisCount = 3;
              childAspectRatio = 2.2; // Increased height for larger text
            } else if (constraints.maxWidth > 900) {
              // Medium desktop - 3 columns
              crossAxisCount = 3;
              childAspectRatio = 2.0; // Increased height for larger text
            } else if (constraints.maxWidth > 600) {
              // Tablet landscape - 2 columns
              crossAxisCount = 2;
              childAspectRatio = 1.9; // Increased height for larger text
            } else if (constraints.maxWidth > 480) {
              // Large mobile/small tablet - 2 columns
              crossAxisCount = 2;
              childAspectRatio = 1.7; // Increased height for larger text
            } else {
              // Small mobile - 1 column
              crossAxisCount = 1;
              childAspectRatio = 3.2; // Increased height for larger text
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) => _buildOverviewCard(cards[index], index, cards.length),
            );
          },
        ),
      ],
    );
  }

// Updated _buildOverviewCard method with larger text sizes
  Widget _buildOverviewCard(_CardData card, int index, int totalCards) {
    // Calculate proper interval values that don't exceed 1.0
    final double startDelay = (index / totalCards) * 0.5;
    final double endTime = startDelay + 0.5;
    final double clampedEndTime = endTime > 1.0 ? 1.0 : endTime;

    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(startDelay, clampedEndTime, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(startDelay, clampedEndTime, curve: Curves.easeOut),
          ),
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [card.color.withOpacity(0.1), card.color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Adjust layout based on available space
                bool isVerySmall = constraints.maxHeight < 140; // Adjusted for larger text
                bool isNarrowCard = constraints.maxWidth < 150;

                // Adjust padding based on available space
                double padding = isVerySmall ? 10 : 14; // Increased padding

                return Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min, // Important: prevents overflow
                    children: [
                      // Header row with title and icon
                      Flexible(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                card.title,
                                style: TextStyle(
                                  fontSize: isVerySmall ? 15 : (isNarrowCard ? 18 : 20), // Increased sizes
                                  fontWeight: FontWeight.w900,
                                  height: 1.2, // Tighter line height
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: isVerySmall ? 1 : (isNarrowCard ? 2 : 1),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              card.icon,
                              color: card.color,
                              size: isVerySmall ? 20 : (isNarrowCard ? 22 : 24), // Increased sizes
                            ),
                          ],
                        ),
                      ),

                      // Spacer - flexible to absorb extra space
                      if (!isVerySmall)
                        Flexible(
                          flex: 1,
                          child: SizedBox(height: isNarrowCard ? 2 : 4),
                        ),

                      // Value text
                      Flexible(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            card.value,
                            style: TextStyle(
                              fontSize: isVerySmall ? 24 : (isNarrowCard ? 26 : 38), // Increased sizes
                              fontWeight: FontWeight.w900,
                              color: card.color,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),

                      // Description text
                      Flexible(
                        flex: 1,
                        child: Text(
                          card.description,
                          style: TextStyle(
                            fontSize: isVerySmall ? 14 : (isNarrowCard ? 16 : 20), // Increased sizes
                            color: Colors.grey.shade800,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _ActionData('Add Student', Icons.person_add, Colors.blue),
      _ActionData('Add Staff', Icons.group_add, Colors.purple),
      _ActionData('View Reports', Icons.analytics, Colors.green),
      _ActionData('Schedule Exam', Icons.quiz, Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title:'Quick Actions'),
        const SizedBox(height: 8),
        SizedBox(
          height: 70, // Increased height for larger text
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => _buildActionButton(actions[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(_ActionData action) {
    return InkWell(
      onTap: () {}, // Add navigation logic
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), // Increased padding
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: action.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 24), // Increased icon size
            const SizedBox(height: 4),
            Text(
              action.title,
              style: TextStyle(
                fontSize: 12, // Increased text size
                fontWeight: FontWeight.w500,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title:'Analytics'),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStudentsChart(data.studentStatistics)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStaffChart(data.staffStatistics)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildComplaintsChart(data.complaintStatistics)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildAttendanceChart(data.attendanceStatistics)),
                    ],
                  ),
                ],
              );
            }
            return Column(
              children: [
                _buildStudentsChart(data.studentStatistics),
                const SizedBox(height: 8),
                _buildStaffChart(data.staffStatistics),
                const SizedBox(height: 8),
                _buildComplaintsChart(data.complaintStatistics),
                const SizedBox(height: 8),
                _buildAttendanceChart(data.attendanceStatistics),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentsChart(StudentStatistics stats) {
    final sections = stats.studentsByClass.take(5).map((classData) {
      final index = stats.studentsByClass.indexOf(classData);
      return PieChartSectionData(
        color: Colors.primaries[index % Colors.primaries.length],
        value: classData.studentCount.toDouble(),
        title: '${classData.studentCount}',
        titleStyle: const TextStyle(
          fontSize: 12, // Increased chart text size
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 45, // Increased radius for better visibility
      );
    }).toList();

    return _chartCard(
      'Students by Class',
      Column(
        children: [
          SizedBox(
            height: 130, // Increased chart height
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 25, // Increased center space
                sectionsSpace: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: stats.studentsByClass.take(5).map((classData) {
              final index = stats.studentsByClass.indexOf(classData);
              final color = Colors.primaries[index % Colors.primaries.length];
              return _buildLegendItem(color, '${classData.className} ${classData.sectionName}');
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffChart(StaffStatistics stats) {
    final barGroups = stats.staffByRole.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.count.toDouble(),
            color: Colors.primaries[entry.key % Colors.primaries.length],
            width: 20, // Increased bar width
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return _chartCard(
      'Staff by Role',
      SizedBox(
        height: 160, // Increased chart height
        child: BarChart(
          BarChartData(
            maxY: stats.staffByRole.isNotEmpty
                ? stats.staffByRole.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble() * 1.2
                : 10,
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < stats.staffByRole.length) {
                      return Text(
                        stats.staffByRole[value.toInt()].role,
                        style: const TextStyle(fontSize: 11), // Increased text size
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsChart(ComplaintStatistics stats) {
    final sections = stats.complaintsByStatus.map((statusData) {
      return PieChartSectionData(
        color: _getComplaintColor(statusData.status),
        value: statusData.count.toDouble(),
        title: '${statusData.count}',
        titleStyle: const TextStyle(
          fontSize: 12, // Increased chart text size
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 45, // Increased radius
      );
    }).toList();

    return _chartCard(
      'Complaints Status',
      Column(
        children: [
          SizedBox(
            height: 130, // Increased chart height
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 25, // Increased center space
                sectionsSpace: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: stats.complaintsByStatus.map((statusData) {
              return _buildLegendItem(_getComplaintColor(statusData.status), statusData.status);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart(AttendanceStatistics stats) {
    final data = [
      _ChartData('Today', stats.todayAttendanceRate),
      _ChartData('Week', stats.weeklyAttendanceRate),
      _ChartData('Month', stats.monthlyAttendanceRate),
    ];

    return _chartCard(
      'Attendance Rates',
      SizedBox(
        height: 160, // Increased chart height
        child: BarChart(
          BarChartData(
            maxY: 100,
            barGroups: data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value,
                    color: entry.value.value >= 80 ? Colors.green :
                    entry.value.value >= 60 ? Colors.orange : Colors.red,
                    width: 24, // Increased bar width
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 11)), // Increased text size
                  reservedSize: 30, // Increased reserved space
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < data.length) {
                      return Text(
                        data[value.toInt()].label,
                        style: const TextStyle(fontSize: 11), // Increased text size
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title:'Recent Activities'),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.studentStatistics.recentEnrollments.isNotEmpty) ...[
                  const Text('Recent Enrollments',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), // Increased text size
                  const SizedBox(height: 8),
                  ...data.studentStatistics.recentEnrollments.take(3).map(
                        (enrollment) => _activityTile(
                      Icons.person_add,
                      '${enrollment.studentName} enrolled in ${enrollment.className} ${enrollment.sectionName}',
                      enrollment.enrollmentDate,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (data.complaintStatistics.recentComplaints.isNotEmpty) ...[
                  const Text('Recent Complaints',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), // Increased text size
                  const SizedBox(height: 8),
                  ...data.complaintStatistics.recentComplaints.take(3).map(
                        (complaint) => _activityTile(
                      Icons.report,
                      complaint.title,
                      'Category: ${complaint.category} - ${complaint.status}',
                      _getComplaintColor(complaint.status),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents(HolidayStatistics holidays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Upcoming Events'),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Holidays',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${holidays.upcomingHolidays} upcoming',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (holidays.upcomingHolidaysList.isEmpty)
                  Center(
                    child: Text(
                      'No upcoming holidays',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  )
                else
                  ...holidays.upcomingHolidaysList.take(5).map((holiday) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: holiday.isPublicHoliday ? Colors.red.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              holiday.isPublicHoliday ? Icons.public : Icons.school,
                              color: holiday.isPublicHoliday ? Colors.red.shade600 : Colors.blue.shade600,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  holiday.name,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  holiday.description,
                                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                holiday.date,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${holiday.daysUntilHoliday} days',
                                style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _activityTile(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(String title, Widget chart) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 3;
    if (width > 400) return 2;
    return 1;
  }

  Color _getComplaintColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return Colors.green.shade600;
      case 'pending': return Colors.amber.shade600;
      default: return Colors.red.shade600;
    }
  }
}

// Helper classes for data structure
class _CardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String description;

  _CardData(this.title, this.value, this.icon, this.color, this.description);
}

class _ActionData {
  final String title;
  final IconData icon;
  final Color color;

  _ActionData(this.title, this.icon, this.color);
}

class _ChartData {
  final String label;
  final double value;

  _ChartData(this.label, this.value);
}