import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import 'offline_maps_screen.dart';
import 'business_registration_screen.dart';
import 'settings_screen.dart';

class SideMenuScreen extends StatefulWidget {
  const SideMenuScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SideMenuScreen(),
    );
  }

  @override
  State<SideMenuScreen> createState() => _SideMenuScreenState();
}

class _SideMenuScreenState extends State<SideMenuScreen> {
  bool _voiceNavigationEnabled = true;
  bool _nightModeEnabled = false;
  String _distanceUnit = 'км';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151515) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Индикатор перетаскивания
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Заголовок с пользователем
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.person,
                    color: isDark ? Colors.grey[300] : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Имя не указано',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.grey[300] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Список пунктов меню
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.download,
                  title: 'Оффлайн карты',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OfflineMapsScreen(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  icon: Icons.business,
                  title: 'Для бизнеса',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessRegistrationScreen(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  icon: Icons.bookmark,
                  title: 'Сохраненные места',
                  onTap: () {
                    Navigator.pop(context);
                    _showFavorites();
                  },
                ),
                
                _buildMenuItem(
                  icon: Icons.info,
                  title: 'О приложении',
                  onTap: () {
                    Navigator.pop(context);
                    _showAbout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios, 
          size: 16, 
          color: isDark ? Colors.grey[400] : Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  
  void _showFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Избранные места'),
        content: const Text('Список избранных мест будет здесь'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
  
  
  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anal GIS - Навигационная система'),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            SizedBox(height: 8),
            Text('Разработчик: Anal GIS Team'),
            SizedBox(height: 8),
            Text('Описание: Современная навигационная система с офлайн картами и маршрутизацией.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
