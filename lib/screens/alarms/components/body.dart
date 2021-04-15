import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Alarm.dart';
import 'package:e_commerce_app_flutter/screens/alarms_new/alarms_new_screen.dart';
import 'package:e_commerce_app_flutter/services/database/alarms_database_helper.dart';
import 'package:e_commerce_app_flutter/services/local_notifications/notifications_manager.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(screenPadding)),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: getProportionateScreenHeight(10)),
              Text(
                "Alarms",
                style: headingStyle,
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              Expanded(
                child: FutureBuilder(
                  future: AlarmProvider.instance.getAlarms(),
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData)
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10.0),
                            Text("Loading..."),
                          ],
                        ),
                      );
                    else if (snapshot.data.isEmpty) {
                      return Center(child: Text("No Alarms"));
                    } else {
                      return ListView.separated(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: snapshot.data.length,
                        separatorBuilder: (ctx, index) {
                          return SizedBox(height: 16.0);
                        },
                        itemBuilder: (ctx, index) {
                          Alarm alarm = snapshot.data[index];
                          return _alarmTile(alarm);
                        },
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              FloatingActionButton.extended(
                onPressed: _addNewAlarm,
                label: Text(
                  "Add Alarm",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                icon: Icon(
                  Icons.add,
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
            ],
          ),
        ),
      ),
    );
  }

  Future _addNewAlarm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmsNewScreen(),
      ),
    );
    setState(() {});
  }

  Widget _alarmTile(Alarm alarm) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("${alarm.title}"),
                SizedBox(height: 8.0),
                Text("${alarm.description}"),
                SizedBox(height: 8.0),
                Text("${alarm.alarmingTimes.length} times in day"),
                SizedBox(height: 8.0),
                Text("Every ${alarm.daysScheduled} day"),
                SizedBox(height: 8.0),
                Text("${_getDateString(alarm.alarmingStartDate)} : ${_getDateString(alarm.alarmingEndDate)}"),
                SizedBox(height: 8.0),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.delete), onPressed: () => _removeAlarm(alarm)),
        ],
      ),
    );
  }

  String _getDateString(DateTime date) {
    Intl.defaultLocale = "en_US";
    var timeFormatter = DateFormat('dd/MM/yyyy');
    return timeFormatter.format(date);
  }

  _removeAlarm(Alarm alarm) async {
    bool isConfirmed = await _showConfirmDialog();

    if (isConfirmed) {
      _showLoadingDialog();

      await NotificationManager.instance.flutterLocalNotificationsPlugin.cancel(alarm.notificationID);
      await AlarmProvider.instance.delete(alarm.id);

      Navigator.pop(context);

      setState(() {});
    }
  }

  void _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              "Confirm Delete",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Are you sure to delete this alarm?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        });
  }
}
