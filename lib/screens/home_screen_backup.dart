import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../providers/search_provider.dart';
import '../providers/map_layers_provider.dart';
import '../providers/route_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/map_controls_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/map_layers_widget.dart';
import '../widgets/route_widget.dart';
import 'profile_screen.dart';
import 'offline_maps_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import '../widgets/business_modal_widget.dart';
import '../providers/user_actions_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  final MapController _mapController = MapController();
  bool _isBottomSheetExpanded = false;
  
  // ПК версия переменные
  bool _isDesktop = false;
  bool _showSidePanel = true;
  bool _showSideMenu = false;
  bool _showSearchButton = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().setMapController(_mapController);
      context.read<MapLayersProvider>().initializeLayers();
      // Загружаем сессию пользователя при запуске приложения
      context.read<AuthProvider>().loadUserSession();
      context.read<UserActionsProvider>().initialize();
      
      // Проверяем, является ли устройство десктопом
      _checkIfDesktop();
    });
  }
  
  void _checkIfDesktop() {
    final mediaQuery = MediaQuery.of(context);
    setState(() {
      _isDesktop = mediaQuery.size.width > 1024; // ПК версия для экранов шире 1024px
    });
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      context.read<SearchProvider>().search(query);
      setState(() {
        _showSearchResults = true;
      });
    } else {
      setState(() {
        _showSearchResults = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: _isDesktop ? _buildDesktopLayout(themeProvider) : _buildMobileLayout(themeProvider),
        );
      },
    );
  }
  
  Widget _buildDesktopLayout(ThemeProvider themeProvider) {
    return Row(
      children: [
        // Карта (левая часть)
        Expanded(
          flex: _showSidePanel ? 2 : 1,
          child: Stack(
            children: [
              _buildMap(themeProvider),
              _buildMapControls(themeProvider),
              if (_showSearchButton) _buildTopSearchButton(themeProvider),
            ],
          ),
        ),
        
        // Боковая панель (правая часть)
        if (_showSidePanel) _buildSidePanel(themeProvider),
      ],
    );
  }
  
  Widget _buildMobileLayout(ThemeProvider themeProvider) {
    return Stack(
      children: [
        // Карта OpenStreetMap
        Consumer<MapProvider>(
          builder: (context, mapProvider, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapProvider.initialCameraPosition,
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _showSearchResults = false;
                      _searchController.clear();
                    });
                  },
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.anal_gis',
                    maxZoom: 19,
                    backgroundColor: themeProvider.backgroundColor,
                  ),
                  MarkerLayer(
                    markers: mapProvider.markers,
                  ),
                  PolylineLayer(
                    polylines: mapProvider.polylines,
                  ),
                ],
              ),
            );
          },
        ),
        
        // Кнопки управления картой
        Positioned(
          top: 20,
          left: 20,
          child: const MapControlsWidget(),
        ),
        
        // Кнопки действий
        Positioned(
          top: 20,
          right: 20,
          child: Consumer<RouteProvider>(
            builder: (context, routeProvider, child) {
              return Row(
                children: [
                  // Две кнопки слева
                  Row(
                    children: [
                      _buildFloatingButton(Icons.bookmark_border, false),
                      const SizedBox(width: 12),
                      _buildFloatingButton(Icons.directions, false, onTap: () {
                        context.read<RouteProvider>().setRouteMode(true);
                      }),
                      // Кнопка поиска (показывается только в режиме маршрутизации)
                      if (routeProvider.isRouteMode) ...[
                        const SizedBox(width: 12),
                        _buildFloatingButton(Icons.search, false, onTap: () {
                          context.read<RouteProvider>().setRouteMode(false);
                        }),
                      ],
                    ],
                  ),
                  // Одна кнопка справа
                  _buildFloatingButton(Icons.my_location, true, onTap: () {
                    context.read<MapProvider>().getCurrentLocation();
                  }),
                ],
              );
            },
          ),
        ),
        
        // Bottom Sheet для поиска и маршрутизации
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isBottomSheetExpanded 
                ? MediaQuery.of(context).size.height * 0.7 
                : MediaQuery.of(context).size.height * 0.15,
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context, listen: false).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Ручка для перетаскивания
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBottomSheetExpanded = !_isBottomSheetExpanded;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeProvider>(context, listen: false).textColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Контент bottom sheet
                Expanded(
                  child: _isBottomSheetExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildExpandedContent() {
    return Consumer2<SearchProvider, RouteProvider>(
      builder: (context, searchProvider, routeProvider, child) {
        // Если режим маршрутизации включен
        if (routeProvider.isRouteMode) {
          return RouteWidget(
            onClose: () {
              context.read<RouteProvider>().setRouteMode(false);
            },
          );
        }
        
        // Обычный режим поиска
        return Column(
          children: [
            // Поисковая строка
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).textColor),
                decoration: InputDecoration(
                  hintText: 'Поиск карт',
                  hintStyle: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor),
                  prefixIcon: Icon(Icons.search, color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor),
                  suffixIcon: Icon(Icons.mic, color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            
            // Кнопки быстрого доступа
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickButton(Icons.home, 'Дом', () {
                      // TODO: Navigate to home
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickButton(Icons.work, 'Работа', () {
                      // TODO: Navigate to work
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickButton(Icons.add, 'Добавить', () {
                      // TODO: Add location
                    }),
                  ),
                ],
              ),
            ),
            
            // Категории
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Быстрые действия',
                    style: TextStyle(
                      color: Provider.of<ThemeProvider>(context, listen: false).textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final categories = [
                        {'icon': Icons.restaurant, 'title': 'Кафе'},
                        {'icon': Icons.shopping_cart, 'title': 'Магазины'},
                        {'icon': Icons.local_hospital, 'title': 'Медицина'},
                        {'icon': Icons.account_balance, 'title': 'Банки'},
                        {'icon': Icons.movie, 'title': 'Развлечение'},
                        {'icon': Icons.local_movies, 'title': 'Кино'},
                        {'icon': Icons.local_gas_station, 'title': 'АЗС'},
                        {'icon': Icons.hotel, 'title': 'Отель'},
                      ];
                      final category = categories[index];
                      return _buildCategoryButton(
                        category['icon'] as IconData,
                        category['title'] as String,
                        () {
                          // TODO: Search by category
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Результаты поиска
            if (_showSearchResults) _buildSearchResults(),
          ],
        );
      },
    );
  }
  
  Widget _buildCollapsedContent() {
    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        // Если режим маршрутизации и bottom sheet свернут - показываем компактную версию
        if (routeProvider.isRouteMode && !_isBottomSheetExpanded) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBottomSheetExpanded = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Provider.of<ThemeProvider>(context, listen: false).textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              routeProvider.fromLocation.isEmpty ? 'Откуда?' : routeProvider.fromLocation,
                              style: TextStyle(
                                color: routeProvider.fromLocation.isEmpty ? Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor : Provider.of<ThemeProvider>(context, listen: false).textColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBottomSheetExpanded = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Provider.of<ThemeProvider>(context, listen: false).textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              routeProvider.toLocation.isEmpty ? 'Куда?' : routeProvider.toLocation,
                              style: TextStyle(
                                color: routeProvider.toLocation.isEmpty ? Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor : Provider.of<ThemeProvider>(context, listen: false).textColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Обычный режим - показываем поисковую строку и кнопку меню
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBottomSheetExpanded = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Поиск карт',
                            style: TextStyle(
                              color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showBottomSheetMenu(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.menu,
                    color: Provider.of<ThemeProvider>(context, listen: false).textColor,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSearchResults() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.searchResults.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Ничего не найдено',
                style: TextStyle(
                  color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final result = searchProvider.searchResults[index];
              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Provider.of<ThemeProvider>(context, listen: false).textColor,
                ),
                title: Text(
                  result.name,
                  style: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).textColor),
                ),
                subtitle: Text(
                  result.address,
                  style: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor),
                ),
                trailing: Text(
                  result.getDistanceText(latlng.LatLng(43.2220, 76.8512)), // Алматы координаты
                  style: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor),
                ),
                onTap: () {
                  // TODO: Navigate to result
                },
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildQuickButton(IconData icon, String title, VoidCallback onTap) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: themeProvider.textColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCategoryButton(IconData icon, String title, VoidCallback onTap) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: themeProvider.textColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context, listen: false).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Ручка для перетаскивания
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context, listen: false).textColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Заголовок
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Меню',
                      style: TextStyle(
                        color: Provider.of<ThemeProvider>(context, listen: false).textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Provider.of<ThemeProvider>(context, listen: false).textColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Список пунктов меню
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuItem(Icons.download, 'Оффлайн карты', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OfflineMapsScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.business, 'Для бизнеса', () {
                    Navigator.pop(context);
                    _showBusinessModal(context);
                  }),
                  _buildMenuItem(Icons.settings, 'Настройки', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.bookmark, 'Сохраненные места', () {
                    Navigator.pop(context);
                    // TODO: Navigate to saved places
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingButton(IconData icon, bool isBlue, {VoidCallback? onTap}) {
              Consumer<MapProvider>(
                builder: (context, mapProvider, child) {
                  if (mapProvider.isLoading && !mapProvider.isMapLoaded) {
                    return Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Загрузка карты...',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          
              // Поисковая строка (внизу экрана, до самого низа)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCustomSearchBar(),
              ),
          
          
              // Кнопка слоев (слева сверху)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10, // Поднято на 50px выше
                left: 16,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.layers,
                      color: themeProvider.textColor,
                    ),
                    onPressed: () {
                      showMapLayersModal(context);
                    },
                  ),
                ),
              ),
          
              // Кнопки зума (справа, на той же высоте что и кнопка слоев)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10, // Поднято на 50px выше
                right: 16,
                child: const MapControlsWidget(),
              ),
          
              // Плавающие кнопки действий (над поисковой строкой)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                bottom: _isBottomSheetExpanded 
                    ? MediaQuery.of(context).size.height * 0.7 + 10 
                    : 135,
                left: 16,
                right: 16,
                child: Consumer<RouteProvider>(
                  builder: (context, routeProvider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Две кнопки слева
                        Row(
                          children: [
                            _buildFloatingButton(Icons.bookmark_border, false),
                            const SizedBox(width: 12),
                            _buildFloatingButton(Icons.directions, false, onTap: () {
                              context.read<RouteProvider>().setRouteMode(true);
                              if (_isDesktop) {
                                setState(() {
                                  _showSidePanel = false;
                                  _showSearchButton = true;
                                });
                              }
                            }),
                            // Кнопка поиска (показывается только в режиме маршрутизации)
                            if (routeProvider.isRouteMode) ...[
                              const SizedBox(width: 12),
                              _buildFloatingButton(Icons.search, false, onTap: () {
                                context.read<RouteProvider>().setRouteMode(false);
                                if (_isDesktop) {
                                  setState(() {
                                    _showSidePanel = true;
                                    _showSearchButton = false;
                                  });
                                }
                              }),
                            ],
                          ],
                        ),
                        // Одна кнопка справа
                        _buildFloatingButton(Icons.my_location, true, onTap: () {
                          context.read<MapProvider>().getCurrentLocation();
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFloatingButton(IconData icon, bool isBlue, {VoidCallback? onTap}) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isBlue ? const Color(0xFF0C79FE) : themeProvider.textColor,
              size: 24,
            ),
            onPressed: onTap ?? () {
              // TODO: Add button actions
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomSearchBar() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -5) {
          setState(() {
            _isBottomSheetExpanded = true;
          });
        } else if (details.primaryDelta! > 5) {
          setState(() {
            _isBottomSheetExpanded = false;
          });
        }
      },
       child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            height: _isBottomSheetExpanded 
                ? MediaQuery.of(context).size.height * 0.7 
                : MediaQuery.of(context).size.height * 0.15,
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context, listen: false).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Полоска-ручка сверху
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBottomSheetExpanded = !_isBottomSheetExpanded;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBEBFC0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Блок поиска и кнопка меню (или компактная версия маршрута)
                Consumer<RouteProvider>(
                  builder: (context, routeProvider, child) {
                    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
                    // Если режим маршрутизации и bottom sheet свернут - показываем компактную версию
                    if (routeProvider.isRouteMode && !_isBottomSheetExpanded) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Поле "Куда?"
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isBottomSheetExpanded = true;
                                  });
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          routeProvider.toLocation.isEmpty ? 'Куда?' : routeProvider.toLocation,
                                          style: TextStyle(
                                            color: routeProvider.toLocation.isEmpty ? themeProvider.textSecondaryColor : themeProvider.textColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Кнопка меню
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: themeProvider.surfaceColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.menu,
                                  color: themeProvider.textColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showBottomSheetMenu(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Если режим маршрутизации и bottom sheet развернут - скрываем поиск
                    if (routeProvider.isRouteMode) {
                      return const SizedBox.shrink();
                    }
                    
                    // Обычный режим поиска
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Блок поиска
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isBottomSheetExpanded = true;
                                });
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Provider.of<ThemeProvider>(context, listen: false).surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        style: TextStyle(
                                          color: themeProvider.textColor,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Поиск мест и адресов',
                                          hintStyle: TextStyle(
                                            color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isBottomSheetExpanded = true;
                                          });
                                        },
                                      ),
                                    ),
                                    if (_searchController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          setState(() {
                                            _showSearchResults = false;
                                          });
                                        },
                                        child: Icon(
                                          Icons.clear,
                                          color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                                          size: 20,
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.mic,
                                        color: Provider.of<ThemeProvider>(context, listen: false).textSecondaryColor,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Кнопка меню
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: themeProvider.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: themeProvider.textColor,
                                size: 20,
                              ),
                              onPressed: () {
                                _showBottomSheetMenu(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Контент при раскрытии
                if (_isBottomSheetExpanded) _buildExpandedContent(),
              ],
            ),
          ),
    );
  }
  
  Widget _buildExpandedContent() {
    return Expanded(
      child: Consumer2<SearchProvider, RouteProvider>(
        builder: (context, searchProvider, routeProvider, child) {
          // Если режим маршрутизации включен
          if (routeProvider.isRouteMode) {
            return RouteWidget(
              onMenuTap: () => _showBottomSheetMenu(context),
            );
          }
          
          // Если есть результаты поиска, показываем их вместо кнопок
          if (searchProvider.searchResults.isNotEmpty) {
            return SearchResultsWidget();
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Быстрые кнопки - Дом, Работа, Добавить
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildQuickButton(Icons.home, 'Дом'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: _buildQuickButton(Icons.work, 'Работа'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: _buildQuickButton(Icons.add, 'Добавить'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Быстрые действия
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Text(
                      'Быстрые действия',
                      style: TextStyle(
                        color: themeProvider.textSecondaryColor,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Категории - 2 в ряд
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryButton(Icons.restaurant, 'Кафе'),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCategoryButton(Icons.shopping_cart, 'Магазины'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryButton(Icons.local_hospital, 'Медицина'),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCategoryButton(Icons.account_balance, 'Банки'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryButton(Icons.celebration, 'Развлечения'),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCategoryButton(Icons.movie, 'Кино'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildCategoryButton(Icons.local_gas_station, 'АЗС'),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildCategoryButton(Icons.hotel, 'Отель'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildQuickButton(IconData icon, String label) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: themeProvider.textColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildCategoryButton(IconData icon, String label) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(themeProvider.isDarkMode 
                ? 'assets/images/fonButton.png' 
                : 'assets/images/fonButtonWhite.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: themeProvider.textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Расширение для _HomeScreenState - методы меню
extension _HomeScreenStateMenu on _HomeScreenState {
  void _showBottomSheetMenu(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Полоска-ручка
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFBEBFC0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
               // Заголовок с профилем и кнопкой закрытия
               Padding(
                 padding: const EdgeInsets.all(20),
                 child: Consumer<AuthProvider>(
                   builder: (context, authProvider, child) {
                     return Row(
                       children: [
                         GestureDetector(
                           onTap: () {
                             Navigator.pop(context);
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => const ProfileScreen(),
                               ),
                             );
                           },
                           child: Row(
                           children: [
                             Icon(
                               Icons.person,
                               color: themeProvider.textColor,
                               size: 24,
                             ),
                             const SizedBox(width: 12),
                             Text(
                               authProvider.isAuthenticated
                                   ? (authProvider.currentUser?.fullName ?? 'Профиль')
                                   : 'Профиль',
                               style: TextStyle(
                                 color: themeProvider.textColor,
                                 fontSize: 18,
                                 fontWeight: FontWeight.w500,
                               ),
                             ),
                           ],
                           ),
                         ),
                         const Spacer(),
                         IconButton(
                           icon: Icon(
                             Icons.close,
                             color: themeProvider.textColor,
                             size: 24,
                           ),
                           onPressed: () {
                             Navigator.pop(context);
                           },
                         ),
                       ],
                     );
                   },
                 ),
               ),
              
              // Список пунктов меню
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildMenuItem(Icons.download, 'Оффлайн карты', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfflineMapsScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.business, 'Для бизнеса', () {
                      Navigator.pop(context);
                      _showBusinessModal(context);
                    }),
                    _buildMenuItem(Icons.settings, 'Настройки', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.bookmark, 'Сохраненные места', () {
                      Navigator.pop(context);
                      // TODO: Navigate to saved places
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(icon, color: themeProvider.textColor, size: 24),
            title: Text(
              title,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: themeProvider.textColor,
              size: 16,
            ),
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          ),
        );
      },
    );
  }

  void _showBusinessModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BusinessModalWidget(),
    );
  }
  
  // ПК версия методы
  Widget _buildMap(ThemeProvider themeProvider) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapProvider.initialCameraPosition,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _showSearchResults = false;
                  _searchController.clear();
                });
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.anal_gis',
                maxZoom: 19,
                backgroundColor: themeProvider.backgroundColor,
              ),
              MarkerLayer(
                markers: mapProvider.markers,
              ),
              PolylineLayer(
                polylines: mapProvider.polylines,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMapControls(ThemeProvider themeProvider) {
    return Positioned(
      top: 20,
      left: 20,
      child: const MapControlsWidget(),
    );
  }
  
  Widget _buildTopSearchButton(ThemeProvider themeProvider) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.search,
            color: themeProvider.textColor,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _showSidePanel = true;
              _showSearchButton = false;
            });
          },
        ),
      ),
    );
  }
  
  Widget _buildSidePanel(ThemeProvider themeProvider) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Заголовок с кнопкой закрытия
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: themeProvider.textColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: themeProvider.textColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSideMenu = !_showSideMenu;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _showSideMenu ? 'Меню' : 'Поиск',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: themeProvider.textColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSidePanel = false;
                      _showSearchButton = true;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Контент панели
          Expanded(
            child: _showSideMenu ? _buildSideMenu(themeProvider) : _buildSearchPanel(themeProvider),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchPanel(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Поисковая строка
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: themeProvider.textColor),
              decoration: InputDecoration(
                hintText: 'Поиск карт',
                hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
                prefixIcon: Icon(Icons.search, color: themeProvider.textSecondaryColor),
                suffixIcon: Icon(Icons.mic, color: themeProvider.textSecondaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          // Кнопки быстрого доступа
          _buildQuickAccessButtons(themeProvider),
          
          // Категории
          _buildCategoryButtons(themeProvider),
          
          // Результаты поиска
          if (_showSearchResults) _buildSearchResults(themeProvider),
        ],
      ),
    );
  }
  
  Widget _buildQuickAccessButtons(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickButton(
              Icons.home,
              'Дом',
              () {
                // TODO: Navigate to home
              },
              themeProvider,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickButton(
              Icons.work,
              'Работа',
              () {
                // TODO: Navigate to work
              },
              themeProvider,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickButton(
              Icons.add,
              'Добавить',
              () {
                // TODO: Add location
              },
              themeProvider,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryButtons(ThemeProvider themeProvider) {
    final categories = [
      {'icon': Icons.restaurant, 'title': 'Кафе'},
      {'icon': Icons.shopping_cart, 'title': 'Магазины'},
      {'icon': Icons.local_hospital, 'title': 'Медицина'},
      {'icon': Icons.account_balance, 'title': 'Банки'},
      {'icon': Icons.movie, 'title': 'Развлечение'},
      {'icon': Icons.local_movies, 'title': 'Кино'},
      {'icon': Icons.local_gas_station, 'title': 'АЗС'},
      {'icon': Icons.hotel, 'title': 'Отель'},
    ];
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрые действия',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryButton(
                category['icon'] as IconData,
                category['title'] as String,
                () {
                  // TODO: Search by category
                },
                themeProvider,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults(ThemeProvider themeProvider) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        if (searchProvider.searchResults.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Ничего не найдено',
                style: TextStyle(
                  color: themeProvider.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final result = searchProvider.searchResults[index];
              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: themeProvider.textColor,
                ),
                title: Text(
                  result.name,
                  style: TextStyle(color: themeProvider.textColor),
                ),
                subtitle: Text(
                  result.address,
                  style: TextStyle(color: themeProvider.textSecondaryColor),
                ),
                trailing: Text(
                  result.getDistanceText(latlng.LatLng(43.2220, 76.8512)), // Алматы координаты
                  style: TextStyle(color: themeProvider.textSecondaryColor),
                ),
                onTap: () {
                  // TODO: Navigate to result
                },
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildSideMenu(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Профиль пользователя
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0C79FE),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.isAuthenticated 
                                ? '${authProvider.currentUser?.firstName ?? 'Пользователь'} ${authProvider.currentUser?.lastName ?? ''}'
                                : 'Профиль',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authProvider.isAuthenticated 
                                ? authProvider.currentUser?.email ?? ''
                                : 'Войдите в аккаунт',
                            style: TextStyle(
                              color: themeProvider.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Меню
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuItem(Icons.download, 'Оффлайн карты', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OfflineMapsScreen()),
                  );
                }),
                _buildMenuItem(Icons.business, 'Для бизнеса', () {
                  _showBusinessModal(context);
                }),
                _buildMenuItem(Icons.settings, 'Настройки', () {
                  if (_isDesktop) {
                    setState(() {
                      _showSidePanel = false;
                      _showSearchButton = true;
                    });
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }),
                _buildMenuItem(Icons.bookmark, 'Сохраненные места', () {
                  // TODO: Navigate to saved places
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickButton(IconData icon, String title, VoidCallback onTap, ThemeProvider themeProvider) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: themeProvider.textColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCategoryButton(IconData icon, String title, VoidCallback onTap, ThemeProvider themeProvider) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: themeProvider.textColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

