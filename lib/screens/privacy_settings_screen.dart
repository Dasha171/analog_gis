import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

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
              'Конфиденциальность',
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
                title: 'Данные о местоположении',
                themeProvider: themeProvider,
                children: [
                  _buildSwitchTile(
                    title: 'Поделиться местоположением',
                    subtitle: 'Разрешить приложению использовать GPS',
                    value: settingsProvider.locationSharing,
                    onChanged: (value) {
                      settingsProvider.setLocationSharing(value);
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Точность местоположения',
                    subtitle: 'Высокая точность, экономия батареи',
                    icon: Icons.gps_fixed,
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
                title: 'Аналитика и улучшения',
                themeProvider: themeProvider,
                children: [
                  _buildSwitchTile(
                    title: 'Аналитика использования',
                    subtitle: 'Помочь улучшить приложение',
                    value: settingsProvider.analyticsEnabled,
                    onChanged: (value) {
                      settingsProvider.setAnalyticsEnabled(value);
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Отчеты об ошибках',
                    subtitle: 'Автоматически отправлять отчеты',
                    icon: Icons.bug_report,
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
                title: 'Безопасность',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Биометрическая аутентификация',
                    subtitle: 'Вход по отпечатку или Face ID',
                    icon: Icons.fingerprint,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Двухфакторная аутентификация',
                    subtitle: 'Дополнительная защита аккаунта',
                    icon: Icons.security,
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
                title: 'Управление данными',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Экспорт данных',
                    subtitle: 'Скачать все ваши данные',
                    icon: Icons.download,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Удалить аккаунт',
                    subtitle: 'Безвозвратно удалить все данные',
                    icon: Icons.delete_forever,
                    onTap: () {
                      _showDeleteAccountDialog(context, themeProvider);
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

  void _showDeleteAccountDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.cardColor,
          title: Text(
            'Удалить аккаунт',
            style: TextStyle(color: themeProvider.textColor),
          ),
          content: Text(
            'Вы уверены, что хотите удалить аккаунт? Это действие нельзя отменить.',
            style: TextStyle(color: themeProvider.textSecondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(color: themeProvider.textSecondaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функция в разработке'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
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
