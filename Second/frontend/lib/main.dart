import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ─── CONFIGURE THESE ────────────────────────────────────────────────────────
// Replace with your backend IP/domain when testing on a real device
const String kBackendBase = 'http://10.0.2.2:8080'; // Android emulator localhost
// const String kBackendBase = 'http://localhost:8080'; // iOS simulator
// Must match the scheme in OAuth2AuthenticationSuccessHandler.java
const String kDeepLinkScheme = 'myapp';
const String kDeepLinkCallbackUrl = '$kDeepLinkScheme://auth/callback';
// ─────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Future<void> _loginWith(String provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 1. Open the Spring Boot OAuth2 login URL in a browser
      final authUrl = '$kBackendBase/oauth2/authorization/$provider';
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: kDeepLinkScheme,
      );
      // 2. Extract the JWT from the deep link query param
      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];
      if (token == null || token.isEmpty) {
        throw Exception('No token received from server');
      }
      // 3. Persist the token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      // 4. Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please try again.';
      });
      debugPrint('OAuth error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / App name
              const Icon(Icons.bolt, size: 64, color: Color(0xFF6C63FF)),
              const SizedBox(height: 16),
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.white54),
              ),
              const SizedBox(height: 48),
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade800),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // OAuth Buttons
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                )
              else ...[
                _OAuthButton(
                  label: 'Continue with Google',
                  iconPath: 'assets/icons/google.png', // add to assets
                  fallbackIcon: Icons.g_mobiledata,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  onTap: () => _loginWith('google'),
                ),
                const SizedBox(height: 14),
                _OAuthButton(
                  label: 'Continue with GitHub',
                  iconPath: 'assets/icons/github.png',
                  fallbackIcon: Icons.code,
                  backgroundColor: const Color(0xFF24292E),
                  textColor: Colors.white,
                  onTap: () => _loginWith('github'),
                ),
                const SizedBox(height: 14),
                _OAuthButton(
                  label: 'Continue with Facebook',
                  iconPath: 'assets/icons/facebook.png',
                  fallbackIcon: Icons.facebook,
                  backgroundColor: const Color(0xFF1877F2),
                  textColor: Colors.white,
                  onTap: () => _loginWith('facebook'),
                ),
              ],
              const SizedBox(height: 40),
              const Text(
                'By signing in you agree to our Terms of Service\nand Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _OAuthButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  const _OAuthButton({
    required this.label,
    required this.iconPath,
    required this.fallbackIcon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            children: [
              // Try loading asset icon, fallback to material icon
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  iconPath,
                  errorBuilder: (_, __, ___) =>
                      Icon(fallbackIcon, color: textColor, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
