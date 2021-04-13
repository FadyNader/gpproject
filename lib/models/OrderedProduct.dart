import 'package:enum_to_string/enum_to_string.dart';

import 'Model.dart';

enum StatusType { Ordered, Accepted, Rejected }
enum AdoptionType { Full, Temporary }

class OrderedProduct extends Model {
  static const String PRODUCT_UID_KEY = "product_uid";
  static const String ORDER_DATE_KEY = "order_date";
  static const String STATUS_KEY = "status";
  static const String SUBJECT_KEY = "subject";
  static const String DESCRIPTION_KEY = "description";
  static const String DATE_TIME_MEET_KEY = "date_time_meet";
  static const String ADOPTION_TYPE_KEY = "adoption_type";

  String productUid;
  String orderDate;
  StatusType status;
  String subject;
  String description;
  String dateTimeMeet;
  AdoptionType adoptionType;

  OrderedProduct(
    String id, {
    this.productUid,
    this.orderDate,
    this.status,
    this.subject,
    this.description,
    this.dateTimeMeet,
    this.adoptionType,
  }) : super(id);

  factory OrderedProduct.fromMap(Map<String, dynamic> map, {String id}) {
    return OrderedProduct(
      id,
      productUid: map[PRODUCT_UID_KEY],
      orderDate: map[ORDER_DATE_KEY],
      status: EnumToString.fromString(StatusType.values, map[STATUS_KEY]),
      subject: map[SUBJECT_KEY],
      description: map[DESCRIPTION_KEY],
      dateTimeMeet: map[DATE_TIME_MEET_KEY],
      adoptionType: EnumToString.fromString(AdoptionType.values, map[ADOPTION_TYPE_KEY]),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      PRODUCT_UID_KEY: productUid,
      ORDER_DATE_KEY: orderDate,
      STATUS_KEY: EnumToString.convertToString(status),
      SUBJECT_KEY: subject,
      DESCRIPTION_KEY: description,
      DATE_TIME_MEET_KEY: dateTimeMeet,
      ADOPTION_TYPE_KEY: EnumToString.convertToString(adoptionType),
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (productUid != null) map[PRODUCT_UID_KEY] = productUid;
    if (orderDate != null) map[ORDER_DATE_KEY] = orderDate;
    if (status != null) map[STATUS_KEY] = EnumToString.convertToString(status);
    if (subject != null) map[SUBJECT_KEY] = subject;
    if (description != null) map[DESCRIPTION_KEY] = description;
    if (dateTimeMeet != null) map[DATE_TIME_MEET_KEY] = dateTimeMeet;
    if (adoptionType != null) map[ADOPTION_TYPE_KEY] = EnumToString.convertToString(adoptionType);
    return map;
  }
}
