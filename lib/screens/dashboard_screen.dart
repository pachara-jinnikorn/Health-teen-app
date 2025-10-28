import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/health_data_provider.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTab = 'Sleep';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<HealthDataProvider>(
        builder: (context, provider, _) {
          final hd = provider.healthData;

          // เตรียมซีรีส์และ label ตามแท็บ
          List<double> sleepSeries = hd.weeklySleep; // double
          List<int> calorieSeries = hd.weeklyCalories; // int
          List<int> exerciseSeries = hd.weeklyExerciseMinutes; // int

          final days = hd.last7Days
              .map((d) => _weekdayAbbr(d.weekday))
              .toList(); // ['Mon'..'Sun'] ตามลำดับเวลาเก่าสุด->ล่าสุด

          // เลือกชุดข้อมูลตามแท็บ
          List<double> chartDataDouble = [];
          List<int> chartDataInt = [];
          String title = '';
          String unit = '';
          double suggestedMaxY = 10;

          if (_selectedTab == 'Sleep') {
            title = 'Sleep Duration';
            unit = 'h';
            chartDataDouble = sleepSeries;
            // ตั้งเพดาน Y= max(10, ceil(max+1)) เพื่อเผื่อหัวกราฟ
            final maxVal = chartDataDouble.isEmpty
                ? 0
                : (chartDataDouble.reduce((a, b) => a > b ? a : b));
            suggestedMaxY = (maxVal + 1).clamp(0, 24).toDouble();
          } else if (_selectedTab == 'Food') {
            title = 'Calories Intake';
            unit = 'kcal';
            chartDataInt = calorieSeries;
            final maxVal = chartDataInt.isEmpty
                ? 0
                : (chartDataInt.reduce((a, b) => a > b ? a : b));
            suggestedMaxY = (maxVal + 200).toDouble();
          } else {
            title = 'Exercise Minutes';
            unit = 'min';
            chartDataInt = exerciseSeries;
            final maxVal = chartDataInt.isEmpty
                ? 0
                : (chartDataInt.reduce((a, b) => a > b ? a : b));
            suggestedMaxY = (maxVal + 10).toDouble();
          }

          // ค่าปัจจุบันสำหรับการ์ดใหญ่ด้านบน (มาจาก hydrateFromLatest ใน provider)
          final headlineValue = _selectedTab == 'Sleep'
              ? '${_fmtDouble(hd.sleep)}h'
              : _selectedTab == 'Food'
                  ? '${hd.calories} kcal'
                  : '${hd.weeklyExerciseMinutes.isNotEmpty ? hd.weeklyExerciseMinutes.last : 0} min';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      _buildTab('Sleep'),
                      _buildTab('Food'),
                      _buildTab('Exercise'),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card: Summary + Chart
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTextStyles.heading3),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              headlineValue,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // หมายเหตุ: “Last 7 Days +5%” เป็น static text เดิม
                            const Text(
                              'Last 7 Days +5%',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Chart
                            SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: suggestedMaxY <= 0 ? 10 : suggestedMaxY,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final i = value.toInt();
                                          if (i < 0 || i >= days.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Text(days[i],
                                              style: AppTextStyles.caption);
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(days.length, (i) {
                                    final y = _selectedTab == 'Sleep'
                                        ? (i < chartDataDouble.length
                                            ? chartDataDouble[i]
                                            : 0.0)
                                        : (i < chartDataInt.length
                                            ? chartDataInt[i].toDouble()
                                            : 0.0);
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: y,
                                          color: AppColors.primary,
                                          width: 24,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Unit: $unit', style: AppTextStyles.caption),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Badges & Awards
                      const Text('Badges & Awards',
                          style: AppTextStyles.heading2),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.badges.length,
                          itemBuilder: (context, index) {
                            final badge = provider.badges[index];
                            return Container(
                              width: 130,
                              height: 160,
                              margin:
                                  const EdgeInsets.only(right: AppSpacing.md),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: badge.color,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(badge.icon,
                                      style: const TextStyle(fontSize: 40)),
                                  const SizedBox(height: 8),
                                  Text(
                                    badge.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      badge.description,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // History (ตัวอย่าง static เหมือนเดิม)
                      const Text('History', style: AppTextStyles.heading2),
                      const SizedBox(height: AppSpacing.md),
                      _buildHistoryItem(
                        icon: Icons.nightlight_round,
                        title: 'Night Sleep',
                        duration: '${_fmtDouble(hd.sleep)}h',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildHistoryItem(
                        icon: Icons.fitness_center,
                        title: 'Exercise (today)',
                        duration:
                            '${hd.weeklyExerciseMinutes.isNotEmpty ? hd.weeklyExerciseMinutes.last : 0} min',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required String duration,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(title, style: AppTextStyles.body)),
          Text(duration, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  static String _weekdayAbbr(int weekday) {
    // DateTime: Monday=1 ... Sunday=7
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  static String _fmtDouble(double v) {
    // แสดงทศนิยม 1 ตำแหน่งแบบสวย ๆ
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
  }
}
