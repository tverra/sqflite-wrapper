import 'migration_tests/all_migration_tests.dart' as migration_tests;
import 'query_tests/all_query_tests.dart' as query_tests;

void main() {
  query_tests.main();
  migration_tests.main();
}
