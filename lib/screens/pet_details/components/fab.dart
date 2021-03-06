import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../utils.dart';

class AddToCartFAB extends StatelessWidget {
  const AddToCartFAB({
    Key key,
    @required this.pet,
  }) : super(key: key);

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return (this.pet.owner != FirebaseAuth.instance.currentUser.uid)
        ? FloatingActionButton.extended(
            onPressed: () async {
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
              bool addedSuccessfully = false;
              String snackbarMessage;
              try {
                addedSuccessfully = await UserDatabaseHelper().addPetToCart(pet.id);
                if (addedSuccessfully == true) {
                  snackbarMessage = "Pet added successfully";
                } else {
                  throw "Couldn't add pet due to unknown reason";
                }
              } on FirebaseException catch (e) {
                Logger().w("Firebase Exception: $e");
                snackbarMessage = "Something went wrong";
              } catch (e) {
                Logger().w("Unknown Exception: $e");
                snackbarMessage = "Something went wrong";
              } finally {
                Logger().i(snackbarMessage);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(snackbarMessage),
                  ),
                );
              }
            },
            label: Text(
              "Add to list",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            icon: Icon(
              Icons.shopping_cart,
            ),
          )
        : Container();
  }
}
