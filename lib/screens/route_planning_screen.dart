import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/map_provider.dart';
import '../providers/search_provider.dart';
import '../services/navigation_service.dart';
import '../widgets/route_options_widget.dart';

class RoutePlanningScreen extends StatefulWidget {
  final LatLng? startLocation;
  final LatLng? endLocation;
  
  const RoutePlanningScreen({
    super.key,
    this.startLocation,
    this.endLocation,
  });

  @override
  State<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  
  LatLng? _startPoint;
  LatLng? _endPoint;
  String _selectedMode = 'driving';
  bool _isCalculating = false;
  
  final List<Map<String, String>> _transportModes = [
    {'value': 'driving', 'label': 'На автомобиле', 'icon': '🚗'},
    {'value': 'walking', 'label': 'Пешком', 'icon': '🚶'},
    {'value': 'cycling', 'label': 'На велосипеде', 'icon': '🚴'},
  ];

  @override
  void initState() {
    super.initState();
    _startPoint = widget.startLocation;
    _endPoint = widget.endLocation;
    
    if (_startPoint != null) {
      _startController.text = 'Текущее местоположение';
    }
    if (_endPoint != null) {
      _endController.text = 'Выбранная точка';
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Построение маршрута'),
        actions: [
          if (_startPoint != null && _endPoint != null)
            TextButton(
              onPressed: _isCalculating ? null : _calculateRoute,
              child: _isCalculating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Построить'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Поля ввода точек маршрута
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Начальная точка
                _buildLocationField(
                  controller: _startController,
                  label: 'Откуда',
                  icon: Icons.my_location,
                  onTap: () => _selectLocation(true),
                ),
                const SizedBox(height: 8),
                // Кнопка обмена местами
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: _swapLocations,
                  ),
                ),
                const SizedBox(height: 8),
                // Конечная точка
                _buildLocationField(
                  controller: _endController,
                  label: 'Куда',
                  icon: Icons.location_on,
                  onTap: () => _selectLocation(false),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Выбор способа передвижения
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Способ передвижения',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _transportModes.map((mode) {
                    final isSelected = _selectedMode == mode['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMode = mode['value']!;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey[300]!,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                mode['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mode['label']!,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Дополнительные опции
          const RouteOptionsWidget(),
          
          const Spacer(),
          
          // Кнопка построения маршрута
          if (_startPoint != null && _endPoint != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCalculating ? null : _calculateRoute,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCalculating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Построение маршрута...'),
                          ],
                        )
                      : const Text(
                          'Построить маршрут',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.text.isEmpty ? label : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? Colors.grey[600] : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
  
  void _selectLocation(bool isStart) {
    // TODO: Открыть экран выбора места
    // Пока используем моковые координаты
    final location = const LatLng(43.238949, 76.889709);
    
    setState(() {
      if (isStart) {
        _startPoint = location;
        _startController.text = 'ул. Каныша Сатпаева, 22';
      } else {
        _endPoint = location;
        _endController.text = 'ул. Абая, 150';
      }
    });
  }
  
  void _swapLocations() {
    setState(() {
      final tempPoint = _startPoint;
      final tempController = _startController.text;
      
      _startPoint = _endPoint;
      _endPoint = tempPoint;
      _startController.text = _endController.text;
      _endController.text = tempController;
    });
  }
  
  Future<void> _calculateRoute() async {
    if (_startPoint == null || _endPoint == null) return;
    
    setState(() {
      _isCalculating = true;
    });
    
    try {
      final route = await NavigationService.getRoute(
        start: _startPoint!,
        end: _endPoint!,
        mode: _selectedMode,
      );
      
      if (route != null) {
        context.read<MapProvider>().setRoute(route);
        Navigator.pop(context);
        
        // Показываем информацию о маршруте
        _showRouteInfo(route);
      } else {
        _showError('Не удалось построить маршрут');
      }
    } catch (e) {
      _showError('Ошибка при построении маршрута: $e');
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }
  
  void _showRouteInfo(route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Маршрут построен'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Расстояние: ${route.distance.toStringAsFixed(1)} км'),
            Text('Время в пути: ${route.duration} мин'),
            Text('Способ: ${_getModeLabel(route.mode)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  String _getModeLabel(String mode) {
    switch (mode) {
      case 'driving':
        return 'На автомобиле';
      case 'walking':
        return 'Пешком';
      case 'cycling':
        return 'На велосипеде';
      default:
        return mode;
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
