import '../../models/user.dart';
import '../../result/app_error.dart';
import '../../result/result.dart';
import '../user_repository.dart';
import 'sample_data.dart';

/// Keeps the profile in memory.
class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository({User? user, this.delay = Duration.zero})
    : _user = user ?? SampleData.user;

  User _user;
  final Duration delay;

  @override
  Future<Result<User>> getProfile() async {
    await Future<void>.delayed(delay);
    return Ok(_user);
  }

  @override
  Future<Result<User>> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    await Future<void>.delayed(delay);
    if (name.trim().isEmpty) {
      return const Failure(ValidationError({'name': 'must not be empty'}));
    }
    _user = _user.copyWith(name: name.trim(), avatarUrl: () => avatarUrl);
    return Ok(_user);
  }
}
