import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_repository.dart';
import 'user_repository_impl.dart';

class LogInUseCase{
  final UserRepository repo;

  LogInUseCase({required this.repo});
  Future<String> call(String username, String password) async {
    return await repo.logIn(username, password);
  }
}
final LogInUseCaseProvider=Provider<LogInUseCase>(
  (ref){
   final repo=ref.watch(UserRepositoryProvider);
   return LogInUseCase(repo: repo);
  }
);