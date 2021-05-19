import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {
  final List<Transaction> _transactions = <Transaction>[];

  List<Transaction> get transactions {
    return _transactions;
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action,
      {bool? exclusive}) {
    final Transaction transaction = MockTransaction();
    _transactions.add(transaction);

    return action(transaction);
  }
}

class MockTransaction extends Mock implements Transaction {
  final List<Batch> _batches = <Batch>[];

  List<Batch> get batches {
    return _batches;
  }

  @override
  Batch batch() {
    final Batch batch = MockBatch();

    _batches.add(batch);
    return batch;
  }
}

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

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    _statements.add(sql);

    if (arguments != null) {
      _arguments.addAll(arguments);
    }
  }

  @override
  Future<List<Object?>> commit(
      {bool? exclusive, bool? noResult, bool? continueOnError}) async {
    return <Object?>[];
  }
}
