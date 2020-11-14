part of sqflite_wrapper;

void _writeColumns(StringBuffer s, List<String> columns, {String table}) {
  if (table == null) {
    table = '';
  } else {
    table = '$table.';
  }

  for (var i = 0; i < columns.length; i++) {
    final column = columns[i];

    if (column != null) {
      if (i > 0) {
        s.write(', ');
      }
      s.write('$table$column');
    } else {
      s.write('NULL');
    }
  }
}
