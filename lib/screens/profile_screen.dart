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
import 'edit_profile_screen.dart';

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
                                authProvider.currentUser?.fullName ?? 'Имя не указано',
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const EditProfileScreen(),
                                    ),
                                  );
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
                        
                        // Для обычных пользователей показываем действия
                        if (!authProvider.isAdmin) ...[
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
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Для обычных пользователей показываем друзей и фото
                        if (!authProvider.isAdmin) ...[
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
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Кнопка выхода
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showLogoutDialog(context, themeProvider, authProvider);
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Выйти из аккаунта',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C79FE),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
            ),
          ],
        ),
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

  void _showLogoutDialog(BuildContext context, ThemeProvider themeProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Выйти из аккаунта',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Закрываем диалог
              await authProvider.signOut();
              // Навигация к главному экрану
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C79FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Выйти',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}