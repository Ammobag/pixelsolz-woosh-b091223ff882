abstract class BaseEntity<T> {
  T fromJson(Map<String, dynamic> json);
  List<T> fromJsonToList(List<dynamic> json) {
    List<T> returnData = [];

    json.forEach((e) {
      T data = fromJson(e);
      returnData.add(data);
    });

    return returnData.toList();
  }
}
