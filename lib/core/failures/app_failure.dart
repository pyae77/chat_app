abstract class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class UserFetchFailure extends AppFailure {
  const UserFetchFailure([super.message = 'Failed to load users from database.']);
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'An unexpected server error occurred.']);
}
class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Please check your internet connection.']);
}


class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}