import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class CategoryPetsScreen extends StatelessWidget {
  final PetType petType;

  const CategoryPetsScreen({
    Key key,
    @required this.petType,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        petType: petType,
      ),
    );
  }
}
