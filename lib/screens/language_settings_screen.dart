import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

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
              'Язык и регион',
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
                title: 'Язык интерфейса',
                themeProvider: themeProvider,
                children: [
                  _buildRadioTile(
                    title: 'Русский',
                    subtitle: 'Русский язык',
                    value: 'ru',
                    groupValue: settingsProvider.language,
                    onChanged: (value) {
                      settingsProvider.setLanguage(value!);
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildRadioTile(
                    title: 'English',
                    subtitle: 'English language',
                    value: 'en',
                    groupValue: settingsProvider.language,
                    onChanged: (value) {
                      settingsProvider.setLanguage(value!);
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildRadioTile(
                    title: 'Қазақша',
                    subtitle: 'Казахский язык',
                    value: 'kz',
                    groupValue: settingsProvider.language,
                    onChanged: (value) {
                      settingsProvider.setLanguage(value!);
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Регион',
                themeProvider: themeProvider,
                children: [
                  _buildRadioTile(
                    title: 'Россия',
                    subtitle: 'Российская Федерация',
                    value: 'RU',
                    groupValue: settingsProvider.region,
                    onChanged: (value) {
                      settingsProvider.setRegion(value!);
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildRadioTile(
                    title: 'Казахстан',
                    subtitle: 'Қазақстан Республикасы',
                    value: 'KZ',
                    groupValue: settingsProvider.region,
                    onChanged: (value) {
                      settingsProvider.setRegion(value!);
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildRadioTile(
                    title: 'США',
                    subtitle: 'United States',
                    value: 'US',
                    groupValue: settingsProvider.region,
                    onChanged: (value) {
                      settingsProvider.setRegion(value!);
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildRadioTile(
                    title: 'Европа',
                    subtitle: 'European Union',
                    value: 'EU',
                    groupValue: settingsProvider.region,
                    onChanged: (value) {
                      settingsProvider.setRegion(value!);
                    },
                    themeProvider: themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'Формат данных',
                themeProvider: themeProvider,
                children: [
                  _buildListTile(
                    title: 'Формат даты',
                    subtitle: 'ДД.ММ.ГГГГ',
                    icon: Icons.calendar_today,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Формат времени',
                    subtitle: '24-часовой формат',
                    icon: Icons.access_time,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('В разработке')),
                      );
                    },
                    themeProvider: themeProvider,
                  ),
                  _buildListTile(
                    title: 'Единицы измерения',
                    subtitle: 'Метры, километры',
                    icon: Icons.straighten,
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

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return RadioListTile<String>(
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
      groupValue: groupValue,
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
