import 'package:whoosh/core/entities/UserGoogle.dart';

import '../BaseEntity.dart';

class UserSignInWithGoogle extends BaseEntity<UserSignInWithGoogle> {
  UserSignInWithGoogle({
    this.token,
    this.user,
  });

  String? token;
  UserGoogle? user;
  Map<String, dynamic> toJson() => {
        "token": token,
        "user": UserGoogle().toJson(user),
      };
  UserSignInWithGoogle fromJson(Map<String, dynamic> json) =>
      UserSignInWithGoogle(
        token: json["token"],
        user: UserGoogle().fromJson(json["user"]),
      );
}
