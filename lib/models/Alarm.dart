import 'dart:convert';

final String tableAlarms = 'alarms';
final String columnId = '_id';
final String columnNotificationID = 'notification_id';
final String columnTitle = 'title';
final String columnDescription = 'description';
final String columnAlarmingStartDate = 'alarming_start_date';
final String columnAlarmingEndDate = 'alarming_end_date';
final String columnDaysScheduled = 'days_scheduled';
final String columnAlarmingTimes = 'alarming_times';

class Alarm {
  int id;
  int notificationID;
  String title;
  String description;
  DateTime alarmingStartDate;
  DateTime alarmingEndDate;
  int daysScheduled;
  List<dynamic> alarmingTimes;

  Alarm({
    this.id,
    this.notificationID,
    this.title,
    this.description,
    this.alarmingStartDate,
    this.alarmingEndDate,
    this.daysScheduled,
    this.alarmingTimes,
  });

  Map<String, Object> toMap() {
    var map = <String, Object>{
      columnNotificationID: notificationID,
      columnTitle: title,
      columnDescription: description,
      columnAlarmingStartDate: alarmingStartDate.millisecondsSinceEpoch,
      columnAlarmingEndDate: alarmingEndDate.millisecondsSinceEpoch,
      columnDaysScheduled: daysScheduled,
      columnAlarmingTimes: json.encode(alarmingTimes.map((e) => e.millisecondsSinceEpoch).toList()),
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  factory Alarm.fromMap(Map<String, Object> map) {
    return Alarm(
      id: map[columnId],
      notificationID: map[columnNotificationID],
      title: map[columnTitle],
      description: map[columnDescription],
      alarmingStartDate: DateTime.fromMillisecondsSinceEpoch(map[columnAlarmingStartDate]),
      alarmingEndDate: DateTime.fromMillisecondsSinceEpoch(map[columnAlarmingEndDate]),
      daysScheduled: map[columnDaysScheduled],
      alarmingTimes: json.decode(map[columnAlarmingTimes]).map((e) => DateTime.fromMillisecondsSinceEpoch(e)).toList(),
    );
  }
}
