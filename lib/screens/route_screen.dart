import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../widgets/address_search_widget.dart';
import '../widgets/transport_selection_widget.dart';
import '../widgets/route_details_widget.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  @override
  void initState() {
    super.initState();
    // Получаем текущее местоположение
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    // Имитация получения текущего местоположения
    // В реальном приложении здесь будет вызов геолокации
    const double lat = 43.222;
    const double lng = 76.8512;
    
    Provider.of<RouteProvider>(context, listen: false).setCurrentLocation(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршруты'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Моё местоположение',
          ),
        ],
      ),
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          return Column(
            children: [
              // Поиск адресов
              const AddressSearchWidget(),
              
              // Кнопка построения маршрутов
              if (routeProvider.destinationName.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: routeProvider.isBuildingRoute
                          ? null
                          : () {
                              routeProvider.buildAllRoutes(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C79FE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: routeProvider.isBuildingRoute
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Построение маршрутов...'),
                              ],
                            )
                          : const Text(
                              'Построить маршруты',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Выбор транспорта
              if (routeProvider.routes.isNotEmpty) ...[
                const TransportSelectionWidget(),
                const SizedBox(height: 16),
              ],
              
              // Детали маршрутов
              if (routeProvider.routes.isNotEmpty) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: const RouteDetailsWidget(),
                  ),
                ),
              ] else if (routeProvider.destinationName.isNotEmpty && !routeProvider.isBuildingRoute) ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нажмите "Построить маршруты"',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'чтобы увидеть варианты маршрутов',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Введите адрес или название места',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'чтобы построить маршрут',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (routeProvider.currentLat != null && routeProvider.destinationLat != null) {
                routeProvider.buildAllRoutes(context); // Строим все маршруты
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Выберите начальную и конечную точки')),
                );
              }
            },
            label: const Text('Построить маршрут'),
            icon: const Icon(Icons.alt_route),
            backgroundColor: Colors.blue,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
