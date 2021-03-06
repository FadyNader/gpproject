import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class OrderedPetsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final orderedPetsFuture = UserDatabaseHelper().orderedPetsList;
    orderedPetsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
