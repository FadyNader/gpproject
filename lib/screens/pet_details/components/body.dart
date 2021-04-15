import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/screens/pet_details/components/pet_actions_section.dart';
import 'package:e_commerce_app_flutter/screens/pet_details/components/pet_images.dart';
import 'package:e_commerce_app_flutter/services/database/pet_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'pet_review_section.dart';

class Body extends StatelessWidget {
  final String petId;

  const Body({
    Key key,
    @required this.petId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(screenPadding)),
          child: FutureBuilder<Pet>(
            future: PetDatabaseHelper().getPetWithID(petId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final pet = snapshot.data;
                return Column(
                  children: [
                    PetImages(pet: pet),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    PetActionsSection(pet: pet),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    PetReviewsSection(pet: pet),
                    SizedBox(height: getProportionateScreenHeight(100)),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                final error = snapshot.error.toString();
                Logger().e(error);
              }
              return Center(
                child: Icon(
                  Icons.error,
                  color: kTextColor,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
