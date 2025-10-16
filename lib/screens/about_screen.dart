import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
              'О приложении',
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
              // Логотип и название
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C79FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Anal GIS',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Версия 1.0.0',
                      style: TextStyle(
                        color: themeProvider.textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Описание
              _buildSection(
                title: 'Описание',
                themeProvider: themeProvider,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Anal GIS - современная навигационная система с поддержкой офлайн-карт, маршрутизации и справочника организаций. Аналог 2ГИС для Android, iOS и Web.',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Функции
              _buildSection(
                title: 'Основные функции',
                themeProvider: themeProvider,
                children: [
                  _buildFeatureTile(
                    icon: Icons.map,
                    title: 'Офлайн карты',
                    description: 'Загрузка и использование карт без интернета',
                    themeProvider: themeProvider,
                  ),
                  _buildFeatureTile(
                    icon: Icons.directions,
                    title: 'Маршрутизация',
                    description: 'Построение маршрутов для разных видов транспорта',
                    themeProvider: themeProvider,
                  ),
                  _buildFeatureTile(
                    icon: Icons.search,
                    title: 'Поиск POI',
                    description: 'Поиск организаций и точек интереса',
                    themeProvider: themeProvider,
                  ),
                  _buildFeatureTile(
                    icon: Icons.record_voice_over,
                    title: 'Голосовая навигация',
                    description: 'Озвучивание маршрутов и подсказок',
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Информация
              _buildSection(
                title: 'Информация',
                themeProvider: themeProvider,
                children: [
                  _buildInfoTile(
                    title: 'Разработчик',
                    value: 'Anal GIS Team',
                    themeProvider: themeProvider,
                  ),
                  _buildInfoTile(
                    title: 'Дата сборки',
                    value: '2024-01-15',
                    themeProvider: themeProvider,
                  ),
                  _buildInfoTile(
                    title: 'Платформа',
                    value: 'Flutter',
                    themeProvider: themeProvider,
                  ),
                  _buildInfoTile(
                    title: 'Лицензия',
                    value: 'MIT License',
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Контакты
              _buildSection(
                title: 'Контакты',
                themeProvider: themeProvider,
                children: [
                  _buildContactTile(
                    icon: Icons.email,
                    title: 'Email',
                    value: 'support@analgis.com',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email: support@analgis.com')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildContactTile(
                    icon: Icons.language,
                    title: 'Веб-сайт',
                    value: 'www.analgis.com',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Веб-сайт: www.analgis.com')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildContactTile(
                    icon: Icons.bug_report,
                    title: 'Сообщить об ошибке',
                    value: 'Отправить отчет',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Функция в разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
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

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
    required ThemeProvider themeProvider,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF0C79FE),
        size: 24,
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
        description,
        style: TextStyle(
          color: themeProvider.textSecondaryColor,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required ThemeProvider themeProvider,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: themeProvider.textSecondaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
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
        value,
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
