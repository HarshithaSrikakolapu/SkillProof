import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/analytics/data/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _service = AnalyticsService();
  Map<String, dynamic> _userStats = {};
  List<dynamic> _globalStats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _service.getUserProgress();
    final global = await _service.getSkillStats();
    if (mounted) {
      setState(() {
        _userStats = user;
        _globalStats = global;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final progress = _userStats['progress'] as List;
    final points = progress.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['score'] as num).toDouble());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Progress (Scores)", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: points.isEmpty 
               ? const Center(child: Text("No assessments taken yet."))
               : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(
                         bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                      ),
                    ],
                  ),
                ),
            ),
            const SizedBox(height: 32),
            Text("Global Skill Averages", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _globalStats.isEmpty
                  ? const Center(child: Text("No global data."))
                  : BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < _globalStats.length) {
                                   return Text(_globalStats[value.toInt()]['skill'], style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: _globalStats.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: (e.value['avg_score'] as num).toDouble(),
                                color: Colors.green,
                                width: 16,
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
