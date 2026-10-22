class UserEntity {
  final int id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final int userStatus;

  const UserEntity({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.userStatus,
  });
}