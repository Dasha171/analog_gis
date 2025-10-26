import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'verification_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
              icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Регистрация',
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Заголовок
                      Text(
                        'Создайте аккаунт',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Заполните форму для регистрации',
                        style: TextStyle(
                          color: themeProvider.textSecondaryColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Поле имени
                      TextFormField(
                        controller: _firstNameController,
                        style: TextStyle(color: themeProvider.textColor),
                        decoration: InputDecoration(
                          labelText: 'Имя',
                          labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                          hintText: 'Введите ваше имя',
                          hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
                          prefixIcon: Icon(Icons.person, color: themeProvider.textSecondaryColor),
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
                            return 'Введите ваше имя';
                          }
                          if (value.trim().length < 2) {
                            return 'Имя должно содержать минимум 2 символа';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Поле фамилии
                      TextFormField(
                        controller: _lastNameController,
                        style: TextStyle(color: themeProvider.textColor),
                        decoration: InputDecoration(
                          labelText: 'Фамилия',
                          labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                          hintText: 'Введите вашу фамилию',
                          hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
                          prefixIcon: Icon(Icons.person_outline, color: themeProvider.textSecondaryColor),
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
                            return 'Введите вашу фамилию';
                          }
                          if (value.trim().length < 2) {
                            return 'Фамилия должна содержать минимум 2 символа';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Поле email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: themeProvider.textColor),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                          hintText: 'Введите ваш email',
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
                            return 'Введите ваш email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Введите корректный email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Поле телефона
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: themeProvider.textColor),
                        decoration: InputDecoration(
                          labelText: 'Телефон',
                          labelStyle: TextStyle(color: themeProvider.textSecondaryColor),
                          hintText: '+7 (999) 123-45-67',
                          hintStyle: TextStyle(color: themeProvider.textSecondaryColor),
                          prefixIcon: Icon(Icons.phone, color: themeProvider.textSecondaryColor),
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
                            return 'Введите ваш телефон';
                          }
                          // Простая проверка на российский номер
                          final phoneRegex = RegExp(r'^\+?[78][\d\s\-\(\)]{10,}$');
                          if (!phoneRegex.hasMatch(value.replaceAll(' ', '').replaceAll('-', '').replaceAll('(', '').replaceAll(')', ''))) {
                            return 'Введите корректный номер телефона';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Кнопка регистрации
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                                'Зарегистрироваться',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Разделитель
                      Row(
                        children: [
                          Expanded(child: Divider(color: themeProvider.textSecondaryColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'или',
                              style: TextStyle(
                                color: themeProvider.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: themeProvider.textSecondaryColor)),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Кнопка регистрации через Google
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleRegister,
                        icon: Icon(
                          Icons.g_mobiledata,
                          color: themeProvider.textColor,
                          size: 20,
                        ),
                        label: Text(
                          'Зарегистрироваться через Google',
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: themeProvider.textSecondaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Ссылка на вход
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Уже есть аккаунт? ',
                            style: TextStyle(
                              color: themeProvider.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Войти',
                              style: TextStyle(
                                color: Color(0xFF0C79FE),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Отображение ошибок
                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithEmail(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: _emailController.text.trim(),
            isLogin: false,
          ),
        ),
      );
    } else {
      // Проверяем, является ли ошибка связанной с дублированием регистрации
      final errorMessage = authProvider.errorMessage ?? '';
      if (errorMessage.contains('уже зарегистрирован')) {
        final themeProvider = context.read<ThemeProvider>();
        _showUserExistsDialog(context, themeProvider);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context);
    } else {
      // Проверяем, является ли ошибка связанной с дублированием регистрации
      final errorMessage = authProvider.errorMessage ?? '';
      if (errorMessage.contains('уже зарегистрирован')) {
        final themeProvider = context.read<ThemeProvider>();
        _showUserExistsDialog(context, themeProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void _showUserExistsDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.cardColor,
          title: Text(
            'Пользователь уже зарегистрирован',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Пользователь с данным email уже существует в системе. Пожалуйста, войдите в свой аккаунт.',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: themeProvider.textColor.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C79FE),
                foregroundColor: Colors.white,
              ),
              child: const Text('Войти'),
            ),
          ],
        );
      },
    );
  }
}