import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:flutter/material.dart';

import 'expandable_text.dart';

class PetDescription extends StatelessWidget {
  const PetDescription({
    Key key,
    @required this.pet,
  }) : super(key: key);

  final Pet pet;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                  text: pet.name,
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: "\n${pet.variant} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: "\nWeight: ${pet.weight} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: "\nAge: ${pet.age} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: "\nSex: ${pet.sexType.toString().replaceAll("SexType.", "")} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ]),
            ),
            const SizedBox(height: 16),
            ExpandableText(
              title: "Highlights",
              content: pet.highlights,
            ),
            const SizedBox(height: 16),
            ExpandableText(
              title: "Description",
              content: pet.description,
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: "showed by ",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "${pet.seller ?? "Unknown name"}",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
