// domain/repositories/user_repository.dart


import 'user_entity.dart';

abstract class UserRepository {
  Future<void> createUser(UserEntity user);
  Future<String> logIn(String username, String password);
}