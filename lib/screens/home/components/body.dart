import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/screens/cart/cart_screen.dart';
import 'package:e_commerce_app_flutter/screens/category_pets/category_pets_screen.dart';
import 'package:e_commerce_app_flutter/screens/pet_details/pet_details_screen.dart';
import 'package:e_commerce_app_flutter/screens/search_result/search_result_screen.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/data_streams/all_pets_stream.dart';
import 'package:e_commerce_app_flutter/services/data_streams/favourite_pets_stream.dart';
import 'package:e_commerce_app_flutter/services/database/pet_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../utils.dart';
import '../components/home_header.dart';
import 'pet_type_box.dart';
import 'pets_section.dart';

const String ICON_KEY = "icon";
const String TITLE_KEY = "title";
const String PET_TYPE_KEY = "pet_type";

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final petCategories = <Map>[
    <String, dynamic>{
      ICON_KEY: "assets/icons/cat.svg",
      TITLE_KEY: "Cats",
      PET_TYPE_KEY: PetType.Cats,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/dogs.svg",
      TITLE_KEY: "Dogs",
      PET_TYPE_KEY: PetType.Dogs,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/birds.svg",
      TITLE_KEY: "Birds",
      PET_TYPE_KEY: PetType.Birds,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Hamsters.svg",
      TITLE_KEY: "Hamsters",
      PET_TYPE_KEY: PetType.Hamsters,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Turtles.svg",
      TITLE_KEY: "Turtles",
      PET_TYPE_KEY: PetType.Turtles,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/Others.svg",
      TITLE_KEY: "Others",
      PET_TYPE_KEY: PetType.Others,
    },
  ];

  final FavouritePetsStream favouritePetsStream = FavouritePetsStream();
  final AllPetsStream allPetsStream = AllPetsStream();

  @override
  void initState() {
    super.initState();
    favouritePetsStream.init();
    allPetsStream.init();
  }

  @override
  void dispose() {
    favouritePetsStream.dispose();
    allPetsStream.dispose();
    super.dispose();
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: getProportionateScreenHeight(15)),
                HomeHeader(
                  onSearchSubmitted: (value) async {
                    final query = value.toString();
                    if (query.length <= 0) return;
                    List<Pet> searchedPets;
                    try {
                      searchedPets = await PetDatabaseHelper().searchInPets(query.toLowerCase());
                      if (searchedPets != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              searchQuery: query,
                              searchResultPets: searchedPets,
                              searchIn: "All Pets",
                            ),
                          ),
                        );
                        await refreshPage();
                      } else {
                        throw "Couldn't perform search due to some unknown reason";
                      }
                    } catch (e) {
                      final error = e.toString();
                      Logger().e(error);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$error"),
                        ),
                      );
                    }
                  },
                  onCartButtonPressed: () async {
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
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(),
                      ),
                    );
                    await refreshPage();
                  },
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: [
                        ...List.generate(
                          petCategories.length,
                          (index) {
                            return PeTypeBox(
                              icon: petCategories[index][ICON_KEY],
                              title: petCategories[index][TITLE_KEY],
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryPetsScreen(
                                      petType: petCategories[index][PET_TYPE_KEY],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.5,
                  child: PetsSection(
                    sectionTitle: "Pets You Like",
                    petsStreamController: favouritePetsStream,
                    emptyListMessage: "Add Pet to Favourites",
                    onPetCardTapped: onPetCardTapped,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.8,
                  child: PetsSection(
                    sectionTitle: "Explore All Pets",
                    petsStreamController: allPetsStream,
                    emptyListMessage: "Looks like all Stores are closed",
                    onPetCardTapped: onPetCardTapped,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    favouritePetsStream.reload();
    allPetsStream.reload();
    return Future<void>.value();
  }

  void onPetCardTapped(Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailsScreen(pet: pet),
      ),
    ).then((_) async {
      await refreshPage();
    });
  }
}
