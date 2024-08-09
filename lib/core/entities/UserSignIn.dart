import 'package:whoosh/core/BaseEntity.dart';

import 'User.dart';

class UserSignIn extends BaseEntity<UserSignIn> {
  UserSignIn({
    this.token,
    this.user,
  });

  String? token;
  User? user;
  Map<String, dynamic> toJson() => {
        "token": token,
        "user": User().toJson(user),
      };
  UserSignIn fromJson(Map<String, dynamic> json) => UserSignIn(
        token: json["token"],
        user: User().fromJson(json["user"]),
      );
}
