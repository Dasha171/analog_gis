import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../providers/theme_provider.dart';
import '../models/route_model.dart';

class RouteWidget extends StatefulWidget {
  final VoidCallback onMenuTap;
  
  const RouteWidget({
    super.key,
    required this.onMenuTap,
  });

  @override
  State<RouteWidget> createState() => _RouteWidgetState();
}

class _RouteWidgetState extends State<RouteWidget> {
  late TextEditingController _currentLocationController;

  @override
  void initState() {
    super.initState();
    _currentLocationController = TextEditingController(text: 'Моё местоположение');
    
    // Слушаем изменения в RouteProvider для обновления контроллера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);
      _currentLocationController.text = routeProvider.currentLocationName;
    });
  }

  @override
  void dispose() {
    _currentLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
        
        // Обновляем контроллер при изменении названия текущего местоположения
        if (_currentLocationController.text != routeProvider.currentLocationName) {
          _currentLocationController.text = routeProvider.currentLocationName;
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Поля ввода - Мое местоположение и Куда
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56, // Увеличиваем высоту поля
                      padding: const EdgeInsets.symmetric(horizontal: 16), // Убираем vertical padding
                      decoration: BoxDecoration(
                        color: themeProvider.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.navigation,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _currentLocationController,
                              textAlignVertical: TextAlignVertical.center,
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 16,
                                height: 1.2,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Моё местоположение',
                                hintStyle: TextStyle(
                                  color: themeProvider.textSecondaryColor,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (value) {
                                // Обновляем начальную точку маршрута
                                routeProvider.setCurrentLocationName(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56, // Увеличиваем высоту кнопки меню
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: widget.onMenuTap,
                      icon: Icon(
                        Icons.menu,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Поле "Куда?" с кнопкой переворота
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56, // Увеличиваем высоту поля
                      padding: const EdgeInsets.symmetric(horizontal: 16), // Убираем vertical padding
                      decoration: BoxDecoration(
                        color: themeProvider.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: themeProvider.textSecondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: routeProvider.destinationController,
                              textAlignVertical: TextAlignVertical.center, // Выравниваем по центру
                              style: TextStyle(
                                color: themeProvider.textColor,
                                fontSize: 16,
                                height: 1.2, // Уменьшаем высоту строки для лучшего позиционирования
                              ),
                              decoration: InputDecoration(
                                hintText: 'Куда?',
                                hintStyle: TextStyle(
                                  color: themeProvider.textSecondaryColor,
                                  fontSize: 16,
                                  height: 1.2, // Уменьшаем высоту строки для подсказки
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16), // Добавляем вертикальные отступы
                              ),
                              onChanged: (value) {
                                routeProvider.setDestinationName(value);
                                if (value.isNotEmpty) {
                                  routeProvider.searchAddresses(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56, // Увеличиваем высоту кнопки переворота
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Переворот полей места отправления и назначения
                        routeProvider.swapLocations();
                      },
                      icon: Icon(
                        Icons.swap_vert,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Результаты поиска адресов
              if (routeProvider.searchResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    itemCount: routeProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      final result = routeProvider.searchResults[index];
                      return ListTile(
                        leading: Icon(
                          result.type == 'address' ? Icons.location_on : Icons.business,
                          color: themeProvider.textColor,
                        ),
                        title: Text(
                          result.name,
                          style: TextStyle(color: themeProvider.textColor),
                        ),
                        subtitle: Text(
                          result.description,
                          style: TextStyle(color: themeProvider.textSecondaryColor),
                        ),
                        onTap: () {
                          routeProvider.selectDestination(result);
                        },
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Быстрые кнопки - Дом, Работа, Добавить (как в поисковике)
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildQuickButtonRoute(
                      Icons.home,
                      'Дом',
                      themeProvider,
                      () {
                        routeProvider.setQuickDestination('Дом');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: _buildQuickButtonRoute(
                      Icons.work,
                      'Работа',
                      themeProvider,
                      () {
                        routeProvider.setQuickDestination('Работа');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: _buildQuickButtonRoute(
                      Icons.add,
                      'Добавить',
                      themeProvider,
                      () {
                        // Добавление нового места
                        _showAddLocationDialog(context, routeProvider, themeProvider);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Кнопки транспорта
              _buildTransportButtons(context, routeProvider, themeProvider),
              
              const SizedBox(height: 20),
              
              // История маршрутов
              if (routeProvider.routeHistory.isNotEmpty) ...[
                Text(
                  'Недавние маршруты:',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...routeProvider.routeHistory.map((route) => _buildRouteHistoryItem(context, route, themeProvider, routeProvider.destinationName)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickButtonRoute(IconData icon, String label, ThemeProvider themeProvider, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: themeProvider.textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportButtons(BuildContext context, RouteProvider routeProvider, ThemeProvider themeProvider) {
    final transportTypes = [
      {'type': TransportType.car, 'icon': Icons.directions_car, 'name': 'Машина'},
      {'type': TransportType.bus, 'icon': Icons.directions_bus, 'name': 'Автобус'},
      {'type': TransportType.walking, 'icon': Icons.directions_walk, 'name': 'Пешком'},
      {'type': TransportType.taxi, 'icon': Icons.local_taxi, 'name': 'Такси'},
      {'type': TransportType.bicycle, 'icon': Icons.directions_bike, 'name': 'Велосипед'},
      {'type': TransportType.scooter, 'icon': Icons.electric_scooter, 'name': 'Самокат'},
      {'type': TransportType.truck, 'icon': Icons.local_shipping, 'name': 'Доставка'},
    ];

    return Row(
      children: transportTypes.map((transport) {
        final isSelected = routeProvider.selectedTransportType == transport['type'];
        
        // Определяем цвет фона для нажатой кнопки
        final selectedBackgroundColor = themeProvider.isDarkMode 
            ? const Color(0xFF151515) 
            : const Color(0xFFE5E5E5);
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              routeProvider.setSelectedTransportType(transport['type'] as TransportType);
              if (routeProvider.destinationName.isNotEmpty) {
                routeProvider.buildRouteForTransport(transport['type'] as TransportType);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 1), // Минимальный отступ
              height: 48, // Фиксированная высота как у других кнопок
              decoration: BoxDecoration(
                color: isSelected ? selectedBackgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                transport['icon'] as IconData,
                color: isSelected 
                    ? (themeProvider.isDarkMode ? Colors.white : Colors.black)
                    : themeProvider.textColor,
                size: 20, // Еще меньше размер иконки
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRouteHistoryItem(BuildContext context, RouteResult route, ThemeProvider themeProvider, String destinationName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: themeProvider.textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              destinationName,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${route.distance.toStringAsFixed(1)} км',
            style: TextStyle(
              color: themeProvider.textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context, RouteProvider routeProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить место'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Название места',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              routeProvider.addToRouteHistory(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Логика добавления места
              Navigator.pop(context);
            },
            child: Text('Добавить'),
          ),
        ],
      ),
    );
  }
}
