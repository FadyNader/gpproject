import 'dart:math';

import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Alarm.dart';
import 'package:e_commerce_app_flutter/services/database/alarms_database_helper.dart';
import 'package:e_commerce_app_flutter/services/local_notifications/notifications_manager.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _daysScheduledController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<DateTime> _alarmingTimes = [];

  List<DateTime> _pickedDates;

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _daysScheduledController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(screenPadding)),
        child: SizedBox(
          width: double.infinity,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Title",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Alarm Times",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  IconButton(icon: Icon(Icons.add), onPressed: _addAlarmingTime),
                  SizedBox(height: 8),
                  Container(
                    padding: (_alarmingTimes.isEmpty) ? const EdgeInsets.all(0.0) : const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _alarmingTimes
                          .map(
                            (alarmingTime) => Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _getTimeString(alarmingTime),
                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => setState(() => _alarmingTimes.remove(alarmingTime))),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Repeat Alarms", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Every",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _daysScheduledController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 2,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        "Days",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Due Dates", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: _showDatePicker,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _fromDateController,
                            enabled: false,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _toDateController,
                            enabled: false,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
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
            ],
          ),
        ),
      ),
    );
  }

  Future _addAlarmingTime() async {
    final TimeOfDay timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timeOfDay != null) {
      DateTime newAlarmingTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      setState(() => _alarmingTimes.add(newAlarmingTime));
    }
  }

  Future _showDatePicker() async {
    final List<DateTime> picked = await DateRangePicker.showDatePicker(
      context: context,
      initialFirstDate: (_pickedDates == null) ? DateTime.now() : _pickedDates.first,
      initialLastDate: (_pickedDates == null) ? DateTime.now().add(Duration(days: 7)) : _pickedDates.last,
      firstDate: DateTime.now().add(Duration(minutes: -10)),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked.length == 2) {
      _pickedDates = picked;
      _fromDateController.text = _getDateString(_pickedDates.first);
      _toDateController.text = _getDateString(_pickedDates.last);
    } else {
      _pickedDates = null;
    }
    setState(() {});
  }

  String _getTimeString(DateTime date) {
    Intl.defaultLocale = "en_US";
    var timeFormatter = DateFormat('hh:mm aa');
    return timeFormatter.format(date);
  }

  String _getDateString(DateTime date) {
    Intl.defaultLocale = "en_US";
    var timeFormatter = DateFormat('dd/MM/yyyy');
    return timeFormatter.format(date);
  }

  Future<void> _addNewAlarm() async {
    _showLoadingDialog();

    if (_descriptionController.text.trim().isEmpty ||
        _alarmingTimes.isEmpty ||
        _daysScheduledController.text.trim().isEmpty ||
        _pickedDates.isEmpty) {
      Navigator.pop(context);
      _showErrorDialog();
      return;
    }

    Alarm newAlarm = Alarm(
      notificationID: _randomNotificationNumber(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      daysScheduled: int.parse(_daysScheduledController.text.trim()),
      alarmingTimes: _alarmingTimes,
      alarmingStartDate: DateTime(_pickedDates.first.year, _pickedDates.first.month, _pickedDates.first.day),
      alarmingEndDate: DateTime(_pickedDates.last.year, _pickedDates.last.month, _pickedDates.last.day),
    );

    newAlarm = await AlarmProvider.instance.insert(newAlarm);

    await NotificationManager.instance.setAlarmNotifications(newAlarm);

    Navigator.pop(context);

    _showDoneDialog();
  }

  int _randomNotificationNumber() {
    final random = new Random();
    return 100000 + random.nextInt(999999 - 100000);
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

  void _showErrorDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              "Empty Fields",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "There're fields must be NOT empty.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Ok",
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

  void _showDoneDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              "Alarm Added",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Successfully, alarm has been added.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  "Back",
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
