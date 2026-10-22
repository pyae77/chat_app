

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/routes/route_names.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_textformfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_text_widget.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    UIHelpers.hideKeyboard(context);

    if (!_formKey.currentState!.validate()) return;

    ref.read(signUpControllerProvider.notifier).signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpControllerProvider);

    ref.listen<AsyncValue<void>>(
      signUpControllerProvider,
      (previous, next) {
        // Registration error
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
          return;
        }

        // Navigate only after a successful registration operation.
        if (previous?.isLoading == true &&
            next.hasValue &&
            !next.isLoading &&
            !next.hasError) {
          UIHelpers.showSnackBar(
            context,
            'Account created successfully! Please sign in.',
            isError: false,
          );

          context.go(RouteNames.login);
        }
      },
    );

    return GestureDetector(
      onTap: () => UIHelpers.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          leading: Assets.icons.icArrowLeft.path,
          leadingPressed: () => context.pop(),
        ),
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
                    const CustomTextWidget(
                      text: 'Create Account',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    const CustomTextWidget(
                      text:
                          'Sign up to start connecting with your friends',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Name
                    CustomTextFormField(
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Image.asset(
                        Assets.icons.icPerson.path,
                        color: AppColors.iconSecondary,
                      ),
                      validator: (value) =>
                          AppValidators.validateRequired(
                        value,
                        'full name',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomTextFormField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Image.asset(
                        Assets.icons.icMail.path,
                        color: AppColors.iconSecondary,
                      ),
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      obscureText: _isObscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!signUpState.isLoading) {
                          _onRegisterPressed();
                        }
                      },
                      prefixIcon: Image.asset(
                        Assets.icons.icLock.path,
                        color: AppColors.iconSecondary,
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

                    // Register button
                    CustomButton(
                      text: 'Sign Up',
                      icon: Assets.icons.icSignUp.path,
                      iconColor: AppColors.white,
                      spacing: 12,
                      backgroundColor: AppColors.buttonBackground,
                      textColor: AppColors.buttonForeground,
                      onPressed: signUpState.isLoading
                          ? null
                          : _onRegisterPressed,
                      child: signUpState.isLoading
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
                    const SizedBox(height: 16),

                    // Navigate to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomTextWidget(
                          text: 'Already have an account? ',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!signUpState.isLoading) {
                              context.go(RouteNames.login);
                            }
                          },
                          child: const CustomTextWidget(
                            text: 'Sign In',
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
