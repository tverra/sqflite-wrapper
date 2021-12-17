part of sqflite_wrapper;

class SqfReferences {
  final String foreignTableName;
  final String foreignColumnName;
  final SqfAction? onUpdate;
  final SqfAction? onDelete;

  SqfReferences({
    required this.foreignTableName,
    required this.foreignColumnName,
    this.onUpdate,
    this.onDelete,
  });

  String sql({required String columnName}) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('REFERENCES `$foreignTableName`(`$foreignColumnName`)');

    if (onUpdate != null) {
      buffer.write(' ON UPDATE ${sqfActions[onUpdate!.index]}');
    }
    if (onDelete != null) {
      buffer.write(' ON DELETE ${sqfActions[onDelete!.index]}');
    }

    return buffer.toString();
  }
}

List<String> sqfActions = <String>[
  'NO ACTION',
  'RESTRICT',
  'SET NULL',
  'SET DEFAULT',
  'CASCADE',
];
enum SqfAction {
  noAction,
  restrict,
  setNull,
  setDefault,
  cascade,
}
