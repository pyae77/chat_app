
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_entity.dart';
import 'user_model.dart';
import 'user_remote_data_source.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository{
  final UserRemoteDataSource userRemoteDataSource;
  UserRepositoryImpl({required this.userRemoteDataSource});

  @override
  Future<void> createUser(UserEntity user)async {
    final userModel = UserModel(userName:user.userName, password: user.password, id: user.id, firstName: user.firstName, lastName: user.lastName, email: user.email, phone: user.phone, userStatus: user.userStatus);
    await userRemoteDataSource.createUser(userModel);
  }

  @override
  Future<String> logIn(String username, String password) async {
    return await userRemoteDataSource.logIn(username, password);
  }

}
final UserRepositoryProvider=Provider<UserRepository>(
  (ref){ 
   final userRemoteDataSource=ref.watch(userRemoteDataSourceProvider);
   return UserRepositoryImpl(userRemoteDataSource: userRemoteDataSource);
  }
);