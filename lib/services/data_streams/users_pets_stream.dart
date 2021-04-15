import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/pet_database_helper.dart';

class UsersPetsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final usersPetsFuture = PetDatabaseHelper().usersPetsList;
    usersPetsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
