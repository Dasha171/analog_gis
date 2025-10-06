import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';
import '../providers/theme_provider.dart';
import 'offline_maps_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Внешний вид
          _buildSection(
            title: 'Внешний вид',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: themeProvider.isDarkMode ? Colors.amber : Colors.orange,
                    ),
                    title: Text(
                      themeProvider.isDarkMode ? 'Темная тема' : 'Светлая тема',
                    ),
                    subtitle: Text(
                      themeProvider.isDarkMode 
                          ? 'Включена темная тема' 
                          : 'Включена светлая тема',
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: Colors.blue,
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
          
          // Локализация
          _buildSection(
            title: 'Язык и регион',
            children: [
              Consumer<LocalizationProvider>(
                builder: (context, localizationProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Язык'),
                    subtitle: Text(
                      localizationProvider.locale.languageCode == 'ru' 
                          ? 'Русский' 
                          : 'English',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      localizationProvider.toggleLanguage();
                    },
                  );
                },
              ),
            ],
          ),
          
          // Навигация
          _buildSection(
            title: 'Навигация',
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Голосовые подсказки'),
                subtitle: const Text('Включить озвучивание маршрутов'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Сохранить настройку
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Избегать пробок'),
                subtitle: const Text('Учитывать загруженность дорог'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Сохранить настройку
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.toll),
                title: const Text('Избегать платных дорог'),
                subtitle: const Text('Прокладывать маршруты без платных участков'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Сохранить настройку
                  },
                ),
              ),
            ],
          ),
          
          // Карты
          _buildSection(
            title: 'Карты',
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Офлайн карты'),
                subtitle: const Text('Загруженные регионы'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OfflineMapsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.layers),
                title: const Text('Стиль карты'),
                subtitle: const Text('Стандартная'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showMapStyleDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Ночной режим'),
                subtitle: const Text('Темная тема карты'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Сохранить настройку
                  },
                ),
              ),
            ],
          ),
          
          // Уведомления
          _buildSection(
            title: 'Уведомления',
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Push-уведомления'),
                subtitle: const Text('Получать уведомления о пробках и событиях'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Сохранить настройку
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Уведомления о местоположении'),
                subtitle: const Text('Разрешить доступ к геолокации'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Сохранить настройку
                  },
                ),
              ),
            ],
          ),
          
          // Приватность
          _buildSection(
            title: 'Приватность',
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Политика конфиденциальности'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Открыть политику конфиденциальности
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Условия использования'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Открыть условия использования
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Удалить данные'),
                subtitle: const Text('Очистить кэш и сохраненные данные'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showDeleteDataDialog(context);
                },
              ),
            ],
          ),
          
          // О приложении
          _buildSection(
            title: 'О приложении',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Версия'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Оценить приложение'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Открыть страницу в магазине приложений
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Обратная связь'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Открыть форму обратной связи
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
  
  void _showOfflineMapsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Офлайн карты'),
        content: const Text(
          'Загрузите карты регионов для использования без интернета.\n\n'
          'Доступные регионы:\n'
          '• Алматы (150 МБ)\n'
          '• Астана (120 МБ)\n'
          '• Шымкент (80 МБ)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Показать экран загрузки карт
            },
            child: const Text('Загрузить'),
          ),
        ],
      ),
    );
  }
  
  void _showMapStyleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Стиль карты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Стандартная'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Спутник'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Рельеф'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить данные'),
        content: const Text(
          'Это действие удалит все загруженные карты, '
          'историю поиска и другие сохраненные данные. '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Удалить данные
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Данные удалены')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
