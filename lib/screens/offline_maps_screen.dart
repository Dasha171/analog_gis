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
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF151515) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF151515) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Оффлайн карты',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Поисковая строка
          Container(
            margin: const EdgeInsets.all(16),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151515) : Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    child: Icon(
                      Icons.search,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Введите город',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        size: 22,
                      ),
                      onPressed: () {
                        // TODO: Implement voice search
                      },
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.person,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Navigate to profile
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Информация о памяти
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Доступно памяти: 30.2 гб из 64гб',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
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
                return _buildCountrySection(country, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountrySection(Country country, bool isDark) {
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
                  color: isDark ? Colors.white : Colors.black87,
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
        ...country.cities.map((city) => _buildCityItem(city, isDark)),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCityItem(City city, bool isDark) {
    final isDownloading = _downloadingCities[city.name] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // Флаг страны
          Text(
            '🇰🇿', // Можно сделать динамическим
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(width: 12),
          
          // Информация о городе
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (city.districts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    city.districts.join(', '),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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