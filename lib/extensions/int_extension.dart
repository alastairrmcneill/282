extension IntExtension on int {
  String thousandsSeparator() {
    return toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
