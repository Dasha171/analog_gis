import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return _buildUnauthenticatedView(context);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Профиль пользователя
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Аватар
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C79FE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: authProvider.currentUser?.profileImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  authProvider.currentUser!.profileImageUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xFF0C79FE),
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF0C79FE),
                              ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Имя пользователя
                      Text(
                        authProvider.currentUser?.fullName ?? 'Пользователь',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Email
                      Text(
                        authProvider.currentUser?.email ?? '',
                        style: const TextStyle(
                          color: Color(0xFF6C6C6C),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Кнопка редактирования
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Редактировать профиль
                        },
                        icon: const Icon(Icons.edit, color: Color(0xFF0C79FE)),
                        label: const Text(
                          'Редактировать профиль',
                          style: TextStyle(color: Color(0xFF0C79FE)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0C79FE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Настройки
                _buildSettingsSection(context),
                
                const SizedBox(height: 24),
                
                // Дополнительные функции
                _buildAdditionalSection(context),
                
                const SizedBox(height: 100), // Отступ для нижнего меню
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0C79FE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF0C79FE),
                size: 60,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Заголовок
            const Text(
              'Войдите в аккаунт',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Описание
            const Text(
              'Войдите в свой аккаунт, чтобы получить доступ ко всем функциям приложения',
              style: TextStyle(
                color: Color(0xFF6C6C6C),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Кнопка входа
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C79FE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Войти',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Настройки',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          _buildSettingsItem(
            icon: Icons.language,
            title: 'Язык',
            subtitle: 'Русский',
            onTap: () {
              // TODO: Настройки языка
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.notifications,
            title: 'Уведомления',
            subtitle: 'Включены',
            onTap: () {
              // TODO: Настройки уведомлений
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.privacy_tip,
            title: 'Приватность',
            subtitle: 'Настройки конфиденциальности',
            onTap: () {
              // TODO: Настройки приватности
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.security,
            title: 'Безопасность',
            subtitle: 'Пароль и вход',
            onTap: () {
              // TODO: Настройки безопасности
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Дополнительно',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          _buildSettingsItem(
            icon: Icons.help,
            title: 'Помощь и поддержка',
            subtitle: 'FAQ, контакты',
            onTap: () {
              // TODO: Помощь
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.info,
            title: 'О приложении',
            subtitle: 'Версия 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Выйти',
            subtitle: 'Завершить сессию',
            onTap: () {
              _showLogoutDialog(context);
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? const Color(0xFF6C6C6C),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6C6C6C),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
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
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF212121),
        title: const Text(
          'Выйти',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы действительно хотите выйти из аккаунта?',
          style: TextStyle(color: Color(0xFF6C6C6C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF6C6C6C)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              Navigator.pop(context); // Возвращаемся на главный экран
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
