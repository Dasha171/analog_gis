import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/map_controls_widget.dart';
import '../widgets/search_results_widget.dart';
import 'profile_screen.dart';
import 'offline_maps_screen.dart';

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
    return Scaffold(
      body: Stack(
        children: [
                  // Карта OpenStreetMap
                  Consumer<MapProvider>(
                    builder: (context, mapProvider, child) {
                      return Stack(
                        children: [
                          FlutterMap(
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
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.anal_gis',
                                maxZoom: 19,
                              ),
                              MarkerLayer(
                                markers: mapProvider.markers,
                              ),
                              PolylineLayer(
                                polylines: mapProvider.polylines,
                              ),
                            ],
                          ),
                          // Индикатор загрузки карты
                          if (mapProvider.isLoading && !mapProvider.isMapLoaded)
                            Container(
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
                            ),
                        ],
                      );
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
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.layers,
                  color: Colors.white,
                ),
                onPressed: () {
                  // TODO: Implement map style toggle for OpenStreetMap
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isBottomSheetExpanded 
                ? MediaQuery.of(context).size.height * 0.7 + 10 
                : 135,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Две кнопки слева
                Row(
                  children: [
                    _buildFloatingButton(Icons.bookmark_border, false),
                    const SizedBox(width: 12),
                    _buildFloatingButton(Icons.directions, false),
                  ],
                ),
                // Одна кнопка справа
                _buildFloatingButton(Icons.my_location, true, onTap: () {
                  context.read<MapProvider>().getCurrentLocation();
                }),
              ],
            ),
          ),
          
          // Результаты поиска
          if (_showSearchResults)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              right: 16,
              bottom: 180, // Увеличен отступ снизу
              child: const SearchResultsWidget(),
            ),
          
        ],
      ),
    );
  }
  
  Widget _buildFloatingButton(IconData icon, bool isBlue, {VoidCallback? onTap}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isBlue ? const Color(0xFF0C79FE) : Colors.white,
          size: 24,
        ),
        onPressed: onTap ?? () {
          // TODO: Add button actions
        },
      ),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isBottomSheetExpanded 
            ? MediaQuery.of(context).size.height * 0.7 
            : MediaQuery.of(context).size.height * 0.15,
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              
              // Блок поиска и кнопка меню
              Padding(
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF151515),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: const Color(0xFF6C6C6C),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search Maps',
                                  style: TextStyle(
                                    color: const Color(0xFF6C6C6C),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.mic,
                                color: const Color(0xFF6C6C6C),
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
                        color: const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          _showBottomSheetMenu(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Контент при раскрытии
              if (_isBottomSheetExpanded) _buildExpandedContent(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildExpandedContent() {
    return Padding(
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
          const Text(
            'Быстрые действия',
            style: TextStyle(
              color: Color(0xFFC4C4C4),
              fontSize: 12,
            ),
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
    );
  }
  
  Widget _buildQuickButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assets/images/fonButton.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Расширение для _HomeScreenState - методы меню
extension _HomeScreenStateMenu on _HomeScreenState {
  void _showBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFF212121),
            borderRadius: BorderRadius.only(
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
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Пушкин Пушкин',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                      // TODO: Navigate to business
                    }),
                    _buildMenuItem(Icons.settings, 'Настройки', () {
                      Navigator.pop(context);
                      // TODO: Navigate to settings
                    }),
                    _buildMenuItem(Icons.bookmark, 'Сохраненные места', () {
                      Navigator.pop(context);
                      // TODO: Navigate to saved places
                    }),
                    _buildMenuItem(Icons.info, 'О приложении', () {
                      Navigator.pop(context);
                      // TODO: Navigate to about
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),
    );
  }
}
