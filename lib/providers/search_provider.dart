import 'package:flutter/material.dart';
import '../models/poi_model.dart';
import '../models/search_result_model.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<SearchResult> _results = [];
  List<String> _suggestions = [];
  bool _isSearching = false;
  String _selectedCategory = 'all';
  
  // Getters
  String get query => _query;
  List<SearchResult> get results => _results;
  List<String> get suggestions => _suggestions;
  bool get isSearching => _isSearching;
  String get selectedCategory => _selectedCategory;
  
  // Предопределенные категории
  final List<String> _categories = [
    'all',
    'restaurant',
    'pharmacy',
    'shopping',
    'gas_station',
    'bank',
    'hospital',
    'hotel',
    'entertainment',
  ];
  
  List<String> get categories => _categories;
  
  void setQuery(String query) {
    _query = query;
    if (query.length > 2) {
      _generateSuggestions(query);
    } else {
      _suggestions.clear();
    }
    notifyListeners();
  }
  
  void _generateSuggestions(String query) {
    // Примеры автодополнения
    final allSuggestions = [
      'Кафе и рестораны',
      'Аптеки',
      'Магазины',
      'Заправки',
      'Банки',
      'Больницы',
      'Отели',
      'Развлечения',
      'Парки',
      'Транспорт',
    ];
    
    _suggestions = allSuggestions
        .where((suggestion) => 
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _results.clear();
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    _query = query;
    notifyListeners();
    
    try {
      // Имитация поиска - в реальном приложении здесь будет API запрос
      await Future.delayed(const Duration(milliseconds: 500));
      
      _results = _generateMockResults(query);
      
    } catch (e) {
      print('Search error: $e');
      _results = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  
  List<SearchResult> _generateMockResults(String query) {
    // Моковые данные для демонстрации
    final mockResults = [
      SearchResult(
        id: '1',
        name: 'Ресторан "Тюбетейка"',
        address: 'ул. Каныша Сатпаева, 22',
        type: 'restaurant',
        rating: 4.5,
        isOpen: true,
        distance: '0.3 км',
      ),
      SearchResult(
        id: '2',
        name: 'Манеж',
        address: 'ул. Каныша Сатпаева, 30',
        type: 'gym',
        rating: 4.2,
        isOpen: true,
        distance: '0.5 км',
      ),
      SearchResult(
        id: '3',
        name: 'MegaIce',
        address: 'ул. Каныша Сатпаева, 15',
        type: 'shopping',
        rating: 4.0,
        isOpen: true,
        distance: '0.2 км',
      ),
      SearchResult(
        id: '4',
        name: 'Музей им. А. Кастеева',
        address: 'ул. Каныша Сатпаева, 22',
        type: 'museum',
        rating: 4.7,
        isOpen: true,
        distance: '0.4 км',
      ),
    ];
    
    return mockResults
        .where((result) => 
            result.name.toLowerCase().contains(query.toLowerCase()) ||
            result.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  
  void setCategory(String category) {
    _selectedCategory = category;
    if (_query.isNotEmpty) {
      search(_query);
    }
    notifyListeners();
  }
  
  void clearSearch() {
    _query = '';
    _results.clear();
    _suggestions.clear();
    notifyListeners();
  }
  
  void selectSuggestion(String suggestion) {
    _query = suggestion;
    search(suggestion);
  }
}

