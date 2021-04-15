import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
import 'package:e_commerce_app_flutter/components/pet_short_detail_card.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/OrderedPet.dart';
import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/screens/my_orders/components/pet_review_dialog.dart';
import 'package:e_commerce_app_flutter/screens/pet_details/pet_details_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/ordered_pets_stream.dart';
import 'package:e_commerce_app_flutter/services/database/pet_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final OrderedPetsStream orderedPetsStream = OrderedPetsStream();

  @override
  void initState() {
    super.initState();
    orderedPetsStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    orderedPetsStream.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Text(
                    "Your Orders",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.75,
                    child: buildOrderedPetsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    orderedPetsStream.reload();
    return Future<void>.value();
  }

  Widget buildOrderedPetsList() {
    return StreamBuilder<List<String>>(
      stream: orderedPetsStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final orderedPetsIds = snapshot.data;
          if (orderedPetsIds.length == 0) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_bag.svg",
                secondaryMessage: "Order something to show here",
              ),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: orderedPetsIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<OrderedPet>(
                future: UserDatabaseHelper().getOrderedPetFromId(orderedPetsIds[index]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final orderedPet = snapshot.data;
                    return buildOrderedPetItem(orderedPet);
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    Logger().e(error);
                  }
                  return Icon(
                    Icons.error,
                    size: 60,
                    color: kTextColor,
                  );
                },
              );
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        return Center(
          child: NothingToShowContainer(
            iconPath: "assets/icons/network_error.svg",
            primaryMessage: "Something went wrong",
            secondaryMessage: "Unable to connect to Database",
          ),
        );
      },
    );
  }

  Widget buildOrderedPetItem(OrderedPet orderedPet) {
    return FutureBuilder<Pet>(
      future: PetDatabaseHelper().getPetWithID(orderedPet.petUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final pet = snapshot.data;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kTextColor.withOpacity(0.12),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: "Ordered on:  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: orderedPet.orderDate,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Subject:  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: orderedPet.subject,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Description:  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: orderedPet.description,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Date Time Meeting:  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: orderedPet.dateTimeMeet,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Adoption Type:  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: orderedPet.adoptionType.toString().replaceAll("AdoptionType.", ""),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Status:  ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: orderedPet.status.toString().replaceAll("StatusType.", ""),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: kTextColor.withOpacity(0.15),
                      ),
                    ),
                  ),
                  child: PetShortDetailCard(
                    petId: pet.id,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailsScreen(
                            pet: pet,
                          ),
                        ),
                      ).then((_) async {
                        await refreshPage();
                      });
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: FlatButton(
                    onPressed: () async {
                      String currentUserUid = AuthentificationService().currentUser.uid;
                      Review prevReview;
                      try {
                        prevReview = await PetDatabaseHelper().getPetReviewWithID(pet.id, currentUserUid);
                      } on FirebaseException catch (e) {
                        Logger().w("Firebase Exception: $e");
                      } catch (e) {
                        Logger().w("Unknown Exception: $e");
                      } finally {
                        if (prevReview == null) {
                          prevReview = Review(
                            currentUserUid,
                            reviewerUid: currentUserUid,
                          );
                        }
                      }

                      final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return PetReviewDialog(
                            review: prevReview,
                          );
                        },
                      );
                      if (result is Review) {
                        bool reviewAdded = false;
                        String snackbarMessage;
                        try {
                          reviewAdded = await PetDatabaseHelper().addPetReview(pet.id, result);
                          if (reviewAdded == true) {
                            snackbarMessage = "Pet review added successfully";
                          } else {
                            throw "Coulnd't add pet review due to unknown reason";
                          }
                        } on FirebaseException catch (e) {
                          Logger().w("Firebase Exception: $e");
                          snackbarMessage = e.toString();
                        } catch (e) {
                          Logger().w("Unknown Exception: $e");
                          snackbarMessage = e.toString();
                        } finally {
                          Logger().i(snackbarMessage);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(snackbarMessage),
                            ),
                          );
                        }
                      }
                      await refreshPage();
                    },
                    child: Text(
                      "Give Pet Review",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final error = snapshot.error.toString();
          Logger().e(error);
        }
        return Icon(
          Icons.error,
          size: 60,
          color: kTextColor,
        );
      },
    );
  }
}
