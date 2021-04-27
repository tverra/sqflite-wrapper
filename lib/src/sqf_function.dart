part of sqflite_wrapper;

class SqfFunction {
  late final String sql;

  SqfFunction(String function, {String? alias}) {
    final StringBuffer buffer = StringBuffer();

    buffer.write(function);
    if (alias != null) buffer.write(' AS $alias');

    sql = buffer.toString();
  }

  SqfFunction.abs(String param, {String? alias}) {
    _buildSql('ABS', <String>[param], alias);
  }

  SqfFunction.avg(String param, {String? alias}) {
    _buildSql('AVG', <String>[param], alias);
  }

  SqfFunction.count(String param, {String? alias}) {
    _buildSql('COUNT', <String>[param], alias);
  }

  SqfFunction.max(String param, {String? alias}) {
    _buildSql('MAX', <String>[param], alias);
  }

  SqfFunction.min(String param, {String? alias}) {
    _buildSql('MIN', <String>[param], alias);
  }

  SqfFunction.random({String? alias}) {
    _buildSql('RANDOM', <String>[], alias);
  }

  SqfFunction.round(String param, {int? decimalPlaces, String? alias}) {
    final List<String> params = <String>[param];
    if (decimalPlaces != null) params.add(decimalPlaces.toString());

    _buildSql('ROUND', params, alias);
  }

  SqfFunction.sum(String param, {String? alias}) {
    _buildSql('SUM', <String>[param], alias);
  }

  SqfFunction.coalesce(List<String> params, {String? alias}) {
    _buildSql('COALESCE', params, alias);
  }

  void _buildSql(String function, List<String> params, [String? alias]) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('$function(');

    for (int i = 0; i < params.length; i++) {
      if (i > 0) buffer.write(', ');
      buffer.write(params[i]);
    }
    buffer.write(')');
    if (alias != null) buffer.write(' AS $alias');

    sql = buffer.toString();
  }
}
