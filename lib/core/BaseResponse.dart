class BaseResponse<T> {
  int? code;
  T? result;
  String? type;
  String? message;
  bool? status;

  BaseResponse({
    this.code,
    this.result,
    this.type,
    this.message,
    this.status,
  });
}
