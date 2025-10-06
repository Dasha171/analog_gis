import 'package:flutter_tts/flutter_tts.dart';
import '../providers/localization_provider.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  
  /// Инициализация TTS
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _flutterTts.setLanguage("ru-RU");
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }
  
  /// Установка языка
  static Future<void> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
    } catch (e) {
      print('Error setting TTS language: $e');
    }
  }
  
  /// Произнесение текста
  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }
  
  /// Остановка речи
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }
  
  /// Пауза речи
  static Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('Error pausing TTS: $e');
    }
  }
  
  /// Голосовые подсказки для навигации
  static Future<void> speakNavigationInstruction(String instruction) async {
    // Очищаем предыдущую речь
    await stop();
    
    // Произносим новую инструкцию
    await speak(instruction);
  }
  
  /// Предупреждение о маневре
  static Future<void> speakManeuverWarning({
    required String maneuver,
    required int distance,
  }) async {
    String instruction;
    
    switch (maneuver) {
      case 'turn-left':
        instruction = 'Через $distance метров поверните налево';
        break;
      case 'turn-right':
        instruction = 'Через $distance метров поверните направо';
        break;
      case 'turn-sharp-left':
        instruction = 'Через $distance метров резко поверните налево';
        break;
      case 'turn-sharp-right':
        instruction = 'Через $distance метров резко поверните направо';
        break;
      case 'turn-slight-left':
        instruction = 'Через $distance метров слегка поверните налево';
        break;
      case 'turn-slight-right':
        instruction = 'Через $distance метров слегка поверните направо';
        break;
      case 'straight':
        instruction = 'Продолжайте движение прямо $distance метров';
        break;
      case 'uturn':
        instruction = 'Через $distance метров развернитесь';
        break;
      case 'arrive':
        instruction = 'Вы прибыли в пункт назначения';
        break;
      case 'depart':
        instruction = 'Начните движение';
        break;
      default:
        instruction = 'Через $distance метров $maneuver';
    }
    
    await speakNavigationInstruction(instruction);
  }
  
  /// Информация о расстоянии до пункта назначения
  static Future<void> speakDistanceInfo(int distance) async {
    String instruction;
    
    if (distance < 1000) {
      instruction = 'До пункта назначения $distance метров';
    } else {
      final km = (distance / 1000).toStringAsFixed(1);
      instruction = 'До пункта назначения $km километров';
    }
    
    await speakNavigationInstruction(instruction);
  }
  
  /// Ошибка навигации
  static Future<void> speakNavigationError(String error) async {
    await speakNavigationInstruction('Ошибка навигации: $error');
  }
  
  /// Отклонение от маршрута
  static Future<void> speakRouteDeviation() async {
    await speakNavigationInstruction('Вы отклонились от маршрута. Пересчитываю маршрут...');
  }
}

