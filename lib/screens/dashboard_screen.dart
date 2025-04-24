import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../models/dashboard_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String description;

  DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    context.read<DashboardBloc>().add(FetchDashboardData());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Reset and start animation when returning to the screen
    final state = context.read<DashboardBloc>().state;
    if (state is DashboardLoaded && !_animationController.isAnimating) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else if (state is DashboardLoaded) {
          _animationController.forward();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(state, colorScheme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(DashboardState state, ColorScheme colorScheme) {
    if (state is DashboardLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading dashboard data...',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      );
    } else if (state is DashboardError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DashboardBloc>().add(FetchDashboardData());
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)?.try_again ?? 'Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    } else if (state is DashboardLoaded) {
      return _buildDashboardContent(state.data, colorScheme);
    }

    return Center(
      child: Text(
        AppLocalizations.of(context)?.no_data_available ?? 'No data available',
        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardModel data, ColorScheme colorScheme) {
    // Create dashboard cards from the API data
    final List<DashboardCard> overviewCards = [
      DashboardCard(
        title: AppLocalizations.of(context)?.total_students ?? 'Total Students',
        value: data.students.totalCount,
        icon: Icons.people,
        color: Colors.blue.shade700,
        description: '${data.students.newAdmissionsThisMonth} new this month',
      ),
      DashboardCard(
        title: AppLocalizations.of(context)?.active_students ?? 'Active Students',
        value: data.students.activeCount,
        icon: Icons.person,
        color: Colors.green.shade700,
        description: '${data.students.activeCount} of ${data.students.totalCount}',
      ),
      DashboardCard(
        title: AppLocalizations.of(context)?.total_teachers ?? 'Total Teachers',
        value: data.staff.totalTeachers,
        icon: Icons.school,
        color: Colors.purple.shade700,
        description: '${data.staff.onLeaveToday} on leave today',
      ),
      DashboardCard(
        title: AppLocalizations.of(context)?.admin_staff ?? 'Admin Staff',
        value: data.staff.totalAdminStaff,
        icon: Icons.admin_panel_settings,
        color: Colors.orange.shade700,
        description: 'Support personnel',
      ),
    ];

    // Create pie chart sections for gender distribution
    final genderDistribution = data.students.genderDistribution;
    final List<PieChartSectionData> pieChartSections = [
      PieChartSectionData(
        color: Colors.blue.shade600,
        value: double.parse(genderDistribution.boys),
        title: '${double.parse(genderDistribution.boys).toInt()}',
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 100,
        titlePositionPercentageOffset: 0.55,
      ),
      PieChartSectionData(
        color: Colors.pink.shade600,
        value: double.parse(genderDistribution.girls),
        title: '${double.parse(genderDistribution.girls).toInt()}',
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 100,
        titlePositionPercentageOffset: 0.55,
      ),
      PieChartSectionData(
        color: Colors.purple.shade600,
        value: double.parse(genderDistribution.other),
        title: '${double.parse(genderDistribution.other).toInt()}',
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: double.parse(genderDistribution.other) > 5 ? 100 : 80,
        titlePositionPercentageOffset: 0.55,
      ),
    ];

    // Create bar chart data for complaints by status
    final complaintsData = data.complaints.byStatus;
    final List<BarChartGroupData> complaintsBarGroups = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: double.parse(complaintsData.open),
            color: Colors.red.shade500,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: double.parse(complaintsData.pending),
            color: Colors.amber.shade600,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: double.parse(complaintsData.resolved),
            color: Colors.green.shade500,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards Section
              _buildSectionHeader(
                  AppLocalizations.of(context)?.overview ?? 'Overview',
                  colorScheme
              ),
              const SizedBox(height: 16),

              // Animated cards with FadeTransition
              _buildResponsiveCardGrid(
                overviewCards.asMap().entries.map((entry) {
                  int idx = entry.key;
                  DashboardCard card = entry.value;

                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.1 * idx, // Stagger the animations
                          0.1 * idx + 0.6,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.3),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.1 * idx,
                            0.1 * idx + 0.6,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: _buildDashboardCard(card, colorScheme),
                    ),
                  );
                }).toList(),
              ),

              // Quick Actions Section
              const SizedBox(height: 32),
              _buildSectionHeader(
                  AppLocalizations.of(context)?.quick_actions ?? 'Quick Actions',
                  colorScheme
              ),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(colorScheme),

              const SizedBox(height: 32),
              _buildSectionHeader(
                  'Plan Usage',
                  colorScheme
              ),
              const SizedBox(height: 16),
              _buildPlanUsageSection(data.planUsage, colorScheme),

              // Analytics Charts Section
              const SizedBox(height: 32),
              _buildSectionHeader(
                  AppLocalizations.of(context)?.analytics ?? 'Analytics',
                  colorScheme
              ),
              const SizedBox(height: 16),

              // Analytics layout that's responsive for both web and mobile
              LayoutBuilder(
                builder: (context, constraints) {
                  // For wider screens (tablets and desktops), use a row layout
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left chart: Gender Distribution
                        Expanded(
                          flex: 1,
                          child: _buildChartCard(
                            child: PieChart(
                              PieChartData(
                                sections: pieChartSections,
                                centerSpaceRadius: 40,
                                sectionsSpace: 4,
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    // Handle touch events
                                  },
                                ),
                              ),
                            ),
                            title: AppLocalizations.of(context)?.gender_distribution ?? 'Gender Distribution',
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right chart: Complaints Status
                        Expanded(
                          flex: 1,
                          child: _buildChartCard(
                            title: 'Complaints Status',
                            colorScheme: colorScheme,
                            child: Column(
                              children: [
                                Expanded(
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: double.parse(complaintsData.open) > double.parse(complaintsData.pending) ?
                                      (double.parse(complaintsData.open) > double.parse(complaintsData.resolved) ?
                                      double.parse(complaintsData.open) * 1.2 : double.parse(complaintsData.resolved) * 1.2) :
                                      (double.parse(complaintsData.pending) > double.parse(complaintsData.resolved) ?
                                      double.parse(complaintsData.pending) * 1.2 : double.parse(complaintsData.resolved) * 1.2),
                                      barGroups: complaintsBarGroups,
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Text('${value.toInt()}'),
                                              );
                                            },
                                            reservedSize: 30,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              const statuses = ['Open', 'Pending', 'Resolved'];
                                              if (value.toInt() >= 0 && value.toInt() < statuses.length) {
                                                return SideTitleWidget(
                                                  axisSide: meta.axisSide,
                                                  child: Text(
                                                    statuses[value.toInt()],
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                            reservedSize: 30,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        drawHorizontalLine: true,
                                        drawVerticalLine: false,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Resolution rate indicator
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Text(
                                      'Resolution Rate: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: double.parse(data.complaints.resolutionRate) > 50
                                            ? Colors.green.shade100
                                            : double.parse(data.complaints.resolutionRate) > 25
                                            ? Colors.amber.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '${data.complaints.resolutionRate}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: double.parse(data.complaints.resolutionRate) > 50
                                              ? Colors.green.shade800
                                              : double.parse(data.complaints.resolutionRate) > 25
                                              ? Colors.amber.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // For mobile screens, use a column layout
                    return Column(
                      children: [
                        // Gender Distribution Chart
                        _buildChartCard(
                          child: PieChart(
                            PieChartData(
                              sections: pieChartSections,
                              centerSpaceRadius: 40,
                              sectionsSpace: 4,
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  // Handle touch events
                                },
                              ),
                            ),
                          ),
                          title: AppLocalizations.of(context)?.gender_distribution ?? 'Gender Distribution',
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 24),
                        // Complaints Chart
                        _buildChartCard(
                          title: 'Complaints Status',
                          colorScheme: colorScheme,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: double.parse(complaintsData.open) > double.parse(complaintsData.pending) ?
                                    (double.parse(complaintsData.open) > double.parse(complaintsData.resolved) ?
                                    double.parse(complaintsData.open) * 1.2 : double.parse(complaintsData.resolved) * 1.2) :
                                    (double.parse(complaintsData.pending) > double.parse(complaintsData.resolved) ?
                                    double.parse(complaintsData.pending) * 1.2 : double.parse(complaintsData.resolved) * 1.2),
                                    barGroups: complaintsBarGroups,
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text('${value.toInt()}'),
                                            );
                                          },
                                          reservedSize: 30,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            const statuses = ['Open', 'Pending', 'Resolved'];
                                            if (value.toInt() >= 0 && value.toInt() < statuses.length) {
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Text(
                                                  statuses[value.toInt()],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                          reservedSize: 30,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(
                                      show: true,
                                      drawHorizontalLine: true,
                                      drawVerticalLine: false,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Resolution rate indicator
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    'Resolution Rate: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: double.parse(data.complaints.resolutionRate) > 50
                                          ? Colors.green.shade100
                                          : double.parse(data.complaints.resolutionRate) > 25
                                          ? Colors.amber.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${data.complaints.resolutionRate}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: double.parse(data.complaints.resolutionRate) > 50
                                            ? Colors.green.shade800
                                            : double.parse(data.complaints.resolutionRate) > 25
                                            ? Colors.amber.shade800
                                            : Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  // Reusable section header widget
  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Build dashboard card with more modern design
  Widget _buildDashboardCard(DashboardCard card, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shadowColor: card.color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.color.withOpacity(0.8),
              card.color.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Icon(card.icon, color: Colors.white.withOpacity(0.9), size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              card.value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                card.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick actions grid with responsiveness
  Widget _buildQuickActionsGrid(ColorScheme colorScheme) {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.person_add,
        'label': AppLocalizations.of(context)?.add_student ?? 'Add Student',
        'onPressed': () {
          // Navigate to add student screen
        },
      },
      {
        'icon': Icons.add_box,
        'label': AppLocalizations.of(context)?.add_new_class ?? 'Create Class',
        'onPressed': () {
          // Navigate to create class screen
        },
      },
      {
        'icon': Icons.people,
        'label': AppLocalizations.of(context)?.manage_staff ?? 'Manage Staff',
        'onPressed': () {
          // Navigate to staff management
        },
      },
      {
        'icon': Icons.assessment,
        'label': AppLocalizations.of(context)?.reports ?? 'Reports',
        'onPressed': () {
          // Navigate to reports screen
        },
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          // Grid layout for larger screens
          return Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: actions.map((action) {
                return _buildQuickActionButton(
                  icon: action['icon'],
                  label: action['label'],
                  onPressed: action['onPressed'],
                  colorScheme: colorScheme,
                );
              }).toList(),
            ),
          );
        } else {
          // Row with horizontal scrolling for smaller screens
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: actions.map((action) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildQuickActionButton(
                    icon: action['icon'],
                    label: action['label'],
                    onPressed: action['onPressed'],
                    colorScheme: colorScheme,
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  // Build responsive card grid
  Widget _buildResponsiveCardGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use grid layout for wider screens
        if (constraints.maxWidth > 700) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 1100 ? 4 : 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: children,
          );
        } else {
          // Use horizontal scrolling for smaller screens
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children.map((child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: child,
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }

  // Build quick action buttons with improved design
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable chart card widget
  Widget _buildChartCard({
    required Widget child,
    required String title,
    required ColorScheme colorScheme,
  }) {
    return SizedBox(
      height: 400, // 💡 Set the same fixed height for all cards
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show chart options
                    },
                    tooltip: 'More options',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              // Chart content (fill available space)
              Expanded(
                child: child,
              ),

              // Legend for gender distribution
              if (title == (AppLocalizations.of(context)?.gender_distribution ?? 'Gender Distribution'))
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildLegendItem(Colors.blue.shade600, AppLocalizations.of(context)?.boys ?? 'Boys', colorScheme),
                      _buildLegendItem(Colors.pink.shade600, AppLocalizations.of(context)?.girls ?? 'Girls', colorScheme),
                      _buildLegendItem(Colors.purple.shade600, AppLocalizations.of(context)?.other ?? 'Other', colorScheme),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLegendItem(Color color, String label, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildPlanUsageSection(PlanUsage planUsage, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replace the Row in the _buildPlanUsageSection function with this more responsive version
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Plan Usage - ${planUsage.planName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // Add some spacing between the elements
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Renews: ${planUsage.nextBillingDate}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Students usage
            _buildUsageIndicator(
              title: 'Students',
              current: double.parse(planUsage.currentStudentCount),
              max: double.parse(planUsage.studentLimit),
              color: Colors.blue,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Staff usage
            _buildUsageIndicator(
              title: 'Staff',
              current: double.parse(planUsage.currentStaffCount),
              max: double.parse(planUsage.staffLimit),
              color: Colors.purple,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Storage usage
            _buildUsageIndicator(
              title: 'Storage',
              current: double.parse(planUsage.usedStorageMB),
              max: double.parse(planUsage.storageLimitMB),
              color: Colors.amber,
              colorScheme: colorScheme,
              suffix: 'MB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageIndicator({
    required String title,
    required double current,
    required double max,
    required Color color,
    required ColorScheme colorScheme,
    String suffix = '',
  }) {
    final percentage = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${current.toInt()}${suffix.isNotEmpty ? ' $suffix' : ''} / ${max.toInt()}${suffix.isNotEmpty ? ' $suffix' : ''}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage > 1 ? 1 : percentage,
            child: Container(
              decoration: BoxDecoration(
                color: percentage > 0.9 ? Colors.red : color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}