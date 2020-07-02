import 'package:flutter_test/flutter_test.dart';
import 'package:notekeeperapp/screens/note_detail.dart';

void main() {
  test('title is empty', () {
    var result= TitleFieldValidator.validate('');
    expect(result, 'Title cannot be empty');
  });

  test('title non-empty but exceeds 20 characters', () {
    String input= 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    var result= TitleFieldValidator.validate(input);
    expect(result, 'Limit characters to 20');
  });
}