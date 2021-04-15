import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class FavouritePetsStream extends DataStream<List<Pet>> {
  @override
  void reload() {
    final favPetsFuture = UserDatabaseHelper().usersFavouritePetsList;
    favPetsFuture.then((favPets) {
      addData(favPets.cast<Pet>());
    }).catchError((e) {
      addError(e);
    });
  }
}
