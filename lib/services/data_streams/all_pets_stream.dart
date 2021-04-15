import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/pet_database_helper.dart';

class AllPetsStream extends DataStream<List<Pet>> {
  @override
  void reload() {
    final allPetsFuture = PetDatabaseHelper().allPetsList;
    allPetsFuture.then((favPets) {
      addData(favPets);
    }).catchError((e) {
      addError(e);
    });
  }
}
