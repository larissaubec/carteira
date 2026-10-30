import 'json.dart';
import 'user.dart';

/// An authenticated session.
///
/// The token is private: nothing outside this class can change it, and the
/// only way to read it is through [token]. That is encapsulation in practice.
class Session {
  const Session({required this._token, required this.user});

  factory Session.fromJson(Json json) => Session(
    token: json.readString('token'),
    user: User.fromJson(json.readObject('user')),
  );

  final String _token;
  final User user;

  String get token => _token;

  /// Value for the `Authorization` header.
  String get authorizationHeader => 'Bearer $_token';

  Json toJson() => {'token': _token, 'user': user.toJson()};

  Session copyWith({User? user}) =>
      Session(token: _token, user: user ?? this.user);

  @override
  bool operator ==(Object other) =>
      other is Session && other._token == _token && other.user == user;

  @override
  int get hashCode => Object.hash(_token, user);

  @override
  String toString() => 'Session(${user.email})';
}
