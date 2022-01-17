part of sqflite_wrapper;

class SqfMigration {
  final int version;
  final List<String> actions;
  final List<String> rollback;

  const SqfMigration({
    required this.version,
    required this.actions,
    required this.rollback,
  });
}