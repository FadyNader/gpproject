import 'package:flutter/material.dart';

class PetActions extends ChangeNotifier {
  bool _petFavStatus = false;

  bool get petFavStatus {
    return _petFavStatus;
  }

  set initialPetFavStatus(bool status) {
    _petFavStatus = status;
  }

  set petFavStatus(bool status) {
    _petFavStatus = status;
    notifyListeners();
  }

  void switchPetFavStatus() {
    _petFavStatus = !_petFavStatus;
    notifyListeners();
  }
}
