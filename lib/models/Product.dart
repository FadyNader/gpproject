import 'package:e_commerce_app_flutter/models/Model.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum ProductType {
  Cats,
  Dogs,
  Birds,
  Hamsters,
  Turtles,
  Others,
}

enum SexType { Male, Female }

class Product extends Model {
  static const String IMAGES_KEY = "images";
  static const String NAME_KEY = "name";
  static const String VARIANT_KEY = "variant";
  static const String WEIGHT_KEY = "weight";
  static const String AGE_KEY = "age";
  static const String SEX_TYPE_KEY = "sex_type";
  static const String RATING_KEY = "rating";
  static const String HIGHLIGHTS_KEY = "highlights";
  static const String DESCRIPTION_KEY = "description";
  static const String SELLER_KEY = "seller";
  static const String OWNER_KEY = "owner";
  static const String PRODUCT_TYPE_KEY = "product_type";
  static const String SEARCH_TAGS_KEY = "search_tags";

  List<String> images;
  String name;
  String variant;
  double weight;
  int age;
  SexType sexType;
  num rating;
  String highlights;
  String description;
  String seller;
  bool favourite;
  String owner;
  ProductType productType;
  List<String> searchTags;

  Product(
    String id, {
    this.images,
    this.name,
    this.variant,
    this.weight,
    this.age,
    this.sexType,
    this.productType,
    this.rating = 0.0,
    this.highlights,
    this.description,
    this.seller,
    this.owner,
    this.searchTags,
  }) : super(id);

  factory Product.fromMap(Map<String, dynamic> map, {String id}) {
    if (map[SEARCH_TAGS_KEY] == null) {
      map[SEARCH_TAGS_KEY] = List<String>();
    }
    return Product(
      id,
      images: map[IMAGES_KEY].cast<String>(),
      name: map[NAME_KEY],
      variant: map[VARIANT_KEY],
      weight: map[WEIGHT_KEY],
      age: map[AGE_KEY],
      sexType: EnumToString.fromString(SexType.values, map[SEX_TYPE_KEY]),
      productType: EnumToString.fromString(ProductType.values, map[PRODUCT_TYPE_KEY]),
      rating: map[RATING_KEY],
      highlights: map[HIGHLIGHTS_KEY],
      description: map[DESCRIPTION_KEY],
      seller: map[SELLER_KEY],
      owner: map[OWNER_KEY],
      searchTags: map[SEARCH_TAGS_KEY].cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      IMAGES_KEY: images,
      NAME_KEY: name,
      VARIANT_KEY: variant,
      WEIGHT_KEY: weight,
      AGE_KEY: age,
      SEX_TYPE_KEY: EnumToString.convertToString(sexType),
      PRODUCT_TYPE_KEY: EnumToString.convertToString(productType),
      RATING_KEY: rating,
      HIGHLIGHTS_KEY: highlights,
      DESCRIPTION_KEY: description,
      SELLER_KEY: seller,
      OWNER_KEY: owner,
      SEARCH_TAGS_KEY: searchTags,
    };

    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (images != null) map[IMAGES_KEY] = images;
    if (name != null) map[NAME_KEY] = name;
    if (variant != null) map[VARIANT_KEY] = variant;
    if (weight != null) map[WEIGHT_KEY] = weight;
    if (age != null) map[AGE_KEY] = age;
    if (sexType != null) map[SEX_TYPE_KEY] = EnumToString.convertToString(sexType);
    if (rating != null) map[RATING_KEY] = rating;
    if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
    if (description != null) map[DESCRIPTION_KEY] = description;
    if (seller != null) map[SELLER_KEY] = seller;
    if (productType != null) map[PRODUCT_TYPE_KEY] = EnumToString.convertToString(productType);
    if (owner != null) map[OWNER_KEY] = owner;
    if (searchTags != null) map[SEARCH_TAGS_KEY] = searchTags;

    return map;
  }
}
