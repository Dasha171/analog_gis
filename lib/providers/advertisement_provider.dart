import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/advertisement_model.dart';
import '../models/city_model.dart';
import '../models/manager_permissions_model.dart';
import '../services/unified_database_service.dart';

class AdvertisementProvider extends ChangeNotifier {
  final UnifiedDatabaseService _databaseService = UnifiedDatabaseService();
  List<Advertisement> _advertisements = [];
  List<City> _cities = [];
  List<ManagerPermissions> _managerPermissions = [];
  bool _isLoading = false;

  // Getters
  List<Advertisement> get advertisements => _advertisements;
  List<City> get cities => _cities;
  List<ManagerPermissions> get managerPermissions => _managerPermissions;
  bool get isLoading => _isLoading;

  // Получение одобренных рекламных объявлений для отображения
  List<Advertisement> get approvedAdvertisements {
    return _advertisements.where((ad) => ad.status == 'approved').toList();
  }

  // Получение рекламы по городу
  List<Advertisement> getAdvertisementsByCity(String cityId) {
    return approvedAdvertisements.where((ad) => ad.cityId == cityId).toList();
  }

  // Получение разрешений менеджера
  ManagerPermissions? getManagerPermissions(String managerId) {
    try {
      return _managerPermissions.firstWhere((perm) => perm.managerId == managerId);
    } catch (e) {
      return null;
    }
  }

  // Получение городов менеджера из AdminProvider
  List<City> getManagerCitiesFromAdmin(String managerId, List<String> cityIds) {
    return _cities.where((city) => cityIds.contains(city.id)).toList();
  }

  // Инициализация
  Future<void> initialize() async {
    _setLoading(true);
    await _loadCities();
    await _loadAdvertisements();
    await _loadManagerPermissions();
    _setLoading(false);
  }

  // Загрузка городов
  Future<void> _loadCities() async {
    try {
      // Всегда создаем новый список городов Казахстана
        await _createDemoCities();
      print('Загружены города Казахстана: ${_cities.length}');
    } catch (e) {
      print('Ошибка загрузки городов: $e');
    }
  }

  // Создание демо городов
  Future<void> _createDemoCities() async {
    // Очищаем старые данные
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('advertisement_cities');
    
    _cities = [
      // Основные города Казахстана
      City(
        id: '1',
        name: 'Алматы',
        country: 'Казахстан',
        latitude: 43.2220,
        longitude: 76.8512,
      ),
      City(
        id: '2',
        name: 'Нур-Султан',
        country: 'Казахстан',
        latitude: 51.1694,
        longitude: 71.4491,
      ),
      City(
        id: '3',
        name: 'Шымкент',
        country: 'Казахстан',
        latitude: 42.3417,
        longitude: 69.5901,
      ),
      City(
        id: '4',
        name: 'Актобе',
        country: 'Казахстан',
        latitude: 50.2800,
        longitude: 57.2100,
      ),
      City(
        id: '5',
        name: 'Тараз',
        country: 'Казахстан',
        latitude: 42.9000,
        longitude: 71.3667,
      ),
      City(
        id: '6',
        name: 'Павлодар',
        country: 'Казахстан',
        latitude: 52.3000,
        longitude: 76.9500,
      ),
      City(
        id: '7',
        name: 'Семей',
        country: 'Казахстан',
        latitude: 50.4000,
        longitude: 80.2500,
      ),
      City(
        id: '8',
        name: 'Усть-Каменогорск',
        country: 'Казахстан',
        latitude: 49.9500,
        longitude: 82.6167,
      ),
      City(
        id: '9',
        name: 'Караганда',
        country: 'Казахстан',
        latitude: 49.8000,
        longitude: 73.1167,
      ),
      City(
        id: '10',
        name: 'Атырау',
        country: 'Казахстан',
        latitude: 47.1167,
        longitude: 51.8833,
      ),
      City(
        id: '11',
        name: 'Костанай',
        country: 'Казахстан',
        latitude: 53.2167,
        longitude: 63.6333,
      ),
      City(
        id: '12',
        name: 'Кызылорда',
        country: 'Казахстан',
        latitude: 44.8500,
        longitude: 65.5167,
      ),
      City(
        id: '13',
        name: 'Актау',
        country: 'Казахстан',
        latitude: 43.6500,
        longitude: 51.1667,
      ),
      City(
        id: '14',
        name: 'Туркестан',
        country: 'Казахстан',
        latitude: 43.3000,
        longitude: 68.2500,
      ),
      City(
        id: '15',
        name: 'Петропавловск',
        country: 'Казахстан',
        latitude: 54.8667,
        longitude: 69.1500,
      ),
      City(
        id: '16',
        name: 'Темиртау',
        country: 'Казахстан',
        latitude: 50.0667,
        longitude: 72.9667,
      ),
      City(
        id: '17',
        name: 'Кокшетау',
        country: 'Казахстан',
        latitude: 53.2833,
        longitude: 69.4000,
      ),
      City(
        id: '18',
        name: 'Талдыкорган',
        country: 'Казахстан',
        latitude: 45.0167,
        longitude: 78.3667,
      ),
      City(
        id: '19',
        name: 'Экибастуз',
        country: 'Казахстан',
        latitude: 51.7167,
        longitude: 75.3167,
      ),
      City(
        id: '20',
        name: 'Рудный',
        country: 'Казахстан',
        latitude: 52.9667,
        longitude: 63.1167,
      ),
      City(
        id: '21',
        name: 'Жанаозен',
        country: 'Казахстан',
        latitude: 43.3333,
        longitude: 52.8500,
      ),
      City(
        id: '22',
        name: 'Жезказган',
        country: 'Казахстан',
        latitude: 47.7833,
        longitude: 67.7167,
      ),
      City(
        id: '23',
        name: 'Байконур',
        country: 'Казахстан',
        latitude: 45.6167,
        longitude: 63.3167,
      ),
      City(
        id: '24',
        name: 'Сатпаев',
        country: 'Казахстан',
        latitude: 47.9000,
        longitude: 67.5333,
      ),
      City(
        id: '25',
        name: 'Кентау',
        country: 'Казахстан',
        latitude: 43.5167,
        longitude: 68.5167,
      ),
      City(
        id: '13',
        name: 'Уральск',
        country: 'Казахстан',
        latitude: 51.2333,
        longitude: 51.3667,
      ),
      City(
        id: '14',
        name: 'Петропавловск',
        country: 'Казахстан',
        latitude: 54.8667,
        longitude: 69.1500,
      ),
      City(
        id: '15',
        name: 'Туркестан',
        country: 'Казахстан',
        latitude: 43.3000,
        longitude: 68.2500,
      ),
      City(
        id: '16',
        name: 'Темиртау',
        country: 'Казахстан',
        latitude: 50.0500,
        longitude: 72.9667,
      ),
      City(
        id: '17',
        name: 'Экибастуз',
        country: 'Казахстан',
        latitude: 51.7167,
        longitude: 75.3167,
      ),
      City(
        id: '18',
        name: 'Жезказган',
        country: 'Казахстан',
        latitude: 47.7833,
        longitude: 67.7000,
      ),
      City(
        id: '19',
        name: 'Кокшетау',
        country: 'Казахстан',
        latitude: 53.2833,
        longitude: 69.4000,
      ),
      City(
        id: '20',
        name: 'Талдыкорган',
        country: 'Казахстан',
        latitude: 45.0167,
        longitude: 78.3667,
      ),
      City(
        id: '21',
        name: 'Актау',
        country: 'Казахстан',
        latitude: 43.6500,
        longitude: 51.1667,
      ),
      City(
        id: '22',
        name: 'Атырау',
        country: 'Казахстан',
        latitude: 47.1167,
        longitude: 51.8833,
      ),
      City(
        id: '23',
        name: 'Костанай',
        country: 'Казахстан',
        latitude: 53.2167,
        longitude: 63.6333,
      ),
      City(
        id: '24',
        name: 'Кызылорда',
        country: 'Казахстан',
        latitude: 44.8500,
        longitude: 65.5167,
      ),
      City(
        id: '25',
        name: 'Павлодар',
        country: 'Казахстан',
        latitude: 52.3000,
        longitude: 76.9500,
      ),
      City(
        id: '26',
        name: 'Семей',
        country: 'Казахстан',
        latitude: 50.4000,
        longitude: 80.2500,
      ),
      City(
        id: '27',
        name: 'Усть-Каменогорск',
        country: 'Казахстан',
        latitude: 49.9500,
        longitude: 82.6167,
      ),
      City(
        id: '28',
        name: 'Караганда',
        country: 'Казахстан',
        latitude: 49.8000,
        longitude: 73.1167,
      ),
      City(
        id: '29',
        name: 'Тараз',
        country: 'Казахстан',
        latitude: 42.9000,
        longitude: 71.3667,
      ),
      City(
        id: '30',
        name: 'Актобе',
        country: 'Казахстан',
        latitude: 50.2800,
        longitude: 57.2100,
      ),
      City(
        id: '31',
        name: 'Шымкент',
        country: 'Казахстан',
        latitude: 42.3417,
        longitude: 69.5901,
      ),
      City(
        id: '32',
        name: 'Нур-Султан',
        country: 'Казахстан',
        latitude: 51.1694,
        longitude: 71.4491,
      ),
      City(
        id: '33',
        name: 'Алматы',
        country: 'Казахстан',
        latitude: 43.2220,
        longitude: 76.8512,
      ),
      City(
        id: '34',
        name: 'Рудный',
        country: 'Казахстан',
        latitude: 52.9667,
        longitude: 63.1167,
      ),
      City(
        id: '35',
        name: 'Жанаозен',
        country: 'Казахстан',
        latitude: 43.3333,
        longitude: 52.8500,
      ),
      City(
        id: '36',
        name: 'Байконур',
        country: 'Казахстан',
        latitude: 45.6167,
        longitude: 63.3167,
      ),
      City(
        id: '37',
        name: 'Сатпаев',
        country: 'Казахстан',
        latitude: 47.9000,
        longitude: 67.5333,
      ),
      City(
        id: '38',
        name: 'Кентау',
        country: 'Казахстан',
        latitude: 43.5167,
        longitude: 68.5167,
      ),
      City(
        id: '39',
        name: 'Степногорск',
        country: 'Казахстан',
        latitude: 52.3500,
        longitude: 71.8833,
      ),
      City(
        id: '40',
        name: 'Арал',
        country: 'Казахстан',
        latitude: 46.8000,
        longitude: 61.6667,
      ),
      City(
        id: '41',
        name: 'Балхаш',
        country: 'Казахстан',
        latitude: 46.8500,
        longitude: 74.9833,
      ),
      City(
        id: '42',
        name: 'Жанатас',
        country: 'Казахстан',
        latitude: 43.5667,
        longitude: 69.7167,
      ),
      City(
        id: '43',
        name: 'Капшагай',
        country: 'Казахстан',
        latitude: 43.8833,
        longitude: 77.0833,
      ),
      City(
        id: '44',
        name: 'Кульсары',
        country: 'Казахстан',
        latitude: 46.9833,
        longitude: 54.0167,
      ),
      City(
        id: '45',
        name: 'Лисаковск',
        country: 'Казахстан',
        latitude: 52.5500,
        longitude: 62.5000,
      ),
      City(
        id: '46',
        name: 'Макинск',
        country: 'Казахстан',
        latitude: 52.6333,
        longitude: 70.4167,
      ),
      City(
        id: '47',
        name: 'Сарканд',
        country: 'Казахстан',
        latitude: 45.4167,
        longitude: 79.9167,
      ),
      City(
        id: '48',
        name: 'Текели',
        country: 'Казахстан',
        latitude: 44.8333,
        longitude: 78.8333,
      ),
      City(
        id: '49',
        name: 'Шардара',
        country: 'Казахстан',
        latitude: 41.2500,
        longitude: 67.9667,
      ),
      City(
        id: '50',
        name: 'Шахтинск',
        country: 'Казахстан',
        latitude: 49.7167,
        longitude: 72.5833,
      ),
      City(
        id: '24',
        name: 'Актау',
        country: 'Казахстан',
        latitude: 43.6500,
        longitude: 51.1667,
      ),
      City(
        id: '25',
        name: 'Атырау',
        country: 'Казахстан',
        latitude: 47.1167,
        longitude: 51.8833,
      ),
      City(
        id: '26',
        name: 'Костанай',
        country: 'Казахстан',
        latitude: 53.2167,
        longitude: 63.6333,
      ),
      City(
        id: '27',
        name: 'Кызылорда',
        country: 'Казахстан',
        latitude: 44.8500,
        longitude: 65.5167,
      ),
      City(
        id: '28',
        name: 'Уральск',
        country: 'Казахстан',
        latitude: 51.2333,
        longitude: 51.3667,
      ),
      City(
        id: '29',
        name: 'Петропавловск',
        country: 'Казахстан',
        latitude: 54.8667,
        longitude: 69.1500,
      ),
      City(
        id: '30',
        name: 'Туркестан',
        country: 'Казахстан',
        latitude: 43.3000,
        longitude: 68.2500,
      ),
      City(
        id: '31',
        name: 'Темиртау',
        country: 'Казахстан',
        latitude: 50.0500,
        longitude: 72.9667,
      ),
      City(
        id: '32',
        name: 'Экибастуз',
        country: 'Казахстан',
        latitude: 51.6667,
        longitude: 75.3667,
      ),
      City(
        id: '33',
        name: 'Жезказган',
        country: 'Казахстан',
        latitude: 47.7833,
        longitude: 67.7167,
      ),
      City(
        id: '34',
        name: 'Балхаш',
        country: 'Казахстан',
        latitude: 46.8500,
        longitude: 74.9833,
      ),
      City(
        id: '35',
        name: 'Рудный',
        country: 'Казахстан',
        latitude: 52.9667,
        longitude: 63.1167,
      ),
      City(
        id: '36',
        name: 'Кентау',
        country: 'Казахстан',
        latitude: 43.5167,
        longitude: 68.5167,
      ),
      City(
        id: '37',
        name: 'Сатпаев',
        country: 'Казахстан',
        latitude: 47.9000,
        longitude: 67.5333,
      ),
      City(
        id: '38',
        name: 'Арал',
        country: 'Казахстан',
        latitude: 46.8000,
        longitude: 61.6667,
      ),
      City(
        id: '39',
        name: 'Жанаозен',
        country: 'Казахстан',
        latitude: 43.3333,
        longitude: 52.8500,
      ),
      City(
        id: '40',
        name: 'Степногорск',
        country: 'Казахстан',
        latitude: 52.3500,
        longitude: 71.8833,
      ),
      // Дополнительные города Казахстана
      City(
        id: '41',
        name: 'Арал',
        country: 'Казахстан',
        latitude: 46.8000,
        longitude: 61.6667,
      ),
      City(
        id: '42',
        name: 'Балхаш',
        country: 'Казахстан',
        latitude: 46.8500,
        longitude: 74.9833,
      ),
      City(
        id: '43',
        name: 'Жанатас',
        country: 'Казахстан',
        latitude: 43.5667,
        longitude: 69.7167,
      ),
      City(
        id: '44',
        name: 'Капшагай',
        country: 'Казахстан',
        latitude: 43.8833,
        longitude: 77.0833,
      ),
      City(
        id: '45',
        name: 'Кульсары',
        country: 'Казахстан',
        latitude: 46.9833,
        longitude: 54.0167,
      ),
      City(
        id: '46',
        name: 'Лисаковск',
        country: 'Казахстан',
        latitude: 52.5500,
        longitude: 62.5000,
      ),
      City(
        id: '47',
        name: 'Макинск',
        country: 'Казахстан',
        latitude: 52.6333,
        longitude: 70.4167,
      ),
      City(
        id: '48',
        name: 'Сарканд',
        country: 'Казахстан',
        latitude: 45.4167,
        longitude: 79.9167,
      ),
      City(
        id: '49',
        name: 'Текели',
        country: 'Казахстан',
        latitude: 44.8333,
        longitude: 78.8333,
      ),
      City(
        id: '50',
        name: 'Шардара',
        country: 'Казахстан',
        latitude: 41.2500,
        longitude: 67.9667,
      ),
      City(
        id: '51',
        name: 'Шахтинск',
        country: 'Казахстан',
        latitude: 49.7167,
        longitude: 72.5833,
      ),
      City(
        id: '52',
        name: 'Жанаозен',
        country: 'Казахстан',
        latitude: 43.3333,
        longitude: 52.8500,
      ),
      City(
        id: '53',
        name: 'Байконур',
        country: 'Казахстан',
        latitude: 45.6167,
        longitude: 63.3167,
      ),
      City(
        id: '54',
        name: 'Сатпаев',
        country: 'Казахстан',
        latitude: 47.9000,
        longitude: 67.5333,
      ),
      City(
        id: '55',
        name: 'Кентау',
        country: 'Казахстан',
        latitude: 43.5167,
        longitude: 68.5167,
      ),
      City(
        id: '56',
        name: 'Арыс',
        country: 'Казахстан',
        latitude: 42.4333,
        longitude: 68.8000,
      ),
      City(
        id: '57',
        name: 'Житикара',
        country: 'Казахстан',
        latitude: 52.1833,
        longitude: 61.2000,
      ),
      City(
        id: '58',
        name: 'Кандыагаш',
        country: 'Казахстан',
        latitude: 49.4667,
        longitude: 57.4167,
      ),
      City(
        id: '59',
        name: 'Каратау',
        country: 'Казахстан',
        latitude: 43.1833,
        longitude: 70.4667,
      ),
      City(
        id: '60',
        name: 'Ленгер',
        country: 'Казахстан',
        latitude: 42.1833,
        longitude: 69.8833,
      ),
      City(
        id: '61',
        name: 'Махамбет',
        country: 'Казахстан',
        latitude: 47.6667,
        longitude: 51.5833,
      ),
      City(
        id: '62',
        name: 'Ордабасы',
        country: 'Казахстан',
        latitude: 42.9000,
        longitude: 68.1833,
      ),
      City(
        id: '63',
        name: 'Сатпаев',
        country: 'Казахстан',
        latitude: 47.9000,
        longitude: 67.5333,
      ),
      City(
        id: '64',
        name: 'Темир',
        country: 'Казахстан',
        latitude: 47.2500,
        longitude: 57.2000,
      ),
      City(
        id: '65',
        name: 'Форт-Шевченко',
        country: 'Казахстан',
        latitude: 44.5167,
        longitude: 50.2667,
      ),
      City(
        id: '66',
        name: 'Хромтау',
        country: 'Казахстан',
        latitude: 50.2500,
        longitude: 58.4333,
      ),
      City(
        id: '67',
        name: 'Шалкар',
        country: 'Казахстан',
        latitude: 47.8333,
        longitude: 59.6000,
      ),
      City(
        id: '68',
        name: 'Шу',
        country: 'Казахстан',
        latitude: 43.6000,
        longitude: 73.7500,
      ),
      City(
        id: '69',
        name: 'Щучинск',
        country: 'Казахстан',
        latitude: 52.9333,
        longitude: 70.2000,
      ),
      City(
        id: '70',
        name: 'Эмба',
        country: 'Казахстан',
        latitude: 48.8167,
        longitude: 58.1500,
      ),
      // Дополнительные города Казахстана
      City(
        id: '71',
        name: 'Аксай',
        country: 'Казахстан',
        latitude: 51.1667,
        longitude: 53.3833,
      ),
      City(
        id: '72',
        name: 'Алга',
        country: 'Казахстан',
        latitude: 49.9000,
        longitude: 57.3333,
      ),
      City(
        id: '73',
        name: 'Арыс',
        country: 'Казахстан',
        latitude: 42.4333,
        longitude: 68.8000,
      ),
      City(
        id: '74',
        name: 'Атбасар',
        country: 'Казахстан',
        latitude: 51.8167,
        longitude: 68.3667,
      ),
      City(
        id: '75',
        name: 'Аягоз',
        country: 'Казахстан',
        latitude: 47.9667,
        longitude: 80.4333,
      ),
      City(
        id: '76',
        name: 'Булаево',
        country: 'Казахстан',
        latitude: 54.9000,
        longitude: 70.4500,
      ),
      City(
        id: '77',
        name: 'Державинск',
        country: 'Казахстан',
        latitude: 51.1000,
        longitude: 66.3167,
      ),
      City(
        id: '78',
        name: 'Ерейментау',
        country: 'Казахстан',
        latitude: 51.6167,
        longitude: 73.2667,
      ),
      City(
        id: '79',
        name: 'Есик',
        country: 'Казахстан',
        latitude: 43.3500,
        longitude: 77.4667,
      ),
      City(
        id: '80',
        name: 'Жанаарка',
        country: 'Казахстан',
        latitude: 48.5333,
        longitude: 70.8500,
      ),
      City(
        id: '81',
        name: 'Жанатас',
        country: 'Казахстан',
        latitude: 43.5667,
        longitude: 69.7167,
      ),
      City(
        id: '82',
        name: 'Жаркент',
        country: 'Казахстан',
        latitude: 44.1667,
        longitude: 80.0000,
      ),
      City(
        id: '83',
        name: 'Жезды',
        country: 'Казахстан',
        latitude: 48.0333,
        longitude: 70.7667,
      ),
      City(
        id: '84',
        name: 'Житикара',
        country: 'Казахстан',
        latitude: 52.1833,
        longitude: 61.2000,
      ),
      City(
        id: '85',
        name: 'Зайсан',
        country: 'Казахстан',
        latitude: 47.4667,
        longitude: 84.8667,
      ),
      City(
        id: '86',
        name: 'Зыряновск',
        country: 'Казахстан',
        latitude: 49.7333,
        longitude: 84.2667,
      ),
      City(
        id: '87',
        name: 'Иртышск',
        country: 'Казахстан',
        latitude: 53.3667,
        longitude: 75.4500,
      ),
      City(
        id: '88',
        name: 'Кандыагаш',
        country: 'Казахстан',
        latitude: 49.4667,
        longitude: 57.4167,
      ),
      City(
        id: '89',
        name: 'Каратау',
        country: 'Казахстан',
        latitude: 43.1833,
        longitude: 70.4667,
      ),
      City(
        id: '90',
        name: 'Каркаралинск',
        country: 'Казахстан',
        latitude: 49.4167,
        longitude: 75.4667,
      ),
      City(
        id: '91',
        name: 'Каскелен',
        country: 'Казахстан',
        latitude: 43.2000,
        longitude: 76.6167,
      ),
      City(
        id: '92',
        name: 'Курчатов',
        country: 'Казахстан',
        latitude: 50.7500,
        longitude: 78.5500,
      ),
      City(
        id: '93',
        name: 'Ленгер',
        country: 'Казахстан',
        latitude: 42.1833,
        longitude: 69.8833,
      ),
      City(
        id: '94',
        name: 'Махамбет',
        country: 'Казахстан',
        latitude: 47.6667,
        longitude: 51.5833,
      ),
      City(
        id: '95',
        name: 'Мерке',
        country: 'Казахстан',
        latitude: 42.8667,
        longitude: 73.1833,
      ),
      City(
        id: '96',
        name: 'Ордабасы',
        country: 'Казахстан',
        latitude: 42.9000,
        longitude: 68.1833,
      ),
      City(
        id: '97',
        name: 'Приозерск',
        country: 'Казахстан',
        latitude: 46.0333,
        longitude: 73.7000,
      ),
      City(
        id: '98',
        name: 'Серебрянск',
        country: 'Казахстан',
        latitude: 49.7000,
        longitude: 83.2667,
      ),
      City(
        id: '99',
        name: 'Степняк',
        country: 'Казахстан',
        latitude: 52.3500,
        longitude: 70.7833,
      ),
      City(
        id: '100',
        name: 'Темир',
        country: 'Казахстан',
        latitude: 47.2500,
        longitude: 57.2000,
      ),
      City(
        id: '101',
        name: 'Туркестан',
        country: 'Казахстан',
        latitude: 43.3000,
        longitude: 68.2500,
      ),
      City(
        id: '102',
        name: 'Уральск',
        country: 'Казахстан',
        latitude: 51.2333,
        longitude: 51.3667,
      ),
      City(
        id: '103',
        name: 'Форт-Шевченко',
        country: 'Казахстан',
        latitude: 44.5167,
        longitude: 50.2667,
      ),
      City(
        id: '104',
        name: 'Хромтау',
        country: 'Казахстан',
        latitude: 50.2500,
        longitude: 58.4333,
      ),
      City(
        id: '105',
        name: 'Шалкар',
        country: 'Казахстан',
        latitude: 47.8333,
        longitude: 59.6000,
      ),
      City(
        id: '106',
        name: 'Шу',
        country: 'Казахстан',
        latitude: 43.6000,
        longitude: 73.7500,
      ),
      City(
        id: '107',
        name: 'Щучинск',
        country: 'Казахстан',
        latitude: 52.9333,
        longitude: 70.2000,
      ),
      City(
        id: '108',
        name: 'Экибастуз',
        country: 'Казахстан',
        latitude: 51.7167,
        longitude: 75.3167,
      ),
      City(
        id: '109',
        name: 'Эмба',
        country: 'Казахстан',
        latitude: 48.8167,
        longitude: 58.1500,
      ),
      City(
        id: '110',
        name: 'Яныкурган',
        country: 'Казахстан',
        latitude: 43.9000,
        longitude: 67.2500,
      ),
    ];
    await _saveCities();
  }

  // Загрузка рекламных объявлений
  Future<void> _loadAdvertisements() async {
    try {
      _advertisements = await _databaseService.getAllAdvertisements();
      print('Загружены рекламные объявления: ${_advertisements.length}');
    } catch (e) {
      print('Ошибка загрузки рекламных объявлений: $e');
    }
  }

  // Загрузка разрешений менеджеров
  Future<void> _loadManagerPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = prefs.getString('manager_permissions') ?? '[]';
      final permissionsList = json.decode(permissionsJson) as List;
      _managerPermissions = permissionsList.map((json) => ManagerPermissions.fromJson(json)).toList();

      print('Загружены разрешения менеджеров: ${_managerPermissions.length}');
    } catch (e) {
      print('Ошибка загрузки разрешений менеджеров: $e');
    }
  }

  // Сохранение городов
  Future<void> _saveCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('advertisement_cities', json.encode(_cities.map((e) => e.toJson()).toList()));
      print('Города сохранены');
    } catch (e) {
      print('Ошибка сохранения городов: $e');
    }
  }

  // Сохранение рекламных объявлений
  Future<void> _saveAdvertisements() async {
    try {
      // Обновляем все объявления в UnifiedDatabaseService
      for (final ad in _advertisements) {
        await _databaseService.saveAdvertisement(ad);
      }
      print('Рекламные объявления сохранены');
    } catch (e) {
      print('Ошибка сохранения рекламных объявлений: $e');
    }
  }

  // Сохранение разрешений менеджеров
  Future<void> _saveManagerPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('manager_permissions', json.encode(_managerPermissions.map((e) => e.toJson()).toList()));
      print('Разрешения менеджеров сохранены');
    } catch (e) {
      print('Ошибка сохранения разрешений менеджеров: $e');
    }
  }

  // Добавление рекламного объявления
  Future<bool> addAdvertisement({
    required String title,
    required String description,
    required String imageUrl,
    required String linkUrl,
    required String cityId,
    required String managerId,
    required String managerName,
  }) async {
    try {
      final city = _cities.firstWhere((c) => c.id == cityId);
      
      final advertisement = Advertisement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        imageUrl: imageUrl,
        linkUrl: linkUrl,
        cityId: cityId,
        cityName: city.name,
        managerId: managerId,
        managerName: managerName,
        organizationId: '', // Пока пустое
        organizationName: '', // Пока пустое
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: managerId,
        status: 'pending',
      );

      _advertisements.add(advertisement);
      await _databaseService.saveAdvertisement(advertisement);
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка добавления рекламного объявления: $e');
      return false;
    }
  }

  // Одобрение рекламного объявления
  Future<void> approveAdvertisement(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          status: 'approved',
          approvedAt: DateTime.now(),
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка одобрения рекламного объявления: $e');
    }
  }

  // Отклонение рекламного объявления
  Future<void> rejectAdvertisement(String adId, String reason) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          status: 'rejected',
          rejectionReason: reason,
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка отклонения рекламного объявления: $e');
    }
  }

  // Блокировка рекламного объявления
  Future<void> blockAdvertisement(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          status: 'blocked',
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка блокировки рекламного объявления: $e');
    }
  }

  // Удаление рекламного объявления
  Future<void> deleteAdvertisement(String adId) async {
    try {
      _advertisements.removeWhere((ad) => ad.id == adId);
      await _saveAdvertisements();
      notifyListeners();
    } catch (e) {
      print('Ошибка удаления рекламного объявления: $e');
    }
  }

  // Увеличение просмотров
  Future<void> incrementViews(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          views: (_advertisements[adIndex].views ?? 0) + 1,
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка увеличения просмотров: $e');
    }
  }

  // Увеличение кликов
  Future<void> incrementClicks(String adId) async {
    try {
      final adIndex = _advertisements.indexWhere((ad) => ad.id == adId);
      if (adIndex != -1) {
        _advertisements[adIndex] = _advertisements[adIndex].copyWith(
          clicks: (_advertisements[adIndex].clicks ?? 0) + 1,
        );
        await _saveAdvertisements();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка увеличения кликов: $e');
    }
  }

  // Установка разрешений менеджеру
  Future<void> setManagerPermissions({
    required String managerId,
    required List<String> allowedCities,
    bool canAddAds = true,
    bool canEditAds = true,
    bool canDeleteAds = false,
  }) async {
    try {
      // Удаляем существующие разрешения
      _managerPermissions.removeWhere((perm) => perm.managerId == managerId);
      
      // Добавляем новые разрешения
      final permissions = ManagerPermissions(
        managerId: managerId,
        cityIds: allowedCities ?? [],
        canManageAds: canAddAds,
        canManageOrganizations: canAddAds,
        createdAt: DateTime.now(),
        allowedCities: allowedCities,
        canAddAds: canAddAds,
      );
      
      _managerPermissions.add(permissions);
      await _saveManagerPermissions();
      notifyListeners();
    } catch (e) {
      print('Ошибка установки разрешений менеджеру: $e');
    }
  }

  // Добавление города
  Future<void> addCity({
    required String name,
    required String country,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final city = City(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        country: country,
        latitude: latitude,
        longitude: longitude,
      );
      
      _cities.add(city);
      await _saveCities();
      notifyListeners();
    } catch (e) {
      print('Ошибка добавления города: $e');
    }
  }

  // Получение статистики рекламы
  Map<String, dynamic> getAdvertisementStats() {
    final totalAds = _advertisements.length;
    final pendingAds = _advertisements.where((ad) => ad.status == 'pending').length;
    final approvedAds = _advertisements.where((ad) => ad.status == 'approved').length;
    final rejectedAds = _advertisements.where((ad) => ad.status == 'rejected').length;
    final blockedAds = _advertisements.where((ad) => ad.status == 'blocked').length;
    final totalViews = _advertisements.fold(0, (sum, ad) => sum + (ad.views ?? 0));
    final totalClicks = _advertisements.fold(0, (sum, ad) => sum + (ad.clicks ?? 0));

    return {
      'totalAds': totalAds,
      'pendingAds': pendingAds,
      'approvedAds': approvedAds,
      'rejectedAds': rejectedAds,
      'blockedAds': blockedAds,
      'totalViews': totalViews,
      'totalClicks': totalClicks,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
