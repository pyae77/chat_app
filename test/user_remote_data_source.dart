import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart'; 
import 'user_model.dart';

class UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSource({required this.dio});

  Future<void> createUser(UserModel user) async {
    await dio.post('/user', data: user.toJson());
  }

  Future<String> logIn(String username, String password) async {
    final response = await dio.get(
      '/user/login',
      queryParameters: {'username': username, 'password': password},
    );
    return response.data['message'];
  }
}


final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRemoteDataSource(dio: dio);
});