import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../providers/route_provider.dart';
import '../providers/map_provider.dart';
import '../providers/theme_provider.dart';

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
                _buildQuickAccessButtons(context),
                
                const SizedBox(height: 12),
                
                // Кнопки транспорта
                _buildTransportButtons(context, routeProvider),
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
                iconColor: isFromCurrentLocation ? const Color(0xFF0C79FE) : Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                text: routeProvider.fromLocation,
                textColor: Provider.of<ThemeProvider>(context, listen: false).textColor,
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
                iconColor: isToCurrentLocation ? const Color(0xFF0C79FE) : Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                text: routeProvider.toLocation.isEmpty ? 'Куда?' : routeProvider.toLocation,
                textColor: routeProvider.toLocation.isEmpty ? Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor : Provider.of<ThemeProvider>(context, listen: false).textColor,
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
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return GestureDetector(
                  onTap: () => routeProvider.swapLocations(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeProvider.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.swap_vert,
                      color: themeProvider.textColor,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 8),
            
            // Кнопка меню
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return GestureDetector(
                  onTap: onMenuTap,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeProvider.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu,
                      color: themeProvider.textColor,
                      size: 20,
                    ),
                  ),
                );
              },
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
          color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
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

  Widget _buildQuickAccessButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(context, Icons.home, 'Дом'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(context, Icons.work, 'Работа'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(context, Icons.add, 'Добавить'),
        ),
      ],
    );
  }

  Widget _buildQuickButton(BuildContext context, IconData icon, String label) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: themeProvider.textColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransportButtons(BuildContext context, RouteProvider routeProvider) {
    final transportModes = [
      TransportMode.car,
      TransportMode.bus,
      TransportMode.pedestrian,
      TransportMode.taxi,
      TransportMode.bicycle,
      TransportMode.scooter,
      TransportMode.truck,
    ];

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
                      color: isSelected ? themeProvider.surfaceColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      routeProvider.getTransportIcon(mode),
                      color: themeProvider.textColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
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
      pageBuilder: (context, animation, secondaryAnimation) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              isFrom ? 'Выберите место отправления' : 'Выберите место назначения',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: TextField(
              controller: searchController,
              style: TextStyle(color: themeProvider.textColor),
              decoration: InputDecoration(
                hintText: 'Введите адрес или название места',
                hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
                border: const OutlineInputBorder(),
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
          );
        },
      ),
    );
  }
}
