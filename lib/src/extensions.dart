import 'package:sqflite_wrapper/sqflite_wrapper.dart';

extension ColumnsToString on List<SqfColumn> {
  String toCommaSeparated({bool escape = true}) {
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      if (escape) buffer.write('`');
      buffer.write(this[i].name);
      if (escape) buffer.write('`');

      if (i < length - 1) {
        buffer.write(', ');
      }
    }

    return buffer.toString();
  }
}
