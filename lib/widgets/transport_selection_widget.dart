import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../models/route_model.dart';

class TransportSelectionWidget extends StatelessWidget {
  const TransportSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        if (routeProvider.routes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: TransportType.values.length,
            itemBuilder: (context, index) {
              final transportType = TransportType.values[index];
              final route = routeProvider.getRouteByTransport(transportType);
              final isSelected = routeProvider.selectedRoute?.transportType == transportType;

              return GestureDetector(
                onTap: () {
                  if (route != null) {
                    routeProvider.selectRoute(route);
                  }
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0C79FE) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0C79FE) : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getTransportIcon(transportType),
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      if (route != null) ...[
                        Text(
                          route.formattedDuration,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          '—',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getTransportIcon(TransportType transportType) {
    switch (transportType) {
      case TransportType.car:
        return Icons.directions_car;
      case TransportType.bus:
        return Icons.directions_bus;
      case TransportType.walking:
        return Icons.directions_walk;
      case TransportType.taxi:
        return Icons.local_taxi;
      case TransportType.bicycle:
        return Icons.directions_bike;
      case TransportType.scooter:
        return Icons.electric_scooter;
      case TransportType.truck:
        return Icons.local_shipping;
    }
  }
}
