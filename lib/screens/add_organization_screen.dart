import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/organization_provider.dart';
import '../models/organization_model.dart';

class AddOrganizationScreen extends StatefulWidget {
  const AddOrganizationScreen({super.key});

  @override
  State<AddOrganizationScreen> createState() => _AddOrganizationScreenState();
}

class _AddOrganizationScreenState extends State<AddOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  
  String _selectedCategory = 'Кафе';
  double _selectedLatitude = 43.238949; // Алматы по умолчанию
  double _selectedLongitude = 76.889709;
  bool _isLoading = false;

  final List<String> _categories = [
    'Кафе',
    'Ресторан',
    'Медицина',
    'Магазин',
    'Банк',
    'Аптека',
    'Спорт',
    'Образование',
    'Красота',
    'Автосервис',
    'Другое',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, OrganizationProvider>(
      builder: (context, themeProvider, organizationProvider, child) {
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
              'Добавить организацию',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
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
                  // Основная информация
                  _buildSectionTitle('Основная информация', themeProvider),
                  const SizedBox(height: 16),
                  
                  // Название
                  _buildTextField(
                    controller: _nameController,
                    label: 'Название организации',
                    hint: 'Введите название',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите название организации';
                      }
                      return null;
                    },
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Категория
                  _buildDropdownField(
                    label: 'Категория',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Описание
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Описание',
                    hint: 'Краткое описание организации',
                    maxLines: 3,
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Контактная информация
                  _buildSectionTitle('Контактная информация', themeProvider),
                  const SizedBox(height: 16),
                  
                  // Адрес
                  _buildTextField(
                    controller: _addressController,
                    label: 'Адрес',
                    hint: 'Введите адрес',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите адрес организации';
                      }
                      return null;
                    },
                    themeProvider: themeProvider,
                    onTap: () => _showMapDialog(context, themeProvider),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Телефон
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Телефон',
                    hint: '+7 (xxx) xxx-xx-xx',
                    keyboardType: TextInputType.phone,
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Веб-сайт
                  _buildTextField(
                    controller: _websiteController,
                    label: 'Веб-сайт',
                    hint: 'https://example.com',
                    keyboardType: TextInputType.url,
                    themeProvider: themeProvider,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Координаты
                  _buildSectionTitle('Местоположение на карте', themeProvider),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeProvider.textSecondaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: const Color(0xFF0C79FE)),
                            const SizedBox(width: 8),
                            Text(
                              'Координаты',
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Широта: $_selectedLatitude',
                          style: TextStyle(color: themeProvider.textSecondaryColor),
                        ),
                        Text(
                          'Долгота: $_selectedLongitude',
                          style: TextStyle(color: themeProvider.textSecondaryColor),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showMapDialog(context, themeProvider),
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Выбрать на карте'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C79FE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeProvider themeProvider,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onTap: onTap,
          readOnly: onTap != null,
          style: TextStyle(color: themeProvider.textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
            filled: true,
            fillColor: themeProvider.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeProvider.textSecondaryColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0C79FE)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeProvider.textSecondaryColor.withOpacity(0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            style: TextStyle(color: themeProvider.textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: themeProvider.cardColor,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showMapDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'Выбор местоположения',
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Text(
                'Нажмите на карту, чтобы выбрать местоположение',
                style: TextStyle(color: themeProvider.textSecondaryColor),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeProvider.textSecondaryColor.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 64,
                          color: themeProvider.textSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Карта будет здесь',
                          style: TextStyle(color: themeProvider.textSecondaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Координаты: $_selectedLatitude, $_selectedLongitude',
                          style: TextStyle(color: themeProvider.textSecondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: themeProvider.textSecondaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Здесь будет логика выбора координат
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C79FE),
              foregroundColor: Colors.white,
            ),
            child: const Text('Выбрать'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final organization = Organization(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        email: 'admin@example.com', // В реальном приложении - email владельца
        ownerId: 'admin', // В реальном приложении - ID текущего пользователя
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        isVerified: true,
        isPublished: true,
      );

      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
      await organizationProvider.addOrganization(organization);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Организация успешно добавлена'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}