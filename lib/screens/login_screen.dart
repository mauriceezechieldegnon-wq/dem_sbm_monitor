import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegisterMode) {
        await AuthService.instance.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await AuthService.instance.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      // La navigation vers Mission Control se fait automatiquement via
      // le StreamBuilder<User?> placé dans main.dart.
    } catch (e) {
      setState(() => _errorMessage = AuthService.readableError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage =
          'Entre ton e-mail ci-dessus puis retape sur "Mot de passe oublié".');
      return;
    }
    try {
      await AuthService.instance.resetPassword(_emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de réinitialisation envoyé.')),
      );
    } catch (e) {
      setState(() => _errorMessage = AuthService.readableError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          _buildBackgroundGlows(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlows() {
    return Positioned.fill(
      child: Container(
        color: AppColors.navy,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -80,
              child: _glow(AppColors.cyan.withValues(alpha:0.22), 280),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: _glow(AppColors.cyanDim.withValues(alpha:0.2), 260),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha:0)]),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cyan.withValues(alpha:0.4)),
          ),
          child: Icon(LucideIcons.building, color: AppColors.cyan, size: 30),
        ),
        const SizedBox(height: 18),
        Text('DEM SBM', style: AppTheme.displayFont(fontSize: 26)),
        const SizedBox(height: 6),
        Text(
          'Smart Building Monitor',
          style:
              AppTheme.bodyFont(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassDecoration(radius: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isRegisterMode
                      ? 'CRÉER UN COMPTE OPÉRATEUR'
                      : 'CONNEXION OPÉRATEUR',
                  style: AppTheme.monoFont(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'E-mail requis';
                    if (!value.contains('@')) return 'E-mail invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: LucideIcons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Mot de passe requis';
                    if (value.length < 6) return '6 caractères minimum';
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.danger.withValues(alpha:0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertTriangle,
                            color: AppColors.danger, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTheme.bodyFont(
                                fontSize: 12, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: AppColors.navy,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.navy,
                            ),
                          )
                        : Text(
                            _isRegisterMode
                                ? 'CRÉER LE COMPTE'
                                : 'SE CONNECTER',
                            style: AppTheme.monoFont(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                if (!_isRegisterMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTheme.bodyFont(
                            fontSize: 12, color: AppColors.cyan),
                      ),
                    ),
                  ),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _isRegisterMode = !_isRegisterMode;
                      _errorMessage = null;
                    }),
                    child: Text(
                      _isRegisterMode
                          ? 'Déjà un compte ? Se connecter'
                          : 'Pas encore de compte ? En créer un',
                      style: AppTheme.bodyFont(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTheme.bodyFont(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            AppTheme.bodyFont(fontSize: 13, color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceLight.withValues(alpha:0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }
}
