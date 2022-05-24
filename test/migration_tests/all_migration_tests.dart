import 'sqf_column_tests.dart' as sqf_column_tests;
import 'sqf_index_tests.dart' as sqf_index_tests;
import 'sqf_references_tests.dart' as sqf_references_tests;
import 'sqf_table_tests.dart' as sqf_table_tests;

void main() {
  sqf_column_tests.main();
  sqf_references_tests.main();
  sqf_table_tests.main();
  sqf_index_tests.main();
}
