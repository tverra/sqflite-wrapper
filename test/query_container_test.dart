import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_wrapper/sqflite_wrapper.dart';

main() {
  group('QueryContainer', () {
    test('works as an encapsulation for query and args', () {
      QueryContainer query = QueryContainer(query: 'query', args: [1, 2, 3]);

      expect(query.query, 'query');
      expect(query.args, [1, 2, 3]);
    });
  });
}
