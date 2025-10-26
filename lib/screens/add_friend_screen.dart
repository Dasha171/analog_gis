import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/friends_provider.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Загружаем код приглашения для текущего пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final friendsProvider = Provider.of<FriendsProvider>(context, listen: false);
      // Получаем ID текущего пользователя (в реальном приложении из AuthProvider)
      friendsProvider.loadInvitationCode('current_user_id');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, FriendsProvider>(
      builder: (context, themeProvider, friendsProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Добавить друга',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Информация о приглашении
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C79FE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Color(0xFF0C79FE),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ваш код приглашения',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: themeProvider.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF0C79FE)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                friendsProvider.invitationCode ?? 'Загрузка...',
                                style: TextStyle(
                                  color: themeProvider.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Color(0xFF0C79FE)),
                              onPressed: () {
                                if (friendsProvider.invitationCode != null) {
                                  Clipboard.setData(ClipboardData(text: friendsProvider.invitationCode!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Код скопирован в буфер обмена'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Поделитесь этим кодом с друзьями, чтобы они могли добавить вас в друзья',
                        style: TextStyle(
                          color: themeProvider.textSecondaryColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Разделитель
                Row(
                  children: [
                    Expanded(child: Divider(color: themeProvider.textSecondaryColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ИЛИ',
                        style: TextStyle(
                          color: themeProvider.textSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: themeProvider.textSecondaryColor)),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Форма добавления друга
                Text(
                  'Добавить друга по email',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: themeProvider.textColor),
                    decoration: InputDecoration(
                      labelText: 'Email друга',
                      labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                      hintText: 'friend@example.com',
                      hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
                      prefixIcon: Icon(Icons.email, color: themeProvider.textSecondaryColor),
                      filled: true,
                      fillColor: themeProvider.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0C79FE), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите email друга';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Введите корректный email';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Кнопка отправки приглашения
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendInvitation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C79FE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Отправить приглашение',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Инструкции
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: themeProvider.textSecondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Как это работает:',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Поделитесь кодом приглашения с другом\n2. Друг вводит код в приложении\n3. Вы автоматически становитесь друзьями\n4. Теперь вы можете видеть местоположение друг друга на карте',
                        style: TextStyle(
                          color: themeProvider.textSecondaryColor,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final friendsProvider = context.read<FriendsProvider>();
    final success = await friendsProvider.sendInvitation(_emailController.text.trim());

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Приглашение отправлено!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Приглашение уже отправлено этому пользователю'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
