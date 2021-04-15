import 'package:e_commerce_app_flutter/components/top_rounded_container.dart';
import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/screens/pet_details/components/pet_description.dart';
import 'package:e_commerce_app_flutter/screens/pet_details/provider_models/PetActions.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../size_config.dart';
import '../../../utils.dart';

class PetActionsSection extends StatelessWidget {
  final Pet pet;

  const PetActionsSection({
    Key key,
    @required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        Stack(
          children: [
            TopRoundedContainer(
              child: PetDescription(pet: pet),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: buildFavouriteButton(),
            ),
          ],
        ),
      ],
    );
    UserDatabaseHelper().isPetFavourite(pet.id).then(
      (value) {
        final petActions = Provider.of<PetActions>(context, listen: false);
        petActions.petFavStatus = value;
      },
    ).catchError(
      (e) {
        Logger().w("$e");
      },
    );
    return column;
  }

  Widget buildFavouriteButton() {
    return Consumer<PetActions>(
      builder: (context, petDetails, child) {
        return InkWell(
          onTap: () async {
            bool allowed = AuthentificationService().currentUserVerified;
            if (!allowed) {
              final reverify = await showConfirmationDialog(
                  context, "You haven't verified your email address. This action is only allowed for verified users.",
                  positiveResponse: "Resend verification email", negativeResponse: "Go back");
              if (reverify) {
                final future = AuthentificationService().sendVerificationEmailToCurrentUser();
                await showDialog(
                  context: context,
                  builder: (context) {
                    return FutureProgressDialog(
                      future,
                      message: Text("Resending verification email"),
                    );
                  },
                );
              }
              return;
            }
            bool success = false;
            final future = UserDatabaseHelper().switchPetFavouriteStatus(pet.id, !petDetails.petFavStatus).then(
              (status) {
                success = status;
              },
            ).catchError(
              (e) {
                Logger().e(e.toString());
                success = false;
              },
            );
            await showDialog(
              context: context,
              builder: (context) {
                return FutureProgressDialog(
                  future,
                  message: Text(
                    petDetails.petFavStatus ? "Removing from Favourites" : "Adding to Favourites",
                  ),
                );
              },
            );
            if (success) {
              petDetails.switchPetFavStatus();
            }
          },
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(8)),
            decoration: BoxDecoration(
              color: petDetails.petFavStatus ? Color(0xFFFFE6E6) : Color(0xFFF5F6F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(8)),
              child: Icon(
                Icons.favorite,
                color: petDetails.petFavStatus ? Color(0xFFFF4848) : Color(0xFFD8DEE4),
              ),
            ),
          ),
        );
      },
    );
  }
}
