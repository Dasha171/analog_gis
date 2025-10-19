import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, AdminProvider, AuthProvider>(
      builder: (context, themeProvider, adminProvider, authProvider, child) {
        if (!authProvider.isAdmin) {
          return Scaffold(
            backgroundColor: themeProvider.backgroundColor,
            body: Center(
              child: Text(
                'Доступ запрещен',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Админ панель',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: themeProvider.textColor),
                onPressed: () {
                  adminProvider.updateStats();
                },
              ),
            ],
          ),
          body: adminProvider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF0C79FE),
                  ),
                )
              : DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      // Табы
                      Container(
                        color: themeProvider.cardColor,
                        child: TabBar(
                          indicatorColor: const Color(0xFF0C79FE),
                          labelColor: themeProvider.textColor,
                          unselectedLabelColor: themeProvider.textSecondaryColor,
                          tabs: const [
                            Tab(text: 'Статистика'),
                            Tab(text: 'Пользователи'),
                            Tab(text: 'Организации'),
                            Tab(text: 'Настройки'),
                          ],
                        ),
                      ),
                      
                      // Содержимое табов
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildStatsTab(context, themeProvider, adminProvider),
                            _buildUsersTab(context, themeProvider, adminProvider),
                            _buildOrganizationsTab(context, themeProvider, adminProvider),
                            _buildSettingsTab(context, themeProvider, adminProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStatsTab(BuildContext context, ThemeProvider themeProvider, AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Общая статистика
          _buildStatsCard(
            themeProvider,
            'Общая статистика',
            [
              _buildStatItem(themeProvider, 'Всего пользователей', '${adminProvider.appStats.totalUsers}', Icons.people),
              _buildStatItem(themeProvider, 'Активных пользователей', '${adminProvider.appStats.activeUsers}', Icons.person),
              _buildStatItem(themeProvider, 'Организаций', '${adminProvider.appStats.totalOrganizations}', Icons.business),
              _buildStatItem(themeProvider, 'Отзывов', '${adminProvider.appStats.totalReviews}', Icons.rate_review),
              _buildStatItem(themeProvider, 'Фотографий', '${adminProvider.appStats.totalPhotos}', Icons.photo_library),
              _buildStatItem(themeProvider, 'Дружеских связей', '${adminProvider.appStats.totalFriendships}', Icons.favorite),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Графики (заглушки)
          _buildChartCard(themeProvider, 'Активность пользователей', 'График активности за последние 30 дней'),
          _buildChartCard(themeProvider, 'Популярные места', 'Топ-10 самых посещаемых мест'),
          _buildChartCard(themeProvider, 'География пользователей', 'Распределение пользователей по регионам'),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, ThemeProvider themeProvider, AdminProvider adminProvider) {
    return Column(
      children: [
        // Кнопка добавления пользователя
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(context, themeProvider, adminProvider),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Добавить пользователя'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C79FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Список пользователей
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: adminProvider.users.length,
            itemBuilder: (context, index) {
              final user = adminProvider.users[index];
              return _buildUserItem(context, themeProvider, adminProvider, user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationsTab(BuildContext context, ThemeProvider themeProvider, AdminProvider adminProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0C79FE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.business,
                color: Color(0xFF0C79FE),
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Управление организациями',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Здесь будет управление организациями, модерация отзывов и управление контентом',
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context, ThemeProvider themeProvider, AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsCard(
            themeProvider,
            'Системные настройки',
            [
              _buildSettingsItem(themeProvider, 'Уведомления', 'Настройка push-уведомлений', Icons.notifications),
              _buildSettingsItem(themeProvider, 'Резервное копирование', 'Автоматическое резервное копирование', Icons.backup),
              _buildSettingsItem(themeProvider, 'Безопасность', 'Настройки безопасности', Icons.security),
              _buildSettingsItem(themeProvider, 'Логи', 'Просмотр системных логов', Icons.list_alt),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingsCard(
            themeProvider,
            'Реклама и монетизация',
            [
              _buildSettingsItem(themeProvider, 'Баннеры', 'Управление рекламными баннерами', Icons.ads_click),
              _buildSettingsItem(themeProvider, 'Промо-акции', 'Создание промо-акций', Icons.local_offer),
              _buildSettingsItem(themeProvider, 'Партнеры', 'Управление партнерами', Icons.handshake),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeProvider themeProvider, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeProvider themeProvider, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0C79FE), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(ThemeProvider themeProvider, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: themeProvider.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'График будет здесь',
                style: TextStyle(
                  color: themeProvider.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, ThemeProvider themeProvider, AdminProvider adminProvider, dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getRoleIcon(user.role),
              color: _getRoleColor(user.role),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Создан: ${_formatDate(user.createdAt)}',
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  color: user.isActive ? Colors.red : Colors.green,
                ),
                onPressed: () {
                  adminProvider.toggleUserStatus(user.id);
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: themeProvider.textSecondaryColor),
                onSelected: (value) {
                  switch (value) {
                    case 'edit_role':
                      _showEditRoleDialog(context, themeProvider, adminProvider, user);
                      break;
                    case 'delete':
                      adminProvider.deleteUser(user.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit_role',
                    child: Text('Изменить роль'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Удалить'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ThemeProvider themeProvider, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(ThemeProvider themeProvider, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Переход к настройкам
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0C79FE), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: themeProvider.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: themeProvider.textSecondaryColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'moderator':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'moderator':
        return Icons.shield;
      default:
        return Icons.person;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showAddUserDialog(BuildContext context, ThemeProvider themeProvider, AdminProvider adminProvider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Добавить пользователя',
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: themeProvider.textColor),
              decoration: InputDecoration(
                labelText: 'Имя',
                labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                filled: true,
                fillColor: themeProvider.surfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: TextStyle(color: themeProvider.textColor),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                filled: true,
                fillColor: themeProvider.surfaceColor,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: 'Роль',
                labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                filled: true,
                fillColor: themeProvider.surfaceColor,
              ),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('Пользователь')),
                DropdownMenuItem(value: 'moderator', child: Text('Модератор')),
                DropdownMenuItem(value: 'admin', child: Text('Администратор')),
              ],
              onChanged: (value) => selectedRole = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: themeProvider.textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminProvider.addUser(
                nameController.text,
                emailController.text,
                selectedRole,
              );
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пользователь добавлен'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, ThemeProvider themeProvider, AdminProvider adminProvider, dynamic user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Изменить роль',
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: InputDecoration(
            labelText: 'Роль',
            labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
            filled: true,
            fillColor: themeProvider.surfaceColor,
          ),
          items: const [
            DropdownMenuItem(value: 'user', child: Text('Пользователь')),
            DropdownMenuItem(value: 'moderator', child: Text('Модератор')),
            DropdownMenuItem(value: 'admin', child: Text('Администратор')),
          ],
          onChanged: (value) => selectedRole = value!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: TextStyle(color: themeProvider.textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              adminProvider.updateUserRole(user.id, selectedRole);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
