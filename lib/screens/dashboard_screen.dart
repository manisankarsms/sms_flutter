import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../models/dashboard_model.dart';

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

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(state.data);
            }
            return Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardModel data) {
    // Create dashboard cards from the API data
    final List<DashboardCard> overviewCards = [
      DashboardCard(
        title: 'Total Students',
        value: data.students.totalCount,
        icon: Icons.people,
        color: Colors.blue.shade700,
        description: '${data.students.newAdmissionsThisMonth} new this month',
      ),
      DashboardCard(
        title: 'Active Students',
        value: data.students.activeCount,
        icon: Icons.person,
        color: Colors.green.shade700,
        description: '${data.students.activeCount} of ${data.students.totalCount}',
      ),
      DashboardCard(
        title: 'Total Teachers',
        value: data.staff.totalTeachers,
        icon: Icons.school,
        color: Colors.purple.shade700,
        description: '${data.staff.onLeaveToday} on leave today',
      ),
      DashboardCard(
        title: 'Admin Staff',
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
        title: 'Boys',
        radius: 80,
      ),
      PieChartSectionData(
        color: Colors.pink.shade600,
        value: double.parse(genderDistribution.girls),
        title: 'Girls',
        radius: 80,
      ),
      PieChartSectionData(
        color: Colors.purple.shade600,
        value: double.parse(genderDistribution.other),
        title: 'Other',
        radius: 80,
      ),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards Section
            _buildSectionHeader('Overview'),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: overviewCards.map((card) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _buildDashboardCard(card),
                  );
                }).toList(),
              ),
            ),

            // Quick Actions Section
            const SizedBox(height: 32),
            _buildSectionHeader('Quick Actions'),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add Student',
                    onPressed: () {
                      // TODO: Navigate to add student screen
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuickActionButton(
                    icon: Icons.add_box,
                    label: 'Create Class',
                    onPressed: () {
                      // TODO: Navigate to create class screen
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuickActionButton(
                    icon: Icons.people,
                    label: 'Manage Staff',
                    onPressed: () {
                      // TODO: Navigate to staff management
                    },
                  ),
                ],
              ),
            ),

            // Analytics Charts Section
            const SizedBox(height: 32),
            _buildSectionHeader('Analytics'),
            const SizedBox(height: 16),

            // Pie Chart for Gender Distribution
            _buildChartCard(
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 4,
                ),
              ),
              title: 'Gender Distribution',
            ),
          ],
        ),
      ),
    );
  }

  // Reusable section header widget
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  // Build dashboard card with more modern design
  Widget _buildDashboardCard(DashboardCard card) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.color.withOpacity(0.7),
              card.color,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(card.icon, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              card.value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build quick action buttons with improved design
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}