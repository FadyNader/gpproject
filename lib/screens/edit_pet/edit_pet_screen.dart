import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/screens/edit_pet/provider_models/PetDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/body.dart';

class EditPetScreen extends StatelessWidget {
  final Pet petToEdit;

  const EditPetScreen({Key key, this.petToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PetDetails(),
      child: Scaffold(
        appBar: AppBar(),
        body: Body(
          petToEdit: petToEdit,
        ),
      ),
    );
  }
}
