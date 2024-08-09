import 'package:whoosh/core/BaseEntity.dart';

import 'User.dart';

class UserSignUp extends BaseEntity<UserSignUp> {
  UserSignUp({
    this.status,
    this.user,
  });

  String? status;
  User? user;
  Map<String, dynamic> toJson() => {
        "status": status,
        "user": User().toJson(user),
      };
  UserSignUp fromJson(Map<String, dynamic> json) => UserSignUp(
        status: json["status"],
        user: User().fromJson(json["user"]),
      );
}
