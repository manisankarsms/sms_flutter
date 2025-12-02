import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FeeStatusPieChart extends StatelessWidget {
  final int paidCount;
  final int partiallyPaidCount;
  final int pendingCount;

  const FeeStatusPieChart({
    Key? key,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.pendingCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = paidCount + partiallyPaidCount + pendingCount;

    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: paidCount.toDouble(),
                  title: '${(paidCount / total * 100).toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: partiallyPaidCount.toDouble(),
                  title: '${(partiallyPaidCount / total * 100).toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: pendingCount.toDouble(),
                  title: '${(pendingCount / total * 100).toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Paid', Colors.green, paidCount),
              const SizedBox(height: 8),
              _buildLegendItem('Partial', Colors.orange, partiallyPaidCount),
              const SizedBox(height: 8),
              _buildLegendItem('Pending', Colors.red, pendingCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label ($count)',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class FeeAmountBarChart extends StatelessWidget {
  final double paidAmount;
  final double pendingAmount;

  const FeeAmountBarChart({
    Key? key,
    required this.paidAmount,
    required this.pendingAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = paidAmount + pendingAmount;

    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: total * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label = groupIndex == 0 ? 'Collected' : 'Pending';
              return BarTooltipItem(
                '$label\n₹${rod.toY.toStringAsFixed(0)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Collected', style: TextStyle(fontSize: 12));
                  case 1:
                    return const Text('Pending', style: TextStyle(fontSize: 12));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: paidAmount,
                color: Colors.green,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: pendingAmount,
                color: Colors.red,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}