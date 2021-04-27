import 'delete_test.dart' as delete_test;
import 'insert_test.dart' as insert_test;
import 'join_test.dart' as join_test;
import 'order_by_test.dart' as order_by_test;
import 'preload_test.dart' as preload_test;
import 'query_container_test.dart' as query_container_test;
import 'query_test.dart' as query_test;
import 'sqf_function_test.dart' as sqf_function_test;
import 'temp_table_test.dart' as temp_table_test;
import 'update_test.dart' as update_test;
import 'where_test.dart' as where_test;

void main() {
  query_test.main();
  insert_test.main();
  update_test.main();
  delete_test.main();

  join_test.main();
  order_by_test.main();
  preload_test.main();
  query_container_test.main();
  sqf_function_test.main();
  temp_table_test.main();
  where_test.main();
}
