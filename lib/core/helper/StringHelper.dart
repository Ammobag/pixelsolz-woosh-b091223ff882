extension StringTransform on String {
  bool isEmptyX([bool trimBeforeCompare = true]) {
    var trimValue = this;

    if (trimBeforeCompare) {
      trimValue = trimValue.trim();
    }

    return trimValue.isEmpty;
  }
}
