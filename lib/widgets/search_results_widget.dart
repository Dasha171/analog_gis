import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../providers/search_provider.dart';
import '../providers/map_provider.dart';
import '../models/search_result_model.dart';

class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.isSearching) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Поиск...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (searchProvider.searchResults.isEmpty) {
          return const Center(
            child: Text(
              'Ничего не найдено',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          );
        }

        return Column(
          children: [
            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Найдено: ${searchProvider.searchResults.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      searchProvider.clearResults();
                    },
                    child: const Text(
                      'Очистить',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            // Results list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: searchProvider.searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchProvider.searchResults[index];
                  return _buildResultCard(context, result);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultCard(BuildContext context, SearchResult result) {
    final mapProvider = context.read<MapProvider>();
    final currentLocation = mapProvider.currentLocation ?? 
        const latlng.LatLng(43.238949, 76.889709); // Default Almaty

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _onResultTap(context, result);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon based on category
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(result.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(result.category),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        result.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Address
                      Text(
                        result.address,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Rating and distance
                      Row(
                        children: [
                          if (result.rating > 0) ...[
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            result.getDistanceText(currentLocation),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white30,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onResultTap(BuildContext context, SearchResult result) {
    final mapProvider = context.read<MapProvider>();
    
    // Move map to result location
    mapProvider.moveToLocation(result.position);
    
    // Add marker for selected result
    _addResultMarker(context, result);
    
    // Show bottom sheet with details
    _showResultDetails(context, result);
  }

  void _addResultMarker(BuildContext context, SearchResult result) {
    final mapProvider = context.read<MapProvider>();
    
    // Clear previous search markers (keep current location marker)
    mapProvider.clearSearchMarkers();
    
    // Add new search result marker
    mapProvider.addSearchMarker(
      Marker(
        key: ValueKey('search_${result.id}'),
        point: result.position,
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: _getCategoryColor(result.category),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            _getCategoryIcon(result.category),
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  void _showResultDetails(BuildContext context, SearchResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle strip
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Name and rating
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (result.rating > 0) ...[
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    result.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Address
            Text(
              result.address,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(result.category).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.category,
                style: TextStyle(
                  color: _getCategoryColor(result.category),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (result.description != null) ...[
              const SizedBox(height: 12),
              Text(
                result.description!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
            if (result.phone != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    result.phone!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement route building
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Маршрут'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement favorites
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('В избранное'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'кафе':
      case 'ресторан':
        return Colors.red;
      case 'магазин':
        return Colors.orange;
      case 'аптека':
        return Colors.green;
      case 'банк':
        return Colors.blue;
      case 'медицина':
        return Colors.purple;
      case 'развлечения':
        return Colors.pink;
      case 'кино':
        return Colors.indigo;
      case 'азс':
        return Colors.teal;
      case 'отель':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'кафе':
      case 'ресторан':
        return Icons.restaurant;
      case 'магазин':
        return Icons.shopping_cart;
      case 'аптека':
        return Icons.local_pharmacy;
      case 'банк':
        return Icons.account_balance;
      case 'медицина':
        return Icons.local_hospital;
      case 'развлечения':
        return Icons.celebration;
      case 'кино':
        return Icons.movie;
      case 'азс':
        return Icons.local_gas_station;
      case 'отель':
        return Icons.hotel;
      default:
        return Icons.place;
    }
  }
}