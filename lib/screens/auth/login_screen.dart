import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AuthController.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../Controllers/SettingsController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

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

    // Prevent multiple login attempts
    if (_authController.isLoading.value) return;

    try {
      final response = await _authController.login(
        _loginController.text.trim(),
        _passwordController.text,
      );

      if (response.isSuccess) {
        // Login successful, navigate to main screen using GetX
        Get.offAllNamed('/main');
      } else {
        _showErrorDialog(response.errorMessage);
      }
    } catch (e) {
      _showErrorDialog('unexpected_error'.tr);
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: Text('login_error'.tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final SettingsController settingsController = Get.find<SettingsController>();
                        _showLanguageBottomSheet(context, settingsController);
                      },
                      child: Obx(() {
                        final SettingsController settingsController = Get.find<SettingsController>();
                        return Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              'assets/flags/${settingsController.currentLanguage.value}.png',
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

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
          ),
        ),

        const SizedBox(height: 20),

        // App Name
        Text(
          'safedest_driver'.tr,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'welcome_to_driver_app'.tr,
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
          label: 'email_or_username'.tr,
          hint: 'enter_email_or_username'.tr,
          keyboardType: TextInputType.text,
          prefixIcon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'please_enter_email'.tr;
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Password Field
        CustomTextField(
          controller: _passwordController,
          label: 'password'.tr,
          hint: 'enter_password'.tr,
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
              return 'please_enter_password'.tr;
            }
            if (value.length < 6) {
              return 'password_min_length'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => CustomButton(
          text: 'login'.tr,
          onPressed: _authController.isLoading.value ? null : _handleLogin,
          isLoading: _authController.isLoading.value,
          icon: Icons.login,
        ));
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
        Text('remember_me'.tr),
        const Spacer(),
        TextButton(
          onPressed: () {
            Get.toNamed('/forgot-password');
          },
          child: Text('forgot_password'.tr),
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
            Text('dont_have_account'.tr),
            TextButton(
              onPressed: () {
                Get.toNamed('/register');
              },
              child: Text(
                'create_new_account'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        Text(
          'by_logging_in_you_agree'.tr,
          textAlign: TextAlign.center,
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
              child: Text('terms_of_service'.tr),
            ),
            Text('and'.tr),
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
              },
              child: Text('privacy_policy'.tr),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Version number
        Text(
          'V 1.0.0', // Standard version text, can be linked to AppConfig later
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ],
    );
  }

  void _showLanguageBottomSheet(BuildContext context, SettingsController settingsController) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageListTile(context, "ar", "AE", settingsController),
              const SizedBox(height: 10),
              _buildLanguageListTile(context, "en", "US", settingsController),
              const SizedBox(height: 10),
              _buildLanguageListTile(context, "ur", "PK", settingsController),
              const SizedBox(height: 10),
              _buildLanguageListTile(context, "zh", "CN", settingsController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageListTile(BuildContext context, String languageCode, String countryCode, SettingsController settingsController) {
    return Obx(() {
      final isSelected = settingsController.currentLanguage.value == languageCode;
      return ListTile(
        leading: ClipOval(
          child: Image.asset(
            'assets/flags/$languageCode.png',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          languageCode == "ar" ? "العربية" :
          languageCode == "en" ? "English" :
          languageCode == "ur" ? "اردو" : "中文",
        ),
        trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
        onTap: () {
          settingsController.changeLanguage(languageCode);
          Navigator.pop(context);
        },
      );
    });
  }
}
