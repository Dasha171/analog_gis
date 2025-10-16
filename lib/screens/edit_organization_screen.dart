import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/business_provider.dart';
import '../models/organization_model.dart';

class EditOrganizationScreen extends StatefulWidget {
  final Organization organization;
  
  const EditOrganizationScreen({
    super.key,
    required this.organization,
  });

  @override
  State<EditOrganizationScreen> createState() => _EditOrganizationScreenState();
}

class _EditOrganizationScreenState extends State<EditOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  
  String _selectedCategory = 'Ресторан';
  final List<String> _categories = [
    'Ресторан',
    'Кафе',
    'Магазин',
    'Отель',
    'Аптека',
    'Банк',
    'Больница',
    'Школа',
    'Другое',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  void _loadOrganizationData() {
    _nameController.text = widget.organization.name;
    _addressController.text = widget.organization.address;
    _phoneController.text = widget.organization.phone;
    _websiteController.text = widget.organization.website ?? '';
    _selectedCategory = widget.organization.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BusinessProvider, ThemeProvider>(
      builder: (context, businessProvider, themeProvider, child) {
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
              'Редактировать организацию',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: businessProvider.isLoading ? null : _handleSave,
                child: businessProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF0C79FE),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Сохранить',
                        style: TextStyle(
                          color: Color(0xFF0C79FE),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название организации
                  _buildSectionTitle('Название организации', themeProvider),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Введите название',
                    themeProvider: themeProvider,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите название организации';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Адрес
                  _buildSectionTitle('Адрес', themeProvider),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _addressController,
                    hintText: 'Тверская ул. 15',
                    themeProvider: themeProvider,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите адрес организации';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Телефон
                  _buildSectionTitle('Телефон', themeProvider),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: '+7 707 77 77 777',
                    themeProvider: themeProvider,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите телефон организации';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Категория
                  _buildSectionTitle('Категория', themeProvider),
                  const SizedBox(height: 8),
                  _buildCategorySelector(themeProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Сайт организации
                  _buildSectionTitle('Сайт организации', themeProvider),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _websiteController,
                    hintText: 'Введите сайт',
                    themeProvider: themeProvider,
                    keyboardType: TextInputType.url,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Кнопка сохранения
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: businessProvider.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C79FE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: businessProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Сохранить изменения',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(
        color: themeProvider.textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ThemeProvider themeProvider,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: themeProvider.textColor),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
        filled: true,
        fillColor: themeProvider.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0C79FE), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        _showCategoryDialog(themeProvider);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCategory,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: themeProvider.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Выберите категорию',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return ListTile(
              title: Text(
                category,
                style: TextStyle(
                  color: themeProvider.textColor,
                ),
              ),
              trailing: _selectedCategory == category
                  ? const Icon(
                      Icons.check,
                      color: Color(0xFF0C79FE),
                    )
                  : null,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final businessProvider = context.read<BusinessProvider>();
    
    final updatedOrganization = widget.organization.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      category: _selectedCategory,
      website: _websiteController.text.trim().isNotEmpty 
          ? _websiteController.text.trim() 
          : null,
      updatedAt: DateTime.now(),
    );

    final success = await businessProvider.updateOrganization(updatedOrganization);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Организация успешно обновлена!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
