class User {
  User({
    this.verified,
    this.type,
    this.admin,
    this.id,
    this.name,
    this.email,
    this.password,
    this.time,
    this.updatedAt,
    this.v,
    this.zipcode,
  });

  bool? verified;
  String? type;
  bool? admin;
  String? id;
  String? name;
  String? email;
  String? password;
  DateTime? time;
  DateTime? updatedAt;
  int? v;
  String? zipcode;

  User fromJson(Map<String, dynamic> json) {
    return User(
      verified: json["verified"] == null ? null : json["verified"],
      type: json["type"] == null ? null : json["type"],
      admin: json["admin"] == null ? null : json["admin"],
      id: json["_id"] == null ? null : json["_id"],
      name: json["name"] == null ? null : json["name"],
      email: json["email"] == null ? null : json["email"],
      password: json["password"] == null ? null : json["password"],
      time: json["time"] == null ? null : DateTime.parse(json["time"]),
      updatedAt:
          json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      v: json["__v"] == null ? null : json["__v"],
      zipcode: json["zipcode"] == null ? null : json["zipcode"],
    );
  }

  Map<String, dynamic> toJson(User? user) => {
        "verified": user!.verified == null ? null : user.verified,
        "type": user.type == null ? null : user.type,
        "admin": user.admin == null ? null : user.admin,
        "_id": user.id == null ? null : user.id,
        "name": user.name == null ? null : user.name,
        "email": user.email == null ? null : user.email,
        "password": user.password == null ? null : user.password,
        "time": user.time == null ? null : user.time!.toIso8601String(),
        "updatedAt":
            user.updatedAt == null ? null : user.updatedAt!.toIso8601String(),
        "__v": user.v == null ? null : user.v,
        "zipcode": user.zipcode == null ? null : user.zipcode,
      };
}
