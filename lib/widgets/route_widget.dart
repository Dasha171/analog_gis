import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../providers/route_provider.dart';
import '../providers/map_provider.dart';

// Import TransportMode enum
export '../providers/route_provider.dart' show TransportMode;

class RouteWidget extends StatelessWidget {
  final VoidCallback? onMenuTap;
  
  const RouteWidget({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Поля ввода откуда/куда
                _buildLocationInputs(context, routeProvider),
                
                const SizedBox(height: 12),
                
                // Кнопки быстрого доступа
                _buildQuickAccessButtons(),
                
                const SizedBox(height: 12),
                
                // Кнопки транспорта
                _buildTransportButtons(routeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInputs(BuildContext context, RouteProvider routeProvider) {
    // Определяем иконки и цвета в зависимости от текста
    final bool isFromCurrentLocation = routeProvider.fromLocation == 'Моё местоположение';
    final bool isToCurrentLocation = routeProvider.toLocation == 'Моё местоположение';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              // Первое поле
              _buildLocationField(
                context,
                icon: isFromCurrentLocation ? Icons.my_location : Icons.location_on,
                iconColor: isFromCurrentLocation ? const Color(0xFF0C79FE) : const Color(0xFF6C6C6C),
                text: routeProvider.fromLocation,
                textColor: Colors.white,
                onTap: () {
                  if (isFromCurrentLocation) {
                    // Get current location
                    context.read<MapProvider>().getCurrentLocation().then((_) {
                      final mapProvider = context.read<MapProvider>();
                      if (mapProvider.currentLocation != null) {
                        routeProvider.setCurrentLocationAsFrom(mapProvider.currentLocation!);
                      }
                    });
                  } else {
                    _showLocationSearch(context, routeProvider, isFrom: true);
                  }
                },
              ),
              
              const SizedBox(height: 8),
              
              // Второе поле
              _buildLocationField(
                context,
                icon: isToCurrentLocation ? Icons.my_location : Icons.location_on,
                iconColor: isToCurrentLocation ? const Color(0xFF0C79FE) : const Color(0xFF6C6C6C),
                text: routeProvider.toLocation.isEmpty ? 'Куда?' : routeProvider.toLocation,
                textColor: routeProvider.toLocation.isEmpty ? const Color(0xFF6C6C6C) : Colors.white,
                onTap: () {
                  if (isToCurrentLocation) {
                    context.read<MapProvider>().getCurrentLocation().then((_) {
                      final mapProvider = context.read<MapProvider>();
                      if (mapProvider.currentLocation != null) {
                        routeProvider.setToLocation('Моё местоположение', position: mapProvider.currentLocation);
                      }
                    });
                  } else {
                    _showLocationSearch(context, routeProvider, isFrom: false);
                  }
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Колонка с кнопками справа
        Column(
          children: [
            // Кнопка смены местоположений
            GestureDetector(
              onTap: () => routeProvider.swapLocations(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.swap_vert,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Кнопка меню
            GestureDetector(
              onTap: onMenuTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationField(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(Icons.home, 'Дом'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(Icons.work, 'Работа'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(Icons.add, 'Добавить'),
        ),
      ],
    );
  }

  Widget _buildQuickButton(IconData icon, String label) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportButtons(RouteProvider routeProvider) {
    final transportModes = [
      TransportMode.car,
      TransportMode.bus,
      TransportMode.pedestrian,
      TransportMode.taxi,
      TransportMode.bicycle,
      TransportMode.scooter,
      TransportMode.truck,
    ];

    return Row(
      children: transportModes.map((mode) {
        final isSelected = routeProvider.selectedTransport == mode;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: mode == TransportMode.truck ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => routeProvider.setTransportMode(mode),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF151515) : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  routeProvider.getTransportIcon(mode),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLocationSearch(BuildContext context, RouteProvider routeProvider, {required bool isFrom}) {
    final TextEditingController searchController = TextEditingController();
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        backgroundColor: const Color(0xFF212121),
        title: Text(
          isFrom ? 'Выберите место отправления' : 'Выберите место назначения',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Введите адрес или название места',
            hintStyle: TextStyle(color: Color(0xFF6C6C6C)),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Color(0xFF6C6C6C)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                if (isFrom) {
                  routeProvider.setFromLocation(searchController.text);
                } else {
                  routeProvider.setToLocation(searchController.text);
                }
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Выбрать',
              style: TextStyle(color: Color(0xFF0C79FE)),
            ),
          ),
        ],
      ),
    );
  }
}
