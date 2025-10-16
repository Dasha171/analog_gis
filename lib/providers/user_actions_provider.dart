import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserAction {
  final String id;
  final String type; // 'favorite', 'review', 'visited', 'photo'
  final String placeId;
  final String placeName;
  final String placeAddress;
  final double? rating;
  final String? reviewText;
  final String? photoUrl;
  final DateTime createdAt;

  UserAction({
    required this.id,
    required this.type,
    required this.placeId,
    required this.placeName,
    required this.placeAddress,
    this.rating,
    this.reviewText,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'placeId': placeId,
      'placeName': placeName,
      'placeAddress': placeAddress,
      'rating': rating,
      'reviewText': reviewText,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      id: json['id'],
      type: json['type'],
      placeId: json['placeId'],
      placeName: json['placeName'],
      placeAddress: json['placeAddress'],
      rating: json['rating'],
      reviewText: json['reviewText'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserActionsProvider extends ChangeNotifier {
  List<UserAction> _favorites = [];
  List<UserAction> _reviews = [];
  List<UserAction> _visitedPlaces = [];
  List<UserAction> _photos = [];
  bool _isLoading = false;

  // Getters
  List<UserAction> get favorites => _favorites;
  List<UserAction> get reviews => _reviews;
  List<UserAction> get visitedPlaces => _visitedPlaces;
  List<UserAction> get photos => _photos;
  bool get isLoading => _isLoading;

  // Инициализация
  Future<void> initialize() async {
    _setLoading(true);
    await _loadUserActions();
    _setLoading(false);
  }

  // Загрузка данных из SharedPreferences
  Future<void> _loadUserActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем избранное
      final favoritesJson = prefs.getString('user_favorites') ?? '[]';
      final favoritesList = json.decode(favoritesJson) as List;
      _favorites = favoritesList.map((json) => UserAction.fromJson(json)).toList();

      // Загружаем отзывы
      final reviewsJson = prefs.getString('user_reviews') ?? '[]';
      final reviewsList = json.decode(reviewsJson) as List;
      _reviews = reviewsList.map((json) => UserAction.fromJson(json)).toList();

      // Загружаем посещенные места
      final visitedJson = prefs.getString('user_visited') ?? '[]';
      final visitedList = json.decode(visitedJson) as List;
      _visitedPlaces = visitedList.map((json) => UserAction.fromJson(json)).toList();

      // Загружаем фото
      final photosJson = prefs.getString('user_photos') ?? '[]';
      final photosList = json.decode(photosJson) as List;
      _photos = photosList.map((json) => UserAction.fromJson(json)).toList();

      print('Загружены действия пользователя: ${_favorites.length} избранных, ${_reviews.length} отзывов, ${_visitedPlaces.length} посещенных мест, ${_photos.length} фото');
    } catch (e) {
      print('Ошибка загрузки действий пользователя: $e');
    }
  }

  // Сохранение данных в SharedPreferences
  Future<void> _saveUserActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('user_favorites', json.encode(_favorites.map((e) => e.toJson()).toList()));
      await prefs.setString('user_reviews', json.encode(_reviews.map((e) => e.toJson()).toList()));
      await prefs.setString('user_visited', json.encode(_visitedPlaces.map((e) => e.toJson()).toList()));
      await prefs.setString('user_photos', json.encode(_photos.map((e) => e.toJson()).toList()));
      
      print('Действия пользователя сохранены');
    } catch (e) {
      print('Ошибка сохранения действий пользователя: $e');
    }
  }

  // Добавление в избранное
  Future<void> addToFavorites({
    required String placeId,
    required String placeName,
    required String placeAddress,
  }) async {
    final action = UserAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'favorite',
      placeId: placeId,
      placeName: placeName,
      placeAddress: placeAddress,
      createdAt: DateTime.now(),
    );

    _favorites.insert(0, action);
    await _saveUserActions();
    notifyListeners();
  }

  // Удаление из избранного
  Future<void> removeFromFavorites(String placeId) async {
    _favorites.removeWhere((action) => action.placeId == placeId);
    await _saveUserActions();
    notifyListeners();
  }

  // Проверка, находится ли место в избранном
  bool isFavorite(String placeId) {
    return _favorites.any((action) => action.placeId == placeId);
  }

  // Добавление отзыва
  Future<void> addReview({
    required String placeId,
    required String placeName,
    required String placeAddress,
    required double rating,
    required String reviewText,
  }) async {
    final action = UserAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'review',
      placeId: placeId,
      placeName: placeName,
      placeAddress: placeAddress,
      rating: rating,
      reviewText: reviewText,
      createdAt: DateTime.now(),
    );

    _reviews.insert(0, action);
    await _saveUserActions();
    notifyListeners();
  }

  // Добавление посещенного места
  Future<void> addVisitedPlace({
    required String placeId,
    required String placeName,
    required String placeAddress,
  }) async {
    // Проверяем, не добавлено ли уже это место
    if (_visitedPlaces.any((action) => action.placeId == placeId)) {
      return;
    }

    final action = UserAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'visited',
      placeId: placeId,
      placeName: placeName,
      placeAddress: placeAddress,
      createdAt: DateTime.now(),
    );

    _visitedPlaces.insert(0, action);
    await _saveUserActions();
    notifyListeners();
  }

  // Добавление фото
  Future<void> addPhoto({
    required String placeId,
    required String placeName,
    required String placeAddress,
    required String photoUrl,
  }) async {
    final action = UserAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'photo',
      placeId: placeId,
      placeName: placeName,
      placeAddress: placeAddress,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    _photos.insert(0, action);
    await _saveUserActions();
    notifyListeners();
  }

  // Удаление действия
  Future<void> removeAction(String id, String type) async {
    switch (type) {
      case 'favorite':
        _favorites.removeWhere((action) => action.id == id);
        break;
      case 'review':
        _reviews.removeWhere((action) => action.id == id);
        break;
      case 'visited':
        _visitedPlaces.removeWhere((action) => action.id == id);
        break;
      case 'photo':
        _photos.removeWhere((action) => action.id == id);
        break;
    }
    await _saveUserActions();
    notifyListeners();
  }

  // Очистка всех данных
  Future<void> clearAllData() async {
    _favorites.clear();
    _reviews.clear();
    _visitedPlaces.clear();
    _photos.clear();
    await _saveUserActions();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
