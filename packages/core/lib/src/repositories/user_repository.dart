import '../models/user.dart';
import '../result/result.dart';

/// Profile of the signed-in user.
abstract interface class UserRepository {
  Future<Result<User>> getProfile();

  Future<Result<User>> updateProfile({required String name, String? avatarUrl});
}
