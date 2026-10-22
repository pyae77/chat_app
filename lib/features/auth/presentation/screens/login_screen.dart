
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_textformfield.dart';
import '../../../../presentation/widgets/custom_text_widget.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    UIHelpers.hideKeyboard(context);

    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _onGoogleSignInPressed() {
    UIHelpers.hideKeyboard(context);

    ref
        .read(googleAuthControllerProvider.notifier)
        .signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final googleAuthState = ref.watch(googleAuthControllerProvider);

    // Email login error listener
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (previous, next) {
        if (next.hasError && !next.isLoading) {
          if (previous?.hasError == true &&
              previous?.error == next.error) {
            return;
          }

          UIHelpers.showSnackBar(
            context,
            next.error.toString(),
            isError: true,
          );
        }
      },
    );

    // Google login error listener
    ref.listen<AsyncValue<void>>(
      googleAuthControllerProvider,
      (previous, next) {
        if (next.hasError && !next.isLoading) {
          if (previous?.hasError == true &&
              previous?.error == next.error) {
            return;
          }

          UIHelpers.showSnackBar(
            context,
            next.error.toString(),
            isError: true,
          );
        }
      },
    );

    final isAnyAuthLoading =
        authState.isLoading || googleAuthState.isLoading;

    return GestureDetector(
      onTap: () => UIHelpers.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.chat_bubble_rounded,
                      size: 72,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),

                    const CustomTextWidget(
                      text: 'Welcome',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    const CustomTextWidget(
                      text: 'Sign in to chat with your friends',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // Email
                    CustomTextFormField(
                      controller: _emailController,
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: SizedBox(
                        height: 12,
                        width: 12,
                        child: Image.asset(
                          Assets.icons.icMail.path,
                          color: AppColors.iconSecondary,
                        ),
                      ),
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _isObscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!isAnyAuthLoading) {
                          _onLoginPressed();
                        }
                      },
                      prefixIcon: SizedBox(
                        height: 12,
                        width: 12,
                        child: Image.asset(
                          Assets.icons.icLock.path,
                          color: AppColors.iconSecondary,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.iconSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                      validator: AppValidators.validatePassword,
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    CustomButton(
                      icon: Assets.icons.icLogIn.path,
                      iconColor: AppColors.white,
                      spacing: 12,
                      text: 'Sign In',
                      backgroundColor: AppColors.buttonBackground,
                      textColor: AppColors.buttonForeground,
                      onPressed:
                          isAnyAuthLoading ? null : _onLoginPressed,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // OR divider
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.textHint),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: CustomTextWidget(
                            text: 'OR',
                            fontSize: 12,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.textHint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Google Sign-In button
                    CustomButton(
                      text: 'Continue with Google',
                      backgroundColor: AppColors.surface,
                      textColor: AppColors.textPrimary,
                      onPressed: isAnyAuthLoading
                          ? null
                          : _onGoogleSignInPressed,
                      icon: Assets.icons.icGoogle.path,
                      iconColor: null,
                      spacing: 12,
                      child: googleAuthState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Navigate to Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomTextWidget(
                          text: "Don't have an account? ",
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!isAnyAuthLoading) {
                              context.push(RouteNames.register);
                            }
                          },
                          child: const CustomTextWidget(
                            text: 'Sign Up',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
    );
  }
}
