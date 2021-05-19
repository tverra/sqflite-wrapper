part of sqflite_wrapper;

void _writeColumns(StringBuffer s, List<String> columns, {String? table}) {
  final String tableSql = table != null ? '$table.' : '';

  for (int i = 0; i < columns.length; i++) {
    final String column = columns[i];

    if (i > 0) {
      s.write(', ');
    }
    s.write('$tableSql$column');
  }
}
