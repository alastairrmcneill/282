import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/extensions/string_extension.dart';

void main() {
  group('String Extension', () {
    test('returns capital first letter in word sentence', () {
      String testString = "hello world from flutter";
      String result = testString.capitalize();
      expect(result, "Hello World From Flutter");
    });

    test('returns empty string when input is empty', () {
      String testString = "";
      String result = testString.capitalize();
      expect(result, "");
    });

    test('handles single word strings', () {
      String testString = "flutter";
      String result = testString.capitalize();
      expect(result, "Flutter");
    });
    test('handles strings with mixed casing', () {
      String testString = "fLuTtEr iS AwEsOmE";
      String result = testString.capitalize();
      expect(result, "Flutter Is Awesome");
    });
  });
}
