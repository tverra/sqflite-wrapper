/// SQLite query wrapper
///
/// This package adds more abstraction to the flutter sqflite package. The
/// purpose is to make it easier to build dynamic queries.

library sqflite_wrapper;

import 'package:sqflite/sqflite.dart';

part 'src/migration/sqf_column.dart';
part 'src/migration/sqf_index.dart';
part 'src/migration/sqf_migration.dart';
part 'src/migration/sqf_references.dart';
part 'src/migration/sqf_table.dart';
part 'src/query/delete.dart';
part 'src/query/insert.dart';
part 'src/query/join.dart';
part 'src/query/order_by.dart';
part 'src/query/preload.dart';
part 'src/query/query.dart';
part 'src/query/query_container.dart';
part 'src/query/query_helpers.dart';
part 'src/query/sqf_function.dart';
part 'src/query/temp_table.dart';
part 'src/query/update.dart';
part 'src/query/where.dart';
