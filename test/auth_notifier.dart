import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_logIn_usecase.dart';

class AuthNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return "";
  }

  Future<String?> logIn(String username, String password) async {
    state = const AsyncValue.loading();
    
    final loginUseCase = ref.read(LogInUseCaseProvider);
    
    
    state = await AsyncValue.guard(() => loginUseCase(username, password));
    
    if (state.hasError) {
      return state.error.toString();
    }
    return null; // Success
  }
}


final authNotifierProvider = 
    AsyncNotifierProvider.autoDispose<AuthNotifier, void>(
  AuthNotifier.new,
);