import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'route_planning_screen.dart';
import 'friends_screen.dart';
import 'profile_screen.dart';
import 'side_menu_screen.dart';
import '../providers/theme_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const RoutePlanningScreen(),
    const FriendsScreen(),
    const ProfileScreen(),
  ];
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.map,
      label: 'Главная',
    ),
    NavigationItem(
      icon: Icons.directions,
      label: 'Проезд',
    ),
    NavigationItem(
      icon: Icons.people,
      label: 'Друзья',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Профиль',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Нижняя панель с адресом
              if (_currentIndex == 0) _buildBottomPanel(isDark),
              
              // Основная навигация
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151515) : Colors.white,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _navigationItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = _currentIndex == index;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  color: isSelected 
                                      ? const Color(0xFF0C79FE)
                                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected 
                                        ? const Color(0xFF0C79FE)
                                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildBottomPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121).withOpacity(0.95), // Полупрозрачный фон
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Полоска-ручка сверху
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Панель с адресом и кнопкой меню
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Адрес в отдельном прямоугольнике
                Expanded(
                  child: Container(
                    height: 48, // Такая же высота как у кнопок
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ул. Каныша Сатпаева 22 Музей',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Музей им. А. Кастеева',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Кнопка меню в отдельном квадрате
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {
                      SideMenuScreen.show(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class NavigationItem {
  final IconData icon;
  final String label;
  
  NavigationItem({
    required this.icon,
    required this.label,
  });
}