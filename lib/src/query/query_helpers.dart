part of sqflite_wrapper;

void _writeColumns(
  StringBuffer s,
  List<String> columns, {
  String? table,
  bool escapeNames = true,
}) {
  final String tableSql = table != null
      ? escapeNames
          ? '`$table`.'
          : '$table.'
      : '';

  for (int i = 0; i < columns.length; i++) {
    final String column = columns[i];

    if (i > 0) {
      s.write(', ');
    }
    if (escapeNames) {
      s.write('$tableSql`$column`');
    } else {
      s.write('$tableSql$column');
    }
  }
}
