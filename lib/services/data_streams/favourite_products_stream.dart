import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/services/data_streams/data_stream.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';

class FavouriteProductsStream extends DataStream<List<Product>> {
  @override
  void reload() {
    final favProductsFuture = UserDatabaseHelper().usersFavouriteProductsList;
    favProductsFuture.then((favProducts) {
      addData(favProducts.cast<Product>());
    }).catchError((e) {
      addError(e);
    });
  }
}
