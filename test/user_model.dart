
import 'user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.userName,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.password,
    required super.phone,
    required super.userStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      userName: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      userStatus: json['userStatus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'userStatus': userStatus,
    };
  }
}