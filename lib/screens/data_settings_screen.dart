import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class DataSettingsScreen extends StatelessWidget {
  const DataSettingsScreen({super.key});

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
              'Данные и память',
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
                title: 'Кэш и память',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Размер кэша',
                    subtitle: '${settingsProvider.cacheSize} МБ',
                    icon: Icons.storage,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Очистить кэш',
                    subtitle: 'Освободить место на устройстве',
                    icon: Icons.cleaning_services,
                    onTap: () {
                      _showClearCacheDialog(context, settingsProvider, themeProvider);
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Офлайн карты',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Загруженные карты',
                    subtitle: 'Управление офлайн картами',
                    icon: Icons.map,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Автозагрузка карт',
                    subtitle: 'Загружать карты при подключении к Wi-Fi',
                    icon: Icons.wifi,
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
                title: 'Синхронизация',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Синхронизация данных',
                    subtitle: 'Синхронизация между устройствами',
                    icon: Icons.sync,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Резервное копирование',
                    subtitle: 'Сохранение настроек в облаке',
                    icon: Icons.cloud_upload,
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

  void _showClearCacheDialog(BuildContext context, SettingsProvider settingsProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.cardColor,
          title: Text(
            'Очистить кэш',
            style: TextStyle(color: themeProvider.textColor),
          ),
          content: Text(
            'Вы уверены, что хотите очистить кэш? Это может замедлить работу приложения.',
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
                settingsProvider.clearCache();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Кэш очищен'),
                    backgroundColor: Color(0xFF0C79FE),
                  ),
                );
              },
              child: const Text(
                'Очистить',
                style: TextStyle(color: Color(0xFF0C79FE)),
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
