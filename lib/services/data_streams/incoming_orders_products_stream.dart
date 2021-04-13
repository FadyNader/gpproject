import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class IncomingOrdersProductsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final incomingOrdersProductsFuture = UserDatabaseHelper().incomingOrdersProductsList;
    incomingOrdersProductsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
