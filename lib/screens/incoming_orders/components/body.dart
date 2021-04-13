import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/nothingtoshow_container.dart';
import 'package:e_commerce_app_flutter/components/product_short_detail_card.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/services/data_streams/incoming_orders_products_stream.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final IncomingOrdersProductsStream incomingOrdersProductsStream = IncomingOrdersProductsStream();

  @override
  void initState() {
    super.initState();
    incomingOrdersProductsStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    incomingOrdersProductsStream.dispose();
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
                    "Incoming Orders",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.75,
                    child: buildOrderedProductsList(),
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
    incomingOrdersProductsStream.reload();
    return Future<void>.value();
  }

  Widget buildOrderedProductsList() {
    return StreamBuilder<List<String>>(
      stream: incomingOrdersProductsStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data);
          final orderedProductsPaths = snapshot.data;
          if (orderedProductsPaths.length == 0) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_bag.svg",
                secondaryMessage: "Order something to show here",
              ),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: orderedProductsPaths.length,
            itemBuilder: (context, index) {
              return FutureBuilder<OrderedProduct>(
                future: UserDatabaseHelper().getOrderedProductFromPath(orderedProductsPaths[index]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final orderedProduct = snapshot.data;
                    return buildOrderedProductItem(orderedProduct, orderedProductsPaths[index]);
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

  Widget buildOrderedProductItem(OrderedProduct orderedProduct, String docPath) {
    return FutureBuilder<Product>(
      future: ProductDatabaseHelper().getProductWithID(orderedProduct.productUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final product = snapshot.data;
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
                              text: orderedProduct.orderDate,
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
                              text: orderedProduct.subject,
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
                              text: orderedProduct.description,
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
                              text: orderedProduct.dateTimeMeet,
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
                              text: orderedProduct.adoptionType.toString().replaceAll("AdoptionType.", ""),
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
                              text: orderedProduct.status.toString().replaceAll("StatusType.", ""),
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
                  child: ProductShortDetailCard(
                    productId: product.id,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productId: product.id,
                          ),
                        ),
                      ).then((_) async {
                        await refreshPage();
                      });
                    },
                  ),
                ),
                if (orderedProduct.status == StatusType.Ordered)
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
                    child: Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .doc(docPath)
                                  .update({"status": EnumToString.convertToString(StatusType.Accepted)});
                              await refreshPage();
                            },
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .doc(docPath)
                                  .update({"status": EnumToString.convertToString(StatusType.Rejected)});
                              await refreshPage();
                            },
                            child: Text(
                              "Reject",
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
