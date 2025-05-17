import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moodfit/providers/auth_provider.dart';
import 'package:moodfit/screens/auth/login_screen.dart';
import 'package:moodfit/utils/design_system.dart';
import 'package:moodfit/utils/signup_handler.dart';
import 'package:moodfit/widgets/mood_fit_button.dart';
import 'package:moodfit/widgets/mood_fit_text_field.dart';
import 'package:provider/provider.dart';
import '../../utils/toast_util.dart';
import 'package:moodfit/widgets/slider_verification.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isHumanVerified = false;
  late AnimationController _animController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms && _isHumanVerified) {
      // Show confirmation dialog before registering
      final confirmed = await ToastUtil.showConfirmationDialog(
        context: context,
        title: 'Create Account',
        message: 'Are you sure you want to create a new account?',
        confirmText: 'Create Account',
      );

      if (!confirmed) return;

      // Mark signup as active BEFORE Firebase authentication (optional, you may remove if unused)
      await SignupHandler.markSignupActive();
      debugPrint("RegisterScreen: Marked signup as active");

      // ignore: use_build_context_synchronously
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (result && mounted) {
        // Show success toast
        ToastUtil.showSuccessToast(
            'Account created successfully! Please log in.');

        // Instead of auto-login, go to LoginScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (mounted && authProvider.error != null) {
        // Clear signup flag if registration failed
        await SignupHandler.clearSignupActive();

        // Show error toast if sign-up failed
        ToastUtil.showErrorToast(authProvider.error ?? 'Registration failed');
      }
    } else if (!_acceptTerms && mounted) {
      ToastUtil.showErrorToast('Please accept the terms and conditions');
    } else if (!_isHumanVerified && mounted) {
      ToastUtil.showErrorToast('Please verify you are human');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/registration_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surface.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: isDark
                            ? Border.all(color: Colors.white.withOpacity(0.1))
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary.withOpacity(0.1),
                                ),
                                child: Image.asset(
                                  'assets/images/moodfit_logo.png',
                                  height: 80,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Header Text
                              Text(
                                'Create Account',
                                style: MoodFitDesignSystem.heading2(context),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join MoodFit to start your fitness journey',
                                style:
                                    MoodFitDesignSystem.body2(context).copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Name Field
                              MoodFitTextField(
                                controller: _nameController,
                                labelText: 'Full Name',
                                hintText: 'Enter your full name',
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Email Field
                              MoodFitTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Password Field
                              MoodFitTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: !_isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Confirm Password Field
                              MoodFitTextField(
                                controller: _confirmPasswordController,
                                labelText: 'Confirm Password',
                                hintText: 'Confirm your password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: !_isConfirmPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Terms and Conditions
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _acceptTerms,
                                      activeColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms = value ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'I accept the ',
                                        style:
                                            MoodFitDesignSystem.body2(context),
                                        children: [
                                          TextSpan(
                                            text: 'Terms and Conditions',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Verification Slider
                              SliderVerification(
                                onVerified: (verified) {
                                  setState(() {
                                    _isHumanVerified = verified;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),

                              // Error Message
                              if (authProvider.error != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authProvider.error!,
                                          style:
                                              MoodFitDesignSystem.body2(context)
                                                  .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),

                              // Sign Up Button
                              MoodFitButton(
                                label: 'Sign Up',
                                onPressed: _handleRegister,
                                isLoading: authProvider.isLoading,
                                isFullWidth: true,
                                isDisabled: !_isHumanVerified || !_acceptTerms,
                                icon: Icons.person_add_outlined,
                              ),

                              const SizedBox(height: 24),

                              // Already have an account
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: MoodFitDesignSystem.body2(context),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: MoodFitDesignSystem.textButtonStyle(
                                        context),
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
