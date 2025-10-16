import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/business_provider.dart';

class AddOrganizationScreen extends StatefulWidget {
  const AddOrganizationScreen({super.key});

  @override
  State<AddOrganizationScreen> createState() => _AddOrganizationScreenState();
}

class _AddOrganizationScreenState extends State<AddOrganizationScreen> {
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
              'Добавление организации',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
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
                  
                  // Выберите адрес на карте
                  _buildSectionTitle('Выберите адрес на карте', themeProvider),
                  const SizedBox(height: 8),
                  _buildMapSelector(themeProvider),
                  
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
                  
                  // Кнопка продолжить
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: businessProvider.isLoading ? null : _handleContinue,
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
                              'Продолжить',
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

  Widget _buildMapSelector(ThemeProvider themeProvider) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Имитация карты
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: MapPainter(themeProvider),
            ),
          ),
          
          // Иконка карты
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: themeProvider.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.map_outlined,
                color: themeProvider.textColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(ThemeProvider themeProvider) {
    return Container(
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
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final businessProvider = context.read<BusinessProvider>();
    final success = await businessProvider.addOrganization(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      category: _selectedCategory,
      website: _websiteController.text.trim().isNotEmpty 
          ? _websiteController.text.trim() 
          : null,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Организация добавлена успешно!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class MapPainter extends CustomPainter {
  final ThemeProvider themeProvider;

  MapPainter(this.themeProvider);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeProvider.textColor.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Рисуем линии улиц
    for (int i = 0; i < 5; i++) {
      final y = (size.height / 6) * (i + 1);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    for (int i = 0; i < 4; i++) {
      final x = (size.width / 5) * (i + 1);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Рисуем реку/путь
    final riverPaint = Paint()
      ..color = const Color(0xFF0C79FE).withOpacity(0.3)
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(size.width * 0.8, 0);
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.9,
      size.width * 0.8,
      size.height,
    );

    canvas.drawPath(path, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
