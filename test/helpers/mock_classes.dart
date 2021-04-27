import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockBatch extends Mock implements Batch {
  final List<String> _statements = <String>[];
  final List<Object?> _arguments = <Object?>[];

  List<String> get statements {
    return _statements;
  }

  List<Object?> get arguments {
    return _arguments;
  }

  @override
  void rawInsert(String sql, [List<Object?>? arguments]) {
    _statements.add(sql);

    if (arguments != null) {
      _arguments.addAll(arguments);
    }
  }
}
