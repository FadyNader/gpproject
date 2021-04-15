import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class CartItemsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final allPetsFuture = UserDatabaseHelper().allCartItemsList;
    allPetsFuture.then((favPets) {
      addData(favPets);
    }).catchError((e) {
      addError(e);
    });
  }
}
