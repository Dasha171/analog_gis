import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../models/route_model.dart';

class RouteDetailsWidget extends StatelessWidget {
  const RouteDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        if (routeProvider.routes.isEmpty) {
          return const SizedBox.shrink();
        }

        final bestRoute = routeProvider.bestRoute;
        final alternativeRoutes = routeProvider.alternativeRoutes;

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Лучший маршрут
              if (bestRoute != null) ...[
                _buildBestRouteCard(context, bestRoute),
                const SizedBox(height: 12),
              ],
              
              // Альтернативные маршруты
              if (alternativeRoutes.isNotEmpty) ...[
                Text(
                  'Альтернативные маршруты',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...alternativeRoutes.map((route) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildAlternativeRouteCard(context, route),
                )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBestRouteCard(BuildContext context, RouteResult route) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Фоновое изображение (имитация fonButton.png)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100,
                  ],
                ),
              ),
            ),
            
            // Контент
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок "Лучший маршрут"
                  Text(
                    'Лучший маршрут',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Время и информация о маршруте
                  Row(
                    children: [
                      // Время
                      Text(
                        route.formattedDuration,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Точки
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          ...List.generate(3, (index) => Container(
                            width: 3,
                            height: 3,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          )),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      
                      // Время прибытия
                      Text(
                        route.getArrivalTime(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Расстояние и стоимость
                  Row(
                    children: [
                      Text(
                        route.formattedDistance,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        route.formattedCost,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  // Индикаторы пробок и аварий
                  if (route.hasTraffic || route.hasAccidents) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (route.hasTraffic) ...[
                          Container(
                            width: 20,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.directions_car,
                            color: Colors.red,
                            size: 16,
                          ),
                        ],
                        if (route.hasAccidents) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.warning,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Кнопка "В путь"
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Начать навигацию
                  print('🚗 Начинаем навигацию: ${route.transportName}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C79FE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'В путь',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeRouteCard(BuildContext context, RouteResult route) {
    return GestureDetector(
      onTap: () {
        Provider.of<RouteProvider>(context, listen: false).selectRoute(route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Иконка транспорта
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: route.routeColorValue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                route.transportIcon,
                color: route.routeColorValue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Информация о маршруте
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.transportName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        route.formattedDuration,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        route.formattedDistance,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Стоимость
            Text(
              route.formattedCost,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: route.routeColorValue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
