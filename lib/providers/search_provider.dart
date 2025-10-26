import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../models/search_result_model.dart';
import '../models/organization_model.dart';
import '../services/database_service.dart';

class SearchProvider extends ChangeNotifier {
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';
  List<SearchResult> _selectedResults = [];
  final DatabaseService _databaseService = DatabaseService();

  // Getters
  List<SearchResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get currentQuery => _currentQuery;
  List<SearchResult> get selectedResults => _selectedResults;

  // Mock data for testing
  final List<SearchResult> _mockData = [
    SearchResult(
      id: '1',
      name: 'Starbucks',
      address: 'Каныша Сатпаева ул., 15',
      category: 'Кафе',
      position: latlng.LatLng(43.238949, 76.889709),
      rating: 4.5,
      reviewCount: 127,
      phone: '+7 (727) 123-45-67',
      description: 'Кофейня Starbucks в центре Алматы',
    ),
    SearchResult(
      id: '2',
      name: 'Starbucks',
      address: 'Тауелсиздик ул., 1',
      category: 'Кафе',
      position: latlng.LatLng(43.240000, 76.890000),
      rating: 4.3,
      reviewCount: 89,
      phone: '+7 (727) 234-56-78',
      description: 'Кофейня Starbucks на Тауелсиздик',
    ),
    SearchResult(
      id: '3',
      name: 'McDonald\'s',
      address: 'Абая ул., 150',
      category: 'Ресторан',
      position: latlng.LatLng(43.235000, 76.885000),
      rating: 4.1,
      reviewCount: 203,
      phone: '+7 (727) 345-67-89',
      description: 'Ресторан быстрого питания McDonald\'s',
    ),
    SearchResult(
      id: '4',
      name: 'KFC',
      address: 'Достык ул., 85',
      category: 'Ресторан',
      position: latlng.LatLng(43.242000, 76.892000),
      rating: 4.0,
      reviewCount: 156,
      phone: '+7 (727) 456-78-90',
      description: 'Ресторан быстрого питания KFC',
    ),
    SearchResult(
      id: '5',
      name: 'Magnum Cash & Carry',
      address: 'Розыбакиева ул., 247',
      category: 'Магазин',
      position: latlng.LatLng(43.230000, 76.880000),
      rating: 4.2,
      reviewCount: 78,
      phone: '+7 (727) 567-89-01',
      description: 'Гипермаркет Magnum Cash & Carry',
    ),
    SearchResult(
      id: '6',
      name: 'Ramstore',
      address: 'Сейфуллина ул., 597',
      category: 'Магазин',
      position: latlng.LatLng(43.245000, 76.895000),
      rating: 4.4,
      reviewCount: 134,
      phone: '+7 (727) 678-90-12',
      description: 'Торговый центр Ramstore',
    ),
    SearchResult(
      id: '7',
      name: 'Аптека Асыл',
      address: 'Абая ул., 120',
      category: 'Аптека',
      position: latlng.LatLng(43.232000, 76.882000),
      rating: 4.6,
      reviewCount: 45,
      phone: '+7 (727) 789-01-23',
      description: 'Аптека Асыл - лекарства и медицинские товары',
    ),
    SearchResult(
      id: '8',
      name: 'Денсаулык',
      address: 'Достык ул., 95',
      category: 'Аптека',
      position: latlng.LatLng(43.248000, 76.898000),
      rating: 4.3,
      reviewCount: 67,
      phone: '+7 (727) 890-12-34',
      description: 'Сеть аптек Денсаулык',
    ),
    SearchResult(
      id: '9',
      name: 'Каспи Банк',
      address: 'Абая ул., 180',
      category: 'Банк',
      position: latlng.LatLng(43.250000, 76.900000),
      rating: 3.8,
      reviewCount: 23,
      phone: '+7 (727) 901-23-45',
      description: 'Отделение Каспи Банка',
    ),
    SearchResult(
      id: '10',
      name: 'Народный Банк',
      address: 'Достык ул., 110',
      category: 'Банк',
      position: latlng.LatLng(43.252000, 76.902000),
      rating: 4.0,
      reviewCount: 34,
      phone: '+7 (727) 012-34-56',
      description: 'Отделение Народного Банка',
    ),
  ];

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _currentQuery = query;
    notifyListeners();

    try {
      // Ищем в реальных организациях из базы данных
      final organizations = await _databaseService.getAllOrganizations();
      final searchText = query.toLowerCase();
      
      final orgResults = organizations.where((org) {
        return org.name.toLowerCase().contains(searchText) ||
               org.address.toLowerCase().contains(searchText) ||
               org.category.toLowerCase().contains(searchText) ||
               org.description.toLowerCase().contains(searchText);
      }).map((org) => SearchResult(
        id: org.id,
        name: org.name,
        address: org.address,
        category: org.category,
        position: latlng.LatLng(org.latitude, org.longitude),
        rating: org.rating,
        reviewCount: org.reviewCount,
        phone: org.phone,
        description: org.description,
      )).toList();

      // Добавляем результаты из мок-данных для тестирования
      final mockResults = _mockData.where((result) {
        return result.name.toLowerCase().contains(searchText) ||
               result.address.toLowerCase().contains(searchText) ||
               result.category.toLowerCase().contains(searchText) ||
               result.description?.toLowerCase().contains(searchText) == true;
      }).toList();

      _searchResults = [...orgResults, ...mockResults];
    } catch (e) {
      print('Ошибка поиска: $e');
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  void selectResult(SearchResult result) {
    if (!_selectedResults.any((r) => r.id == result.id)) {
      _selectedResults.add(result);
      notifyListeners();
    }
  }

  void deselectResult(SearchResult result) {
    _selectedResults.removeWhere((r) => r.id == result.id);
    notifyListeners();
  }

  void clearResults() {
    _searchResults.clear();
    _selectedResults.clear();
    _currentQuery = '';
    notifyListeners();
  }

  void clearSelection() {
    _selectedResults.clear();
    notifyListeners();
  }

  // Get results by category
  List<SearchResult> getResultsByCategory(String category) {
    return _searchResults.where((result) => result.category == category).toList();
  }

  // Get nearby results
  List<SearchResult> getNearbyResults(latlng.LatLng position, {double radiusKm = 5.0}) {
    return _searchResults.where((result) {
      final distance = result.calculateDistance(position);
      return distance <= radiusKm;
    }).toList()..sort((a, b) {
      final distanceA = a.calculateDistance(position);
      final distanceB = b.calculateDistance(position);
      return distanceA.compareTo(distanceB);
    });
  }
}