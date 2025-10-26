import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/friends_provider.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, FriendsProvider>(
      builder: (context, themeProvider, friendsProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          body: Column(
            children: [
              // Кастомный AppBar без белой полосы
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  color: themeProvider.backgroundColor,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Друзья',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.person_add, color: themeProvider.textColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddFriendScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Содержимое с табами
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      // Табы с фоном #151515
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151515),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: const Color(0xFF0C79FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: themeProvider.textSecondaryColor,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'Друзья'),
                            Tab(text: 'Приглашения'),
                            Tab(text: 'Отправленные'),
                          ],
                        ),
                      ),
                      
                      // Содержимое табов
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildFriendsTab(context, themeProvider, friendsProvider),
                            _buildInvitationsTab(context, themeProvider, friendsProvider),
                            _buildSentTab(context, themeProvider, friendsProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFriendsTab(BuildContext context, ThemeProvider themeProvider, FriendsProvider friendsProvider) {
    if (friendsProvider.friends.isEmpty) {
      return _buildEmptyState(
        themeProvider,
        Icons.people_outline,
        'Пока нет друзей',
        'Добавьте друзей, чтобы видеть их местоположение на карте',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friendsProvider.friends.length,
      itemBuilder: (context, index) {
        final friend = friendsProvider.friends[index];
        return _buildFriendItem(context, themeProvider, friendsProvider, friend);
      },
    );
  }

  Widget _buildInvitationsTab(BuildContext context, ThemeProvider themeProvider, FriendsProvider friendsProvider) {
    if (friendsProvider.pendingInvitations.isEmpty) {
      return _buildEmptyState(
        themeProvider,
        Icons.mail_outline,
        'Нет входящих приглашений',
        'Здесь будут отображаться приглашения в друзья',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friendsProvider.pendingInvitations.length,
      itemBuilder: (context, index) {
        final invitation = friendsProvider.pendingInvitations[index];
        return _buildInvitationItem(context, themeProvider, friendsProvider, invitation);
      },
    );
  }

  Widget _buildSentTab(BuildContext context, ThemeProvider themeProvider, FriendsProvider friendsProvider) {
    if (friendsProvider.sentInvitations.isEmpty) {
      return _buildEmptyState(
        themeProvider,
        Icons.send_outlined,
        'Нет отправленных приглашений',
        'Здесь будут отображаться отправленные вами приглашения',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friendsProvider.sentInvitations.length,
      itemBuilder: (context, index) {
        final invitation = friendsProvider.sentInvitations[index];
        return _buildSentInvitationItem(context, themeProvider, friendsProvider, invitation);
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider, IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0C79FE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0C79FE),
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: TextStyle(
                color: themeProvider.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(BuildContext context, ThemeProvider themeProvider, FriendsProvider friendsProvider, dynamic friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Аватар
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0C79FE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: friend.profileImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      friend.profileImageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Color(0xFF0C79FE),
                          size: 24,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Color(0xFF0C79FE),
                    size: 24,
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // Информация о друге
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      friend.name,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: friend.isOnline ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  friend.email,
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend.isOnline ? 'Онлайн' : 'Был(а) в сети ${_formatDate(friend.lastSeen)}',
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Кнопки действий
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (friend.latitude != null && friend.longitude != null)
                IconButton(
                  icon: const Icon(Icons.map, color: Color(0xFF0C79FE)),
                  onPressed: () {
                    _showFriendOnMap(context, friend);
                  },
                ),
              IconButton(
                icon: Icon(Icons.delete, color: themeProvider.textSecondaryColor),
                onPressed: () {
                  friendsProvider.removeFriend(friend.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationItem(BuildContext context, ThemeProvider themeProvider, FriendsProvider friendsProvider, dynamic invitation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0C79FE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person_add,
              color: Color(0xFF0C79FE),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.name,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invitation.email,
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  friendsProvider.acceptInvitation(invitation.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  friendsProvider.rejectInvitation(invitation.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentInvitationItem(BuildContext context, ThemeProvider themeProvider, FriendsProvider friendsProvider, dynamic invitation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0C79FE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.send,
              color: Color(0xFF0C79FE),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.name,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invitation.email,
                  style: TextStyle(
                    color: themeProvider.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ожидает ответа',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFriendOnMap(BuildContext context, dynamic friend) {
    Navigator.pushNamed(
      context,
      '/map',
      arguments: {
        'showFriend': true,
        'friendId': friend.friendId,
        'friendName': friend.name,
        'latitude': friend.latitude,
        'longitude': friend.longitude,
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'только что';
    }
  }
}