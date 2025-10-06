import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/map_provider.dart';
import '../models/search_result_model.dart';

class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Предложения автодополнения
              if (searchProvider.suggestions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Предложения',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...searchProvider.suggestions.map((suggestion) => 
                        ListTile(
                          leading: const Icon(Icons.search),
                          title: Text(suggestion),
                          onTap: () {
                            searchProvider.selectSuggestion(suggestion);
                          },
                        ),
                      ).toList(),
                    ],
                  ),
                ),
              
              // Результаты поиска
              if (searchProvider.results.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: searchProvider.results.length,
                    itemBuilder: (context, index) {
                      final result = searchProvider.results[index];
                      return SearchResultItem(
                        result: result,
                        onTap: () {
                          _onResultTap(context, result);
                        },
                      );
                    },
                  ),
                ),
              
              // Индикатор загрузки
              if (searchProvider.isSearching)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              
              // Пустое состояние
              if (searchProvider.query.isNotEmpty && 
                  searchProvider.results.isEmpty && 
                  !searchProvider.isSearching)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Ничего не найдено для "${searchProvider.query}"',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  void _onResultTap(BuildContext context, SearchResult result) {
    // TODO: Переместить карту к выбранному результату
    if (result.position != null) {
      context.read<MapProvider>().moveToLocation(result.position!);
    }
    
    // Скрыть результаты поиска
    // Это должно вызываться из родительского виджета
  }
}

class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;
  
  const SearchResultItem({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getIconForType(result.type),
      title: Text(
        result.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.address),
          if (result.distance != null)
            Text(
              result.distance!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          if (result.rating != null)
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  result.rating!.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (result.isOpen)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Открыто',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  Widget _getIconForType(String type) {
    IconData iconData;
    Color iconColor;
    
    switch (type.toLowerCase()) {
      case 'restaurant':
      case 'кафе':
        iconData = Icons.restaurant;
        iconColor = Colors.red;
        break;
      case 'pharmacy':
      case 'аптека':
        iconData = Icons.local_pharmacy;
        iconColor = Colors.green;
        break;
      case 'shopping':
      case 'магазин':
        iconData = Icons.shopping_bag;
        iconColor = Colors.orange;
        break;
      case 'gym':
      case 'спортзал':
        iconData = Icons.fitness_center;
        iconColor = Colors.blue;
        break;
      case 'museum':
      case 'музей':
        iconData = Icons.museum;
        iconColor = Colors.purple;
        break;
      case 'gas_station':
      case 'заправка':
        iconData = Icons.local_gas_station;
        iconColor = Colors.yellow[700]!;
        break;
      case 'bank':
      case 'банк':
        iconData = Icons.account_balance;
        iconColor = Colors.indigo;
        break;
      case 'hospital':
      case 'больница':
        iconData = Icons.local_hospital;
        iconColor = Colors.red[700]!;
        break;
      case 'hotel':
      case 'отель':
        iconData = Icons.hotel;
        iconColor = Colors.brown;
        break;
      default:
        iconData = Icons.place;
        iconColor = Colors.grey;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}

