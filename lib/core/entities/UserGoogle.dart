class UserGoogle {
  UserGoogle({
    this.verified,
    this.type,
    this.admin,
    this.id,
    this.email,
    this.name,
    this.time,
    this.updatedAt,
    this.v,
  });

  bool? verified;
  String? type;
  bool? admin;
  String? id;
  String? email;
  String? name;
  DateTime? time;
  DateTime? updatedAt;
  int? v;

  UserGoogle fromJson(Map<String, dynamic> json) => UserGoogle(
        verified: json["verified"] == null ? null : json["verified"],
        type: json["type"] == null ? null : json["type"],
        admin: json["admin"] == null ? null : json["admin"],
        id: json["_id"] == null ? null : json["_id"],
        email: json["email"] == null ? null : json["email"],
        name: json["name"] == null ? null : json["name"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"] == null ? null : json["__v"],
      );

  Map<String, dynamic> toJson(UserGoogle? user) => {
        "verified": user!.verified == null ? null : user.verified,
        "type": user.type == null ? null : user.type,
        "admin": user.admin == null ? null : user.admin,
        "_id": user.id == null ? null : user.id,
        "email": user.email == null ? null : user.email,
        "name": user.name == null ? null : user.name,
        "time": user.time == null ? null : user.time!.toIso8601String(),
        "updatedAt":
            user.updatedAt == null ? null : user.updatedAt!.toIso8601String(),
        "__v": user.v == null ? null : user.v,
      };
}
