import 'query_test.dart' as queryTest;
import 'insert_test.dart' as insertTest;
import 'update_test.dart' as updateTest;
import 'delete_test.dart' as deleteTest;

import 'join_test.dart' as joinTest;
import 'order_by_test.dart' as orderByTest;
import 'preload_test.dart' as preloadTest;
import 'query_container_test.dart' as queryContainerTest;
import 'sqf_function_test.dart' as sqfFunctionTest;
import 'temp_table_test.dart' as tempTableTest;
import 'where_test.dart' as whereTest;

main() {
  queryTest.main();
  insertTest.main();
  updateTest.main();
  deleteTest.main();
  
  joinTest.main();
  orderByTest.main();
  preloadTest.main();
  queryContainerTest.main();
  sqfFunctionTest.main();
  tempTableTest.main();
  whereTest.main();
}