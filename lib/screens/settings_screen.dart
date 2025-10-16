import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'map_settings_screen.dart';
import 'navigation_settings_screen.dart';
import 'language_settings_screen.dart';
import 'data_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode 
              ? const Color(0xFF151515) 
              : Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Настройки',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              // Поисковая строка
              _buildSearchBar(themeProvider),
              
              // Список настроек
              Expanded(
                child: ListView(
                children: [
                  _buildSettingsItem(
                    icon: Icons.person_outline,
                    title: 'Редактировать профиль',
                    themeProvider: themeProvider,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.map_outlined,
                    title: 'Карта и отображение',
                    themeProvider: themeProvider,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapSettingsScreen()),
                      );
                    },
                  ),
                    _buildSettingsItem(
                      icon: Icons.volume_up_outlined,
                      title: 'Навигация и голос',
                      themeProvider: themeProvider,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NavigationSettingsScreen()),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.language_outlined,
                      title: 'Язык и регион',
                      themeProvider: themeProvider,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.storage_outlined,
                      title: 'Данные и память',
                      themeProvider: themeProvider,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DataSettingsScreen()),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Уведомления',
                      themeProvider: themeProvider,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.lock_outline,
                      title: 'Конфиденциальность',
                      themeProvider: themeProvider,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: 'О приложении',
                      themeProvider: themeProvider,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutScreen()),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Переключатель темы
                    _buildThemeSwitch(themeProvider),
                    
                    const SizedBox(height: 100), // Отступ для iOS home indicator
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? const Color(0xFF252525) 
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: themeProvider.isDarkMode 
                ? Colors.white.withOpacity(0.6) 
                : Colors.black.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Введите текст',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? Colors.white.withOpacity(0.6) 
                    : Colors.black.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ),
          Icon(
            Icons.mic_outlined,
            color: themeProvider.isDarkMode 
                ? Colors.white.withOpacity(0.6) 
                : Colors.black.withOpacity(0.6),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: themeProvider.textColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: themeProvider.textSecondaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: const Color(0xFF252525),
          margin: const EdgeInsets.only(left: 30, right: 30),
        ),
      ],
    );
  }

  Widget _buildThemeSwitch(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Text(
            'Тема приложения',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              themeProvider.toggleTheme();
            },
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF404040),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Анимированный круг (под иконками)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: themeProvider.isDarkMode ? 40 : 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C79FE),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C79FE).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Иконки солнца и луны (поверх круга)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Icon(
                      Icons.wb_sunny,
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.6) : Colors.white,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.dark_mode,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
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