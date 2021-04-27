import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

void main() {
  group('QueryContainer', () {
    test('works as an encapsulation for query and args', () {
      final QueryContainer query = QueryContainer(
        query: 'query',
        args: <dynamic>[1, 2, 3],
      );

      expect(query.query, 'query');
      expect(query.args, <dynamic>[1, 2, 3]);
    });
  });
}
