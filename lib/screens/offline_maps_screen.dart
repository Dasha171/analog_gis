import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Country> _countries = [
    Country(
      name: 'Казахстан',
      flag: '🇰🇿',
      cities: [
        City(
          name: 'Алматы',
          districts: ['Алатауский район', 'Алмалинский', 'Бостандыкский', 'Жетысуский', 'Медеуский', 'Наурызбайский', 'Турксибский'],
          size: '38мб',
        ),
        City(
          name: 'Астана',
          districts: ['Алматинский', 'Есильский', 'Сарыаркинский'],
          size: '45мб',
        ),
        City(
          name: 'Шымкент',
          districts: [],
          size: '32мб',
        ),
        City(
          name: 'Павлодар',
          districts: [],
          size: '28мб',
        ),
        City(
          name: 'Актобе',
          districts: [],
          size: '25мб',
        ),
        City(
          name: 'Тараз',
          districts: [],
          size: '23мб',
        ),
        City(
          name: 'Усть-Каменогорск',
          districts: [],
          size: '21мб',
        ),
        City(
          name: 'Семей',
          districts: [],
          size: '20мб',
        ),
        City(
          name: 'Караганда',
          districts: [],
          size: '35мб',
        ),
        City(
          name: 'Костанай',
          districts: [],
          size: '18мб',
        ),
      ],
    ),
    Country(
      name: 'Россия',
      flag: '🇷🇺',
      cities: [
        City(
          name: 'Москва',
          districts: ['Центральный', 'Северный', 'Северо-Восточный', 'Восточный', 'Юго-Восточный', 'Южный', 'Юго-Западный', 'Западный', 'Северо-Западный'],
          size: '120мб',
        ),
        City(
          name: 'Санкт-Петербург',
          districts: ['Адмиралтейский', 'Василеостровский', 'Выборгский', 'Калининский', 'Кировский', 'Колпинский', 'Красногвардейский'],
          size: '95мб',
        ),
        City(
          name: 'Новосибирск',
          districts: ['Дзержинский', 'Железнодорожный', 'Заельцовский', 'Калининский', 'Кировский', 'Ленинский', 'Октябрьский'],
          size: '42мб',
        ),
        City(
          name: 'Екатеринбург',
          districts: ['Верх-Исетский', 'Железнодорожный', 'Кировский', 'Ленинский', 'Октябрьский', 'Орджоникидзевский', 'Чкаловский'],
          size: '38мб',
        ),
        City(
          name: 'Казань',
          districts: ['Авиастроительный', 'Вахитовский', 'Кировский', 'Московский', 'Ново-Савиновский', 'Приволжский', 'Советский'],
          size: '35мб',
        ),
      ],
    ),
    Country(
      name: 'Туркменистан',
      flag: '🇹🇲',
      cities: [
        City(
          name: 'Ашхабад',
          districts: ['Беркенарский', 'Багтыярлыкский', 'Абаданский', 'Арчабильский'],
          size: '25мб',
        ),
        City(
          name: 'Туркменабат',
          districts: [],
          size: '18мб',
        ),
        City(
          name: 'Туркменбаши',
          districts: [],
          size: '15мб',
        ),
        City(
          name: 'Мары',
          districts: [],
          size: '12мб',
        ),
      ],
    ),
    Country(
      name: 'Узбекистан',
      flag: '🇺🇿',
      cities: [
        City(
          name: 'Ташкент',
          districts: ['Бектемирский', 'Мирабадский', 'Мирзо-Улугбекский', 'Сергелийский', 'Учтепинский', 'Чиланзарский', 'Шайхантахурский', 'Юнусабадский'],
          size: '48мб',
        ),
        City(
          name: 'Самарканд',
          districts: [],
          size: '28мб',
        ),
        City(
          name: 'Наманган',
          districts: [],
          size: '22мб',
        ),
        City(
          name: 'Андижан',
          districts: [],
          size: '20мб',
        ),
        City(
          name: 'Бухара',
          districts: [],
          size: '18мб',
        ),
      ],
    ),
    Country(
      name: 'Кыргызстан',
      flag: '🇰🇬',
      cities: [
        City(
          name: 'Бишкек',
          districts: ['Ленинский', 'Октябрьский', 'Первомайский', 'Свердловский'],
          size: '30мб',
        ),
        City(
          name: 'Ош',
          districts: [],
          size: '22мб',
        ),
        City(
          name: 'Джалал-Абад',
          districts: [],
          size: '15мб',
        ),
        City(
          name: 'Токмок',
          districts: [],
          size: '12мб',
        ),
      ],
    ),
    Country(
      name: 'Таджикистан',
      flag: '🇹🇯',
      cities: [
        City(
          name: 'Душанбе',
          districts: ['Исмоили Сомони', 'Сино', 'Фирдавси', 'Шохмансур'],
          size: '25мб',
        ),
        City(
          name: 'Худжанд',
          districts: [],
          size: '18мб',
        ),
        City(
          name: 'Куляб',
          districts: [],
          size: '15мб',
        ),
        City(
          name: 'Бохтар',
          districts: [],
          size: '12мб',
        ),
      ],
    ),
  ];

  List<Country> _filteredCountries = [];
  Map<String, bool> _downloadingCities = {};

  @override
  void initState() {
    super.initState();
    _filteredCountries = _countries;
    _searchController.addListener(_filterCountries);
    _searchController.addListener(() {
      setState(() {}); // Обновляем UI для показа/скрытия кнопки очистки
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
    _searchController.removeListener(() {
      setState(() {});
    });
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _countries;
      } else {
        _filteredCountries = _countries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.cities.any((city) => 
                  city.name.toLowerCase().contains(query) ||
                  city.districts.any((district) => district.toLowerCase().contains(query)));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.textColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Оффлайн карты',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              // Поисковая строка (без кнопки меню, светлее фон)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212121), // Фиксированный цвет #212121
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: themeProvider.textSecondaryColor,
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
                            hintText: 'Поиск городов и стран',
                            hintStyle: TextStyle(
                              color: themeProvider.textSecondaryColor,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: Icon(
                            Icons.clear,
                            color: themeProvider.textSecondaryColor,
                            size: 20,
                          ),
                        )
                      else
                        Icon(
                          Icons.mic,
                          color: themeProvider.textSecondaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),

              // Информация о памяти
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Доступно памяти: 30.2 гб из 64гб',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Список стран и городов
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return _buildCountrySection(country, themeProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountrySection(Country country, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок страны
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Text(
                country.name,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                country.flag,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),

        // Список городов
        ...country.cities.map((city) => _buildCityItem(city, themeProvider)),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCityItem(City city, ThemeProvider themeProvider) {
    final isDownloading = _downloadingCities[city.name] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.textColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Информация о городе (без флага)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (city.districts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    city.districts.join(', '),
                    style: TextStyle(
                      color: themeProvider.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Кнопка скачивания
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDownloading ? Colors.grey[600] : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isDownloading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _downloadCity(city.name),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                city.size,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _downloadCity(String cityName) async {
    setState(() {
      _downloadingCities[cityName] = true;
    });

    // Имитация загрузки
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _downloadingCities[cityName] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Карта $cityName успешно загружена'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class Country {
  final String name;
  final String flag;
  final List<City> cities;

  Country({
    required this.name,
    required this.flag,
    required this.cities,
  });
}

class City {
  final String name;
  final List<String> districts;
  final String size;

  City({
    required this.name,
    required this.districts,
    required this.size,
  });
}