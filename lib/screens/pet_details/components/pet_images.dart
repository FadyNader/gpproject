import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/screens/pet_details/provider_models/PetImageSwiper.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom_image_updated/pinch_zoom_image_updated.dart';
import 'package:provider/provider.dart';
import 'package:swipedetector/swipedetector.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class PetImages extends StatelessWidget {
  const PetImages({
    Key key,
    @required this.pet,
  }) : super(key: key);

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PetImageSwiper(),
      child: Consumer<PetImageSwiper>(
        builder: (context, petImagesSwiper, child) {
          return Column(
            children: [
              SwipeDetector(
                onSwipeLeft: () {
                  petImagesSwiper.currentImageIndex++;
                  petImagesSwiper.currentImageIndex %= pet.images.length;
                },
                onSwipeRight: () {
                  petImagesSwiper.currentImageIndex--;
                  petImagesSwiper.currentImageIndex += pet.images.length;
                  petImagesSwiper.currentImageIndex %= pet.images.length;
                },
                child: PinchZoomImage(
                  image: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: SizedBox(
                      height: SizeConfig.screenHeight * 0.35,
                      width: SizeConfig.screenWidth * 0.75,
                      child: Image.network(
                        pet.images[petImagesSwiper.currentImageIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    pet.images.length,
                    (index) => buildSmallPreview(petImagesSwiper, index: index),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSmallPreview(PetImageSwiper petImagesSwiper, {@required int index}) {
    return GestureDetector(
      onTap: () {
        petImagesSwiper.currentImageIndex = index;
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(8)),
        padding: EdgeInsets.all(getProportionateScreenHeight(8)),
        height: getProportionateScreenWidth(48),
        width: getProportionateScreenWidth(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: petImagesSwiper.currentImageIndex == index ? kPrimaryColor : Colors.transparent),
        ),
        child: Image.network(pet.images[index]),
      ),
    );
  }
}
