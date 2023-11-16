class Error {
  final String code;
  final String message;

  Error({
    this.code = "",
    this.message = "",
  });

  static Error test() {
    return Error(code: "Test Error", message: "This is a test error message");
  }
}
