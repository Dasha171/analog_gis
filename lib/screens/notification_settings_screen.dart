import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

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
              'Уведомления',
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
                title: 'Общие уведомления',
                themeProvider: themeProvider,
                children: [
                  _buildSwitchTile(
                    title: 'Включить уведомления',
                    subtitle: 'Получать push-уведомления',
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      settingsProvider.setNotificationsEnabled(value);
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Типы уведомлений',
                themeProvider: themeProvider,
                children: [
                  _buildSwitchTile(
                    title: 'Навигационные уведомления',
                    subtitle: 'Уведомления о поворотах и маршруте',
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      // TODO: Implement navigation notifications
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildSwitchTile(
                    title: 'Обновления карт',
                    subtitle: 'Уведомления о новых версиях карт',
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      // TODO: Implement map updates notifications
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildSwitchTile(
                    title: 'Рекомендации',
                    subtitle: 'Персональные рекомендации мест',
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) {
                      // TODO: Implement recommendations notifications
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Время уведомлений',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Тихие часы',
                    subtitle: 'Не беспокоить с 22:00 до 08:00',
                    icon: Icons.bedtime,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Расписание уведомлений',
                    subtitle: 'Настроить время получения уведомлений',
                    icon: Icons.schedule,
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
