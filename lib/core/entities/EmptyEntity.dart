import 'package:whoosh/core/BaseEntity.dart';

class EmptyEntity extends BaseEntity<EmptyEntity> {
  @override
  EmptyEntity fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
