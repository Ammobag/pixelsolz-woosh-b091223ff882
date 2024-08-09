abstract class BaseApiRequestModel {
  Map<String, dynamic> prepareJson();

  Map<String, dynamic> toJson() {
    var baseData = prepareJson();

    return baseData;
  }
}

class EmptyBaseApiRequestModel extends BaseApiRequestModel {
  @override
  Map<String, dynamic> prepareJson() {
    return {};
  }
}
