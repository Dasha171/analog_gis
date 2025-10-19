import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_actions_provider.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import 'reviews_screen.dart';
import 'visited_places_screen.dart';
import 'photos_screen.dart';
import 'friends_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            title: Text(
              'Профиль',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isAuthenticated) {
                return _buildUnauthenticatedView(context, themeProvider);
              }

              return Consumer<UserActionsProvider>(
                builder: (context, userActionsProvider, child) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Профиль пользователя
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: themeProvider.cardColor,
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
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Email
                          Text(
                            authProvider.currentUser?.email ?? '',
                            style: TextStyle(
                              color: themeProvider.textSecondaryColor,
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
                        
                        // Избранное
                        _buildActionSection(
                          context,
                          themeProvider,
                          userActionsProvider,
                          'Избранное',
                          Icons.favorite,
                          userActionsProvider.favorites.length,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Мои отзывы
                        _buildActionSection(
                          context,
                          themeProvider,
                          userActionsProvider,
                          'Мои отзывы',
                          Icons.rate_review,
                          userActionsProvider.reviews.length,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReviewsScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Посещенные места
                        _buildActionSection(
                          context,
                          themeProvider,
                          userActionsProvider,
                          'Посещенные места',
                          Icons.location_on,
                          userActionsProvider.visitedPlaces.length,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const VisitedPlacesScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Друзья
                        _buildActionSection(
                          context,
                          themeProvider,
                          userActionsProvider,
                          'Друзья',
                          Icons.people,
                          userActionsProvider.friends.length,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FriendsScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Фото
                        _buildActionSection(
                          context,
                          themeProvider,
                          userActionsProvider,
                          'Фото',
                          Icons.photo_library,
                          userActionsProvider.photos.length,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PhotosScreen()),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 100), // Отступ для нижнего меню
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context, ThemeProvider themeProvider) {
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
            Text(
              'Войдите в аккаунт',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Описание
            Text(
              'Войдите в свой аккаунт, чтобы получить доступ ко всем функциям приложения',
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
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
  
  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Настройки',
              style: TextStyle(
                color: themeProvider.textColor,
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
            themeProvider: themeProvider,
          ),
          
          _buildSettingsItem(
            icon: Icons.notifications,
            title: 'Уведомления',
            subtitle: 'Включены',
            onTap: () {
              // TODO: Настройки уведомлений
            },
            themeProvider: themeProvider,
          ),
          
          _buildSettingsItem(
            icon: Icons.privacy_tip,
            title: 'Приватность',
            subtitle: 'Настройки конфиденциальности',
            onTap: () {
              // TODO: Настройки приватности
            },
            themeProvider: themeProvider,
          ),
          
          _buildSettingsItem(
            icon: Icons.security,
            title: 'Безопасность',
            subtitle: 'Пароль и вход',
            onTap: () {
              // TODO: Настройки безопасности
            },
            themeProvider: themeProvider,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Дополнительно',
              style: TextStyle(
                color: themeProvider.textColor,
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
            themeProvider: themeProvider,
          ),
          
          _buildSettingsItem(
            icon: Icons.info,
            title: 'О приложении',
            subtitle: 'Версия 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
            themeProvider: themeProvider,
          ),
          
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Выйти',
            subtitle: 'Завершить сессию',
            onTap: () {
              _showLogoutDialog(context);
            },
            textColor: Colors.red,
            themeProvider: themeProvider,
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
    required ThemeProvider themeProvider,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? themeProvider.textSecondaryColor,
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
                      color: textColor ?? themeProvider.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: themeProvider.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: themeProvider.textSecondaryColor,
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

  Widget _buildActionSection(
    BuildContext context,
    ThemeProvider themeProvider,
    UserActionsProvider userActionsProvider,
    String title,
    IconData icon,
    int count,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C79FE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0C79FE),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count ${_getCountText(count)}',
                      style: TextStyle(
                        color: themeProvider.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
    );
  }

  String _getCountText(int count) {
    if (count == 0) return 'пока нет';
    if (count == 1) return 'место';
    if (count >= 2 && count <= 4) return 'места';
    return 'мест';
  }
}
