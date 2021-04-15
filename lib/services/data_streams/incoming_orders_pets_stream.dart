import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class IncomingOrdersPetsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final incomingOrdersPetsFuture = UserDatabaseHelper().incomingOrdersPetsList;
    incomingOrdersPetsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
