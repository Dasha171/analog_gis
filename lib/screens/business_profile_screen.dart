import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/business_provider.dart';
import '../models/business_user_model.dart';
import '../models/organization_model.dart';
import 'business_register_screen.dart';
import 'business_login_screen.dart';
import 'edit_profile_screen.dart';
import 'edit_organization_screen.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BusinessProvider, ThemeProvider>(
      builder: (context, businessProvider, themeProvider, child) {
        if (!businessProvider.isAuthenticated) {
          return _buildUnauthenticatedView(context, themeProvider);
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
              'Личный кабинет',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit, color: themeProvider.textColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Профиль пользователя
                _buildUserProfile(businessProvider.currentBusinessUser!, themeProvider),
                
                const SizedBox(height: 24),
                
                // Статистика
                _buildStatistics(businessProvider, themeProvider),
                
                const SizedBox(height: 24),
                
                // Мои организации
                _buildMyOrganizations(context, businessProvider, themeProvider),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context, ThemeProvider themeProvider) {
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
          'Личный кабинет',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C79FE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.business,
                  color: Color(0xFF0C79FE),
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Войдите в личный кабинет',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Управляйте своими организациями,\nотслеживайте статистику и многое другое',
                style: TextStyle(
                  color: themeProvider.textSecondaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Кнопка входа
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessLoginScreen(),
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
              
              const SizedBox(height: 16),
              
              // Кнопка регистрации
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessRegisterScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0C79FE)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Зарегистрироваться',
                    style: TextStyle(
                      color: Color(0xFF0C79FE),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BusinessUser user, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Аватар
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Информация о пользователе
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.name} ${user.surname}',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Рейтинг
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < user.rating.floor()
                                ? Icons.star
                                : index < user.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          user.rating.toString(),
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Контактная информация
          Row(
            children: [
              Icon(
                Icons.phone,
                color: const Color(0xFF0C79FE),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                user.phone,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${user.totalOrganizations} организаций',
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BusinessProvider businessProvider, ThemeProvider themeProvider) {
    final totalViews = businessProvider.organizations.fold<int>(
      0, (sum, org) => sum + org.viewsPerMonth);
    final totalRoutes = businessProvider.organizations.fold<int>(
      0, (sum, org) => sum + org.routesBuilt);
    final totalPromotions = businessProvider.organizations.fold<int>(
      0, (sum, org) => sum + org.promotionsActivated);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статистика',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildStatItem(
                icon: Icons.visibility,
                title: 'Просмотры за месяц',
                value: '$totalViews',
                themeProvider: themeProvider,
              ),
              
              const SizedBox(height: 16),
              
              _buildStatItem(
                icon: Icons.route,
                title: 'Построено маршрутов',
                value: '$totalRoutes',
                themeProvider: themeProvider,
              ),
              
              const SizedBox(height: 16),
              
              _buildStatItem(
                icon: Icons.local_offer,
                title: 'Акций активировано',
                value: '$totalPromotions',
                themeProvider: themeProvider,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required ThemeProvider themeProvider,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: themeProvider.textColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMyOrganizations(BuildContext context, BusinessProvider businessProvider, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Мои организации',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (businessProvider.organizations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.business_outlined,
                  color: themeProvider.textSecondaryColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'У вас пока нет организаций',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Добавьте свою первую организацию',
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...businessProvider.organizations.map((org) => 
            _buildOrganizationCard(context, org, themeProvider)
          ),
      ],
    );
  }

  Widget _buildOrganizationCard(BuildContext context, Organization org, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Иконка категории
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(org.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(org.category),
              color: _getCategoryColor(org.category),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Информация об организации
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.name,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        org.address,
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: org.isPublished ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: org.isPublished
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 8,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      org.isPublished ? 'Опубликовано' : 'Не опубликовано',
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Рейтинг и кнопка редактирования
          Column(
            children: [
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < org.rating.floor()
                          ? Icons.star
                          : index < org.rating
                              ? Icons.star_half
                              : Icons.star_border,
                      color: Colors.amber,
                      size: 12,
                    );
                  }),
                  const SizedBox(width: 4),
                  Text(
                    org.rating.toString(),
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: themeProvider.textSecondaryColor,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditOrganizationScreen(
                        organization: org,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ресторан':
        return Colors.orange;
      case 'кафе':
        return Colors.brown;
      case 'магазин':
        return Colors.blue;
      case 'отель':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ресторан':
        return Icons.restaurant;
      case 'кафе':
        return Icons.local_cafe;
      case 'магазин':
        return Icons.store;
      case 'отель':
        return Icons.hotel;
      default:
        return Icons.business;
    }
  }
}
