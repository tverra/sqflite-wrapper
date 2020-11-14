import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockBatch extends Mock implements Batch {
  final List<String> _statements = <String>[];
  final List _arguments = [];

  get statements {
    return _statements;
  }

  get arguments {
    return _arguments;
  }

  @override
  void rawInsert(String sql, [List arguments]) {
    _statements.add(sql);
    _arguments.addAll(arguments);
  }
}
