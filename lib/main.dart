import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'screens/home_screen.dart';
import 'providers/map_provider.dart';
import 'providers/search_provider.dart';
import 'providers/map_layers_provider.dart';
import 'providers/route_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/business_provider.dart';
import 'providers/user_actions_provider.dart';
import 'providers/friends_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/advertisement_provider.dart';
import 'services/unified_database_service.dart';
import 'services/cross_platform_sync_service.dart';
import 'providers/organization_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация databaseFactory для веб-версии
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  // Запускаем приложение сразу, а инициализацию делаем в фоне
  runApp(const AnalGisApp());
  
  // Инициализация в фоне (не блокирует UI)
  _initializeAppInBackground();
}

Future<void> _initializeAppInBackground() async {
  try {
    print('🚀 Фоновая инициализация приложения...');
    
    // Мигрируем данные в единую систему
    await UnifiedDatabaseService().migrateData();
    
    // Инициализируем синхронизацию между платформами
    await CrossPlatformSyncService().initialize();
    
    print('✅ Фоновая инициализация завершена');
  } catch (e) {
    print('❌ Ошибка фоновой инициализации: $e');
  }
}

class AnalGisApp extends StatelessWidget {
  const AnalGisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => MapLayersProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => UserActionsProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AdvertisementProvider()),
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
      ],
      child: Consumer2<LocalizationProvider, ThemeProvider>(
        builder: (context, localizationProvider, themeProvider, child) {
    return MaterialApp(
            title: 'Anal GIS',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: localizationProvider.locale,
            supportedLocales: const [
              Locale('ru', 'RU'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: kIsWeb 
                    ? EdgeInsets.zero 
                    : const EdgeInsets.only(top: 30.0), // Отступ сверху 30px для мобильных устройств
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0C79FE),
        secondary: const Color(0xFF0C79FE),
        surface: Colors.white,
        background: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C79FE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF151515),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF151515),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF0C79FE),
        secondary: const Color(0xFF0C79FE),
        surface: const Color(0xFF151515),
        background: const Color(0xFF151515),
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      cardTheme: CardThemeData(
        color: const Color(0xFF151515),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C79FE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
