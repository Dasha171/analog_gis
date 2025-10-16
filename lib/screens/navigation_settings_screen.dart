import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class NavigationSettingsScreen extends StatelessWidget {
  const NavigationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.textColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Навигация и голос',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Голосовая навигация',
                themeProvider: themeProvider,
                children: [
                  _buildSwitchTile(
                    title: 'Включить голосовые подсказки',
                    subtitle: 'Озвучивание поворотов и направлений',
                    value: settingsProvider.voiceNavigation,
                    onChanged: (value) {
                      settingsProvider.setVoiceNavigation(value);
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Настройки маршрута',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Предпочитаемый транспорт',
                    subtitle: 'Автомобиль, пешком, общественный транспорт',
                    icon: Icons.directions_car,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Избегать платных дорог',
                    subtitle: 'Исключать платные участки из маршрута',
                    icon: Icons.money_off,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Избегать паромов',
                    subtitle: 'Исключать паромные переправы',
                    icon: Icons.directions_boat,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Уведомления',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Звуки навигации',
                    subtitle: 'Настройка звуковых сигналов',
                    icon: Icons.volume_up,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Вибрация',
                    subtitle: 'Вибрация при поворотах',
                    icon: Icons.vibration,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required ThemeProvider themeProvider,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.borderColor,
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeProvider.textSecondaryColor,
          fontSize: 14,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0C79FE),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: themeProvider.textColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeProvider.textSecondaryColor,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: themeProvider.textSecondaryColor,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
