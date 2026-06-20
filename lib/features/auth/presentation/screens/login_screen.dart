import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'admin@craftedge.local');
    _passwordController = TextEditingController(text: 'password');
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    const emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final authController = ref.read(loginControllerProvider.notifier);

      await authController.login(email, password);

      if (!mounted) return;

      final authState = ref.read(loginControllerProvider);

      authState.when(
        data: (user) {
          if (user != null) {
            context.go(AppRoutes.dashboard);
          } else {
            setState(() {
              _errorMessage =
              'Invalid email or password. Please try again.';
            });
          }
        },
        loading: () {},
        error: (_, __) {
          setState(() {
            _errorMessage =
            'Invalid email or password. Please try again.';
          });
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
        'An error occurred. Please try again later.';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginControllerProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = true;

    return Scaffold(
      backgroundColor: isDark
          ? const Color.fromARGB(255, 17, 20, 30)
          : const Color(0xFFF8F9FA), // Light background for light theme
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(
                isMobile ? AppSpacing.lg : AppSpacing.xxxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and Branding
                      _buildLogoSection(),

                      // Welcome Text
                      _buildWelcomeSection(),
                      SizedBox(height: AppSpacing.xxxl),

                      // Error Message Display
                      if (_errorMessage != null) ...[
                        _buildErrorBanner(),
                        SizedBox(height: AppSpacing.lg),
                      ],

                      // Email Input Field
                      _buildEmailField(),
                      SizedBox(height: AppSpacing.lg),

                      // Password Input Field
                      _buildPasswordField(),
                      SizedBox(height: AppSpacing.md),

                      // Forgot Password Link
                      _buildForgotPasswordLink(),
                      SizedBox(height: AppSpacing.xxxl),

                      // Sign In Button
                      _buildSignInButton(isLoading),
                      SizedBox(height: AppSpacing.xxxl),

                      // Security Info Section

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      // This container groups the logo and text into a single unit.
      // Adjust the bottom padding to control the internal gap if needed.
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Transform.translate(
        // The offset moves the logo group UP (-40) without affecting
        // the position of the "Welcome back" text or other form elements.
        offset: const Offset(0, -25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 76, 107, 245).withOpacity(1),
                    blurRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
            // Configurable gap between Logo and Text
            SizedBox(height: 45),
            // Branding Text
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Craft',
                    style: AppTypography.displayHero.copyWith(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 36,
                    ),
                  ),
                  TextSpan(
                    text: 'Edge',
                    style: AppTypography.displayHero.copyWith(
                      color: AppColors.primary700.withOpacity(1),
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: AppTypography.heading1?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 30,
            color: const Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'DM Sans'

          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Sign in to your email to continue',
          style: AppTypography.bodyMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFEF4444),
            size: 20,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTypography.label?.copyWith(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL ADDRESS',
          style: AppTypography.caption?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocus);
          },
          validator: _validateEmail,
          style: AppTypography.bodyMedium?.copyWith(
            color: const Color(0xFF8A94A6),
          ),
          decoration: InputDecoration(
            hintText: 'name@company.com',
            hintStyle: AppTypography.bodyMedium?.copyWith(
              color: const Color(0xFF8A94A6),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Image.asset(
                'assets/images/login_email.png',
                width: 20,
                height: 20,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF1E2330),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary700,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASSWORD',
          style: AppTypography.caption?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSignIn(),
          validator: _validatePassword,
          style: AppTypography.bodyMedium?.copyWith(
            color: const Color(0xFF8A94A6),
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTypography.bodyMedium?.copyWith(
              color: const Color(0xFF8A94A6),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Image.asset(
                'assets/images/login_lock.png',
                width: 20,
                height: 20,
              ),
            ),
            suffixIcon: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                child: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.primary700,
                ),
              ),
            ),
            filled: true,
            fillColor: const Color(0xFF1E2330),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary700,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Placeholder for forgot password functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password recovery coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: AppTypography.label?.copyWith(
            color: AppColors.primary700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(AsyncValue<dynamic> isLoading) {
    final isButtonLoading = isLoading.when(
      data: (_) => false,
      loading: () => true,
      error: (_, __) => false,
    );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isButtonLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary700,
          disabledBackgroundColor: AppColors.primary700.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: isButtonLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.8),
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In',
              style: AppTypography.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }


}