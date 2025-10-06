import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/poi_model.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  State<BusinessRegistrationScreen> createState() => _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState extends State<BusinessRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openingHoursController = TextEditingController();
  
  String _selectedCategory = 'restaurant';
  LatLng? _selectedLocation;
  bool _isLoading = false;
  
  final List<Map<String, String>> _categories = [
    {'value': 'restaurant', 'label': 'Ресторан/Кафе', 'icon': '🍽️'},
    {'value': 'pharmacy', 'label': 'Аптека', 'icon': '💊'},
    {'value': 'shopping', 'label': 'Магазин', 'icon': '🛍️'},
    {'value': 'gas_station', 'label': 'Заправка', 'icon': '⛽'},
    {'value': 'bank', 'label': 'Банк', 'icon': '🏦'},
    {'value': 'hospital', 'label': 'Больница', 'icon': '🏥'},
    {'value': 'hotel', 'label': 'Отель', 'icon': '🏨'},
    {'value': 'entertainment', 'label': 'Развлечения', 'icon': '🎭'},
    {'value': 'gym', 'label': 'Спортзал', 'icon': '💪'},
    {'value': 'beauty', 'label': 'Красота', 'icon': '💅'},
    {'value': 'education', 'label': 'Образование', 'icon': '📚'},
    {'value': 'other', 'label': 'Другое', 'icon': '📍'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация организации'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Отправить'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Основная информация
              _buildSectionTitle('Основная информация'),
              const SizedBox(height: 12),
              
              // Название организации
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название организации *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название организации';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Категория
              _buildSectionTitle('Категория'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['value']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category['icon']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            category['label']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Контактная информация
              _buildSectionTitle('Контактная информация'),
              const SizedBox(height: 12),
              
              // Адрес
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Адрес *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите адрес';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Телефон
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                  prefixText: '+7 ',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Веб-сайт
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Веб-сайт',
                  border: OutlineInputBorder(),
                  prefixText: 'https://',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              
              // Расписание работы
              _buildSectionTitle('Расписание работы'),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _openingHoursController,
                decoration: const InputDecoration(
                  labelText: 'Часы работы',
                  border: OutlineInputBorder(),
                  hintText: 'Пн-Пт: 9:00-18:00, Сб-Вс: 10:00-16:00',
                ),
              ),
              const SizedBox(height: 24),
              
              // Описание
              _buildSectionTitle('Описание'),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Описание организации',
                  border: OutlineInputBorder(),
                  hintText: 'Расскажите о вашей организации...',
                ),
              ),
              const SizedBox(height: 24),
              
              // Местоположение на карте
              _buildSectionTitle('Местоположение на карте'),
              const SizedBox(height: 12),
              
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(43.238949, 76.889709),
                      zoom: 15,
                    ),
                    onTap: (location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    markers: _selectedLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected_location'),
                              position: _selectedLocation!,
                              infoWindow: const InfoWindow(
                                title: 'Выбранное местоположение',
                              ),
                            ),
                          }
                        : {},
                    onMapCreated: (controller) {
                      // Карта создана
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Нажмите на карту, чтобы выбрать местоположение организации',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              
              // Кнопка отправки
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Отправка...'),
                          ],
                        )
                      : const Text(
                          'Отправить заявку',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Информация о модерации
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Информация о модерации',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ваша заявка будет рассмотрена модераторами в течение 1-3 рабочих дней. После одобрения организация появится на карте.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите местоположение на карте')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Имитация отправки заявки
      await Future.delayed(const Duration(seconds: 2));
      
      // Создаем POI объект
      final poi = POI(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        address: _addressController.text,
        position: _selectedLocation!,
        type: _selectedCategory,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        openingHours: _openingHoursController.text.isNotEmpty ? _openingHoursController.text : null,
        isBusinessListing: true,
      );
      
      // TODO: Отправить заявку на сервер
      
      // Показываем сообщение об успехе
      _showSuccessDialog();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке заявки: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заявка отправлена'),
        content: const Text(
          'Ваша заявка на регистрацию организации отправлена на модерацию. '
          'Мы свяжемся с вами в течение 1-3 рабочих дней.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
              Navigator.pop(context); // Вернуться на предыдущий экран
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

