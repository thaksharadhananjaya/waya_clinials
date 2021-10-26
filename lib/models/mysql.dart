import 'package:mysql1/mysql1.dart';

class Mysql {
  Future<MySqlConnection> getConnection() async {
    var settings = new ConnectionSettings(
        host: '213.190.6.85',
        port: 3306,
        user: 'u688585976_poiu',
        password: 'WaYamba@2017',
        db: 'u688585976_wayamba_medi');
    try {
      return await MySqlConnection.connect(settings);
    } catch (_) {}
    return null;
  }
}
