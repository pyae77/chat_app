import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';

class LogInScreen extends ConsumerWidget{

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState=ref.watch(authNotifierProvider);
    return Scaffold(
      body:Column(children: [
        TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            authState.when(
              data: (message) => Text('Sucess'),
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text('Error: $error'),
            ),
            CustomButton(
              
              child: const Text('Log In'),
              onPressed:authState.isLoading?null:(){
                ref.read(authNotifierProvider.notifier).logIn(
                  _usernameController.text,
                  _passwordController.text,
                );
              }
            ),
      ],)
    );
  }
    
}