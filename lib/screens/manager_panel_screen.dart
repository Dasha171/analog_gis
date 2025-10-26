import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/advertisement_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import 'add_advertisement_screen.dart';

class ManagerPanelScreen extends StatefulWidget {
  const ManagerPanelScreen({super.key});

  @override
  State<ManagerPanelScreen> createState() => _ManagerPanelScreenState();
}

class _ManagerPanelScreenState extends State<ManagerPanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvertisementProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ThemeProvider, AdvertisementProvider, AuthProvider, AdminProvider>(
      builder: (context, themeProvider, adProvider, authProvider, adminProvider, child) {
        if (!authProvider.isManager) {
          return Scaffold(
            backgroundColor: themeProvider.backgroundColor,
            body: Center(
              child: Text(
                'Доступ запрещен',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: adProvider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF0C79FE),
                  ),
                )
              : Column(
                  children: [
                    // Кастомный AppBar
                    Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 24,
                        right: 24,
                        bottom: 16,
                      ),
                      decoration: BoxDecoration(
                        color: themeProvider.backgroundColor,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Панель менеджера',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: themeProvider.textColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddAdvertisementScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Содержимое
                    Expanded(
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            // Кастомные табы
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF151515),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TabBar(
                                indicator: BoxDecoration(
                                  color: const Color(0xFF0C79FE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                                labelColor: Colors.white,
                                unselectedLabelColor: themeProvider.textSecondaryColor,
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                                tabs: const [
                                  Tab(text: 'Мои объявления'),
                                  Tab(text: 'Статистика'),
                                  Tab(text: 'Разрешения'),
                                ],
                              ),
                            ),
                            
                            // Содержимое табов
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildAdvertisementsTab(context, themeProvider, adProvider, authProvider),
                                  _buildStatsTab(context, themeProvider, adProvider, authProvider),
                                  _buildPermissionsTab(context, themeProvider, adProvider, authProvider, adminProvider),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAdvertisementsTab(BuildContext context, ThemeProvider themeProvider, AdvertisementProvider adProvider, AuthProvider authProvider) {
    final managerAds = adProvider.advertisements.where((ad) => ad.managerId == authProvider.currentUser?.id).toList();
    
    if (managerAds.isEmpty) {
      return _buildEmptyState(
        themeProvider,
        Icons.campaign,
        'Нет рекламных объявлений',
        'Добавьте свое первое рекламное объявление',
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAdvertisementScreen()),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: managerAds.length,
      itemBuilder: (context, index) {
        final ad = managerAds[index];
        return _buildAdvertisementCard(context, themeProvider, ad);
      },
    );
  }

  Widget _buildStatsTab(BuildContext context, ThemeProvider themeProvider, AdvertisementProvider adProvider, AuthProvider authProvider) {
    final managerAds = adProvider.advertisements.where((ad) => ad.managerId == authProvider.currentUser?.id).toList();
    final totalViews = managerAds.fold(0, (sum, ad) => sum + (ad.views ?? 0));
    final totalClicks = managerAds.fold(0, (sum, ad) => sum + (ad.clicks ?? 0));
    final approvedAds = managerAds.where((ad) => ad.status == 'approved').length;
    final pendingAds = managerAds.where((ad) => ad.status == 'pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика рекламы',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Статистические карточки
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildStatCard(themeProvider, 'Всего объявлений', '${managerAds.length}', Icons.campaign, const Color(0xFF0C79FE)),
                  _buildStatCard(themeProvider, 'Одобренных', '$approvedAds', Icons.check_circle, Colors.green),
                  _buildStatCard(themeProvider, 'На рассмотрении', '$pendingAds', Icons.pending, Colors.orange),
                  _buildStatCard(themeProvider, 'Просмотры', '$totalViews', Icons.visibility, Colors.purple),
                  _buildStatCard(themeProvider, 'Клики', '$totalClicks', Icons.mouse, Colors.pink),
                  _buildStatCard(themeProvider, 'CTR', totalViews > 0 ? '${(totalClicks / totalViews * 100).toStringAsFixed(1)}%' : '0%', Icons.trending_up, Colors.red),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab(BuildContext context, ThemeProvider themeProvider, AdvertisementProvider adProvider, AuthProvider authProvider, AdminProvider adminProvider) {
    final managerCities = adminProvider.getManagerCities(authProvider.currentUser?.id ?? '');
    final cities = adProvider.cities.where((city) => managerCities.contains(city.id)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Разрешения',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Разрешения
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваши права',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPermissionItem(themeProvider, 'Добавлять рекламу', true),
                _buildPermissionItem(themeProvider, 'Редактировать рекламу', true),
                _buildPermissionItem(themeProvider, 'Удалять рекламу', false),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Разрешенные города
          Text(
            'Разрешенные города',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (cities.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Нет разрешенных городов',
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...cities.map((city) => _buildCityCard(themeProvider, city)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0C79FE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0C79FE),
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add),
              label: const Text('Добавить объявление'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C79FE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvertisementCard(BuildContext context, ThemeProvider themeProvider, dynamic ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(ad.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Обработка ошибки загрузки изображения
                    },
                  ),
                ),
                child: ad.imageUrl.isEmpty
                    ? Icon(Icons.image, color: themeProvider.textSecondaryColor)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.cityName,
                      style: TextStyle(
                        color: themeProvider.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ad.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(ad.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(themeProvider, 'Просмотры', '${ad.views}', Icons.visibility),
              ),
              Expanded(
                child: _buildStatItem(themeProvider, 'Клики', '${ad.clicks}', Icons.mouse),
              ),
              Expanded(
                child: _buildStatItem(themeProvider, 'CTR', ad.views > 0 ? '${(ad.clicks / ad.views * 100).toStringAsFixed(1)}%' : '0%', Icons.trending_up),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeProvider themeProvider, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(ThemeProvider themeProvider, String title, bool allowed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle : Icons.cancel,
            color: allowed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(ThemeProvider themeProvider, dynamic city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_city,
            color: const Color(0xFF0C79FE),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  city.country,
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeProvider themeProvider, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: themeProvider.textSecondaryColor, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: themeProvider.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'blocked':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'ОДОБРЕНО';
      case 'pending':
        return 'НА РАССМОТРЕНИИ';
      case 'rejected':
        return 'ОТКЛОНЕНО';
      case 'blocked':
        return 'ЗАБЛОКИРОВАНО';
      default:
        return 'НЕИЗВЕСТНО';
    }
  }
}
