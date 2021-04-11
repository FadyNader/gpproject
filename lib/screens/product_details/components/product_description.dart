import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:flutter/material.dart';

import 'expandable_text.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription({
    Key key,
    @required this.product,
  }) : super(key: key);

  final Product product;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                  text: product.name,
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: "\n${product.variant} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: "\nWeight: ${product.weight} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: "\nAge: ${product.age} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: "\nSex: ${product.sexType.toString().replaceAll("SexType.", "")} ",
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
              content: product.highlights,
            ),
            const SizedBox(height: 16),
            ExpandableText(
              title: "Description",
              content: product.description,
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
                    text: "${product.seller ?? "Unknown name"}",
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
