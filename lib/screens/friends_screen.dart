import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _friends = [
    {
      'name': 'Анна Петрова',
      'status': 'В сети',
      'avatar': 'АП',
      'lastSeen': '2 минуты назад',
      'isOnline': true,
    },
    {
      'name': 'Михаил Иванов',
      'status': 'В пути',
      'avatar': 'МИ',
      'lastSeen': '5 минут назад',
      'isOnline': true,
    },
    {
      'name': 'Елена Сидорова',
      'status': 'Не в сети',
      'avatar': 'ЕС',
      'lastSeen': '1 час назад',
      'isOnline': false,
    },
    {
      'name': 'Дмитрий Козлов',
      'status': 'В офисе',
      'avatar': 'ДК',
      'lastSeen': '10 минут назад',
      'isOnline': true,
    },
  ];
  
  List<Map<String, dynamic>> _filteredFriends = [];
  
  @override
  void initState() {
    super.initState();
    _filteredFriends = _friends;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Друзья'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Поиск
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск друзей...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterFriends,
            ),
          ),
          
          // Список друзей
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriends[index];
                return _buildFriendItem(friend);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFriendItem(Map<String, dynamic> friend) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  friend['avatar'],
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (friend['isOnline'])
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            friend['name'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(friend['status']),
              Text(
                friend['lastSeen'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Отправить сообщение'),
                onTap: () {
                  // TODO: Открыть чат
                },
              ),
              PopupMenuItem(
                child: const Text('Показать на карте'),
                onTap: () {
                  // TODO: Показать местоположение друга
                },
              ),
              PopupMenuItem(
                child: const Text('Удалить из друзей'),
                onTap: () {
                  _removeFriend(friend['name']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _friends;
      } else {
        _filteredFriends = _friends
            .where((friend) =>
                friend['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
  
  void _removeFriend(String friendName) {
    setState(() {
      _friends.removeWhere((friend) => friend['name'] == friendName);
      _filteredFriends = _friends;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$friendName удален из друзей')),
    );
  }
}
