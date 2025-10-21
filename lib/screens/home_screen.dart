import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import 'dart:async';
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
import '../widgets/optimized_polyline_layer.dart';
import '../providers/user_actions_provider.dart';
import '../providers/friends_provider.dart';
import '../providers/advertisement_provider.dart';
import 'admin_panel_screen.dart';
import 'manager_panel_screen.dart';

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
    context.read<FriendsProvider>().initialize();
    context.read<AdvertisementProvider>().initialize();
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
          body: Stack(
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
                        minZoom: 3.0,
                        maxZoom: 18.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _showSearchResults = false;
                            _searchController.clear();
                          });
                        },
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        cameraConstraint: CameraConstraint.contain(
                          bounds: LatLngBounds(
                            LatLng(-85.0, -180.0),
                            LatLng(85.0, 180.0),
                          ),
                        ),
                      ),
                      children: [
                        OptimizedTileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.anal_gis',
                          maxZoom: 18,
                          minZoom: 3,
                          backgroundColor: themeProvider.backgroundColor,
                        ),
                        OptimizedMarkerLayer(
                          markers: mapProvider.markers,
                        ),
                        OptimizedPolylineLayer(
                          polylines: mapProvider.polylines,
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Индикатор загрузки карты
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
                
                // Рекламные блоки
                Consumer<AdvertisementProvider>(
                  builder: (context, adProvider, child) {
                    final ads = adProvider.approvedAdvertisements;
                    if (ads.isNotEmpty) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: ads.length,
                              itemBuilder: (context, index) {
                                final ad = ads[index];
                                return Consumer<ThemeProvider>(
                                  builder: (context, themeProvider, child) {
                                    return _buildAdvertisementCard(context, themeProvider, adProvider, ad);
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
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
  
  Widget _buildAdvertisementCard(BuildContext context, ThemeProvider themeProvider, AdvertisementProvider adProvider, dynamic ad) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeProvider.textColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            adProvider.incrementClicks(ad.id);
            // Открываем ссылку
            // TODO: Реализовать открытие ссылки
          },
          child: Stack(
            children: [
              // Изображение рекламы
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(ad.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Обработка ошибки загрузки изображения
                    },
                  ),
                ),
                child: ad.imageUrl.isEmpty
                    ? Container(
                        color: themeProvider.surfaceColor,
                        child: Icon(
                          Icons.image,
                          color: themeProvider.textSecondaryColor,
                          size: 48,
                        ),
                      )
                    : null,
              ),
              
              // Градиент для лучшей читаемости текста
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Заголовок рекламы
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  ad.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Индикатор рекламы
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C79FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'РЕКЛАМА',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                    
                    // Админ панель (только для администраторов)
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.isAdmin) {
                          return _buildMenuItem(Icons.admin_panel_settings, 'Админ панель', () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                            );
                          });
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    // Панель менеджера (только для менеджеров)
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.isManager) {
                          return _buildMenuItem(Icons.manage_accounts, 'Панель менеджера', () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ManagerPanelScreen()),
                            );
                          });
                        }
                        return const SizedBox.shrink();
                      },
                    ),
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
}

