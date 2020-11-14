/// SQLite query wrapper
///
/// This package adds more abstraction to the flutter sqflite package. The
/// purpose is to make it easier to build dynamic queries.

library sqflite_wrapper;

import 'package:sqflite/sqflite.dart';
part 'src/query_helpers.dart';

part 'src/join.dart';
part 'src/order_by.dart';
part 'src/preload.dart';
part 'src/query_container.dart';
part 'src/sqf_function.dart';
part 'src/temp_table.dart';
part 'src/where.dart';

part 'src/query.dart';
part 'src/insert.dart';
part 'src/update.dart';
part 'src/delete.dart';