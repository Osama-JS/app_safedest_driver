import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    // Prevent multiple login attempts
    if (authService.isLoading) return;

    try {
      final response = await authService.login(
        login: _loginController.text.trim(),
        password: _passwordController.text,
        deviceName: 'Flutter App',
      );

      if (mounted) {
        if (response.isSuccess) {
          // Login successful, navigate to main screen
          Navigator.of(context).pushReplacementNamed('/main');
        } else {
          // Add small delay to avoid Navigator conflicts
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            _showErrorDialog(response.errorMessage);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        // Add small delay to avoid Navigator conflicts
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _showErrorDialog('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في تسجيل الدخول'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo and Title
                _buildHeader(),

                const SizedBox(height: 60),

                // Login Form
                _buildLoginForm(),

                const SizedBox(height: 30),

                // Login Button
                _buildLoginButton(),

                const SizedBox(height: 20),

                // Remember Me
                _buildRememberMe(),

                const SizedBox(height: 40),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(
            'assets/icons/Icon.png',
            width: 60,
            height: 60,
            // اختياري إذا تبغى تغيّر لون الصورة (يعمل فقط مع الصور بصيغة PNG شفافة أو SVG)
          ),
        ),

        const SizedBox(height: 20),

        // App Name
        Text(
          AppConfig.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'مرحباً بك في تطبيق السائقين',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Login Field (Email or Username)
        CustomTextField(
          controller: _loginController,
          label: 'البريد الإلكتروني أو اسم المستخدم',
          hint: 'أدخل بريدك الإلكتروني أو اسم المستخدم',
          keyboardType: TextInputType.text,
          prefixIcon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }

            return null;
          },
        ),

        const SizedBox(height: 20),

        // Password Field
        CustomTextField(
          controller: _passwordController,
          label: 'كلمة المرور',
          hint: 'أدخل كلمة المرور',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
            }
            if (value.length < 6) {
              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return CustomButton(
          text: 'تسجيل الدخول',
          onPressed: authService.isLoading ? null : _handleLogin,
          isLoading: authService.isLoading,
          icon: Icons.login,
        );
      },
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        const Text('تذكرني'),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/forgot-password');
          },
          child: const Text('نسيت كلمة المرور؟'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ليس لديك حساب؟'),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                'إنشاء حساب جديد',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        Text(
          'بتسجيل الدخول، أنت توافق على',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),

        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show terms of service
              },
              child: const Text('شروط الخدمة'),
            ),
            const Text(' و '),
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
              },
              child: const Text('سياسة الخصوصية'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'الإصدار ${AppConfig.appVersion}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ],
    );
  }
}
