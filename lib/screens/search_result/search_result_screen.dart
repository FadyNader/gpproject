import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  final String searchIn;
  final List<Pet> searchResultPets;

  const SearchResultScreen({
    Key key,
    @required this.searchQuery,
    @required this.searchResultPets,
    @required this.searchIn,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Body(
        searchQuery: searchQuery,
        searchResultPets: searchResultPets,
        searchIn: searchIn,
      ),
    );
  }
}
