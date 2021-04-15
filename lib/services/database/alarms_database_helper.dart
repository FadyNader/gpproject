import 'package:e_commerce_app_flutter/models/Alarm.dart';
import 'package:sqflite/sqflite.dart';

class AlarmProvider {
  AlarmProvider._();

  static final instance = AlarmProvider._();

  Database db;

  Future open() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = '$databasesPath/app.db';
    print(path);

    db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
          create table $tableAlarms ( 
            $columnId integer primary key autoincrement, 
            $columnNotificationID integer not null,
            $columnTitle text not null,
            $columnDescription text not null,
            $columnAlarmingStartDate integer not null,
            $columnAlarmingEndDate integer not null,
            $columnDaysScheduled integer not null,
            $columnAlarmingTimes text not null
            )
          ''');
    });
  }

  Future<Alarm> insert(Alarm alarm) async {
    alarm.id = await db.insert(tableAlarms, alarm.toMap());
    return alarm;
  }

  Future<List<Alarm>> getAlarms() async {
    try {
      List<Map<String, Object>> records = await db.rawQuery('SELECT * FROM $tableAlarms');
      List<Alarm> alarms = [];
      for (int i = 0; i < records.length; i++) {
        alarms.add(Alarm.fromMap(records[i]));
      }
      return alarms;
    } catch (ex) {
      print(ex);
    }
  }

  Future<Alarm> getAlarm(int id) async {
    List<Map> maps = await db.query(
      tableAlarms,
      columns: [
        columnId,
        columnNotificationID,
        columnTitle,
        columnDescription,
        columnAlarmingStartDate,
        columnAlarmingEndDate,
        columnDaysScheduled,
        columnAlarmingTimes,
      ],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return Alarm.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableAlarms, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    return await db.delete(tableAlarms);
  }

  Future<int> update(Alarm alarm) async {
    return await db.update(tableAlarms, alarm.toMap(), where: '$columnId = ?', whereArgs: [alarm.id]);
  }

  Future close() async => db.close();
}
