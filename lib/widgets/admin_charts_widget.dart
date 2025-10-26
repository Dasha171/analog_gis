import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/advertisement_provider.dart';

class AdminChartsWidget extends StatelessWidget {
  const AdminChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, AdminProvider, AdvertisementProvider>(
      builder: (context, themeProvider, adminProvider, adProvider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // График пользователей по ролям
              _buildUsersChart(themeProvider, adminProvider),
              const SizedBox(height: 16),
              
              // График рекламы по статусам
              _buildAdvertisementsChart(themeProvider, adProvider),
              const SizedBox(height: 16),
              
              // График активности пользователей
              _buildUserActivityChart(themeProvider, adminProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersChart(ThemeProvider themeProvider, AdminProvider adminProvider) {
    final users = adminProvider.users;
    final adminCount = users.where((u) => u.role == 'admin').length;
    final managerCount = users.where((u) => u.role == 'manager').length;
    final businessCount = users.where((u) => u.role == 'business').length;
    final userCount = users.where((u) => u.role == 'user').length;

    return Container(
      height: 160, // Уменьшено с 200 до 160
      padding: const EdgeInsets.all(12), // Уменьшено с 16 до 12
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Пользователи по ролям',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14, // Уменьшено с 16 до 14
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12), // Уменьшено с 16 до 12
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.red,
                    value: adminCount.toDouble(),
                    title: 'Админы\n$adminCount',
                    radius: 35, // Уменьшено с 50 до 35
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Уменьшено с 12 до 10
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: managerCount.toDouble(),
                    title: 'Менеджеры\n$managerCount',
                    radius: 35, // Уменьшено с 50 до 35
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Уменьшено с 12 до 10
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.blue,
                    value: businessCount.toDouble(),
                    title: 'Бизнес\n$businessCount',
                    radius: 35, // Уменьшено с 50 до 35
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Уменьшено с 12 до 10
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: userCount.toDouble(),
                    title: 'Пользователи\n$userCount',
                    radius: 35, // Уменьшено с 50 до 35
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Уменьшено с 12 до 10
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 25, // Уменьшено с 40 до 25
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementsChart(ThemeProvider themeProvider, AdvertisementProvider adProvider) {
    final ads = adProvider.advertisements;
    final pendingCount = ads.where((ad) => ad.status == 'pending').length;
    final approvedCount = ads.where((ad) => ad.status == 'approved').length;
    final rejectedCount = ads.where((ad) => ad.status == 'rejected').length;
    final activeCount = ads.where((ad) => ad.isActive).length;

    return Container(
      height: 160, // Уменьшено с 200 до 160
      padding: const EdgeInsets.all(12), // Уменьшено с 16 до 12
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Реклама по статусам',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14, // Уменьшено с 16 до 14
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12), // Уменьшено с 16 до 12
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (ads.length * 1.2).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(fontSize: 10);
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Ожидает';
                            break;
                          case 1:
                            text = 'Одобрено';
                            break;
                          case 2:
                            text = 'Отклонено';
                            break;
                          case 3:
                            text = 'Активно';
                            break;
                          default:
                            text = '';
                        }
                        return Text(text, style: style);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: pendingCount.toDouble(), color: Colors.orange),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: approvedCount.toDouble(), color: Colors.green),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: rejectedCount.toDouble(), color: Colors.red),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: activeCount.toDouble(), color: Colors.blue),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivityChart(ThemeProvider themeProvider, AdminProvider adminProvider) {
    final users = adminProvider.users;
    final activeUsers = users.where((u) => u.isActive).length;
    final inactiveUsers = users.where((u) => !u.isActive).length;

    return Container(
      height: 160, // Уменьшено с 200 до 160
      padding: const EdgeInsets.all(12), // Уменьшено с 16 до 12
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Активность пользователей',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14, // Уменьшено с 16 до 14
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12), // Уменьшено с 16 до 12
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(fontSize: 10);
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Активные';
                            break;
                          case 1:
                            text = 'Неактивные';
                            break;
                          default:
                            text = '';
                        }
                        return Text(text, style: style);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 0),
                      FlSpot(0, activeUsers.toDouble()),
                      FlSpot(1, activeUsers.toDouble()),
                      FlSpot(1, inactiveUsers.toDouble()),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
