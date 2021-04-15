import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/Address.dart';
import 'package:e_commerce_app_flutter/models/CartItem.dart';
import 'package:e_commerce_app_flutter/models/OrderedPet.dart';
import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:e_commerce_app_flutter/services/database/pet_database_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserDatabaseHelper {
  static const String USERS_COLLECTION_NAME = "users";
  static const String ADDRESSES_COLLECTION_NAME = "addresses";
  static const String CART_COLLECTION_NAME = "cart";
  static const String ORDERED_PETS_COLLECTION_NAME = "ordered_pets";

  static const String PHONE_KEY = 'phone';
  static const String DP_KEY = "display_picture";
  static const String FAV_PETS_KEY = "favourite_pets";
  static const String FCM_TOKEN_KEY = "fcm_token";
  static const String INCOMING_ORDERS_KEY = "incoming_orders";

  UserDatabaseHelper._privateConstructor();
  static UserDatabaseHelper _instance = UserDatabaseHelper._privateConstructor();
  factory UserDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore;
  }

  Future<void> createNewUser(String uid) async {
    FirebaseMessaging messaging = FirebaseMessaging();
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).set({
      DP_KEY: null,
      PHONE_KEY: null,
      FAV_PETS_KEY: List<String>(),
      FCM_TOKEN_KEY: await messaging.getToken(),
      INCOMING_ORDERS_KEY: List(),
    });
  }

  Future<void> setUserToken(String uid) async {
    FirebaseMessaging messaging = FirebaseMessaging();
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).update({
      FCM_TOKEN_KEY: await messaging.getToken(),
    });
  }

  Future<void> removeUserToken(String uid) async {
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).update({
      FCM_TOKEN_KEY: null,
    });
  }

  Future<void> deleteCurrentUserData() async {
    final uid = AuthentificationService().currentUser.uid;
    final docRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final cartCollectionRef = docRef.collection(CART_COLLECTION_NAME);
    final addressCollectionRef = docRef.collection(ADDRESSES_COLLECTION_NAME);
    final ordersCollectionRef = docRef.collection(ORDERED_PETS_COLLECTION_NAME);

    final cartDocs = await cartCollectionRef.get();
    for (final cartDoc in cartDocs.docs) {
      await cartCollectionRef.doc(cartDoc.id).delete();
    }
    final addressesDocs = await addressCollectionRef.get();
    for (final addressDoc in addressesDocs.docs) {
      await addressCollectionRef.doc(addressDoc.id).delete();
    }
    final ordersDoc = await ordersCollectionRef.get();
    for (final orderDoc in ordersDoc.docs) {
      await ordersCollectionRef.doc(orderDoc.id).delete();
    }

    await docRef.delete();
  }

  Future<bool> isPetFavourite(String petId) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final userDocData = (await userDocSnapshot.get()).data();
    final favList = userDocData[FAV_PETS_KEY].cast<String>();
    if (favList.contains(petId)) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Pet>> get usersFavouritePetsList async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final userDocData = (await userDocSnapshot.get()).data();
    final favList = userDocData[FAV_PETS_KEY];

    List pets = List<Pet>();

    for (String petId in favList) {
      final doc = await firestore.collection(PetDatabaseHelper.PETS_COLLECTION_NAME).doc(petId).get();
      Pet pet = Pet.fromMap(doc.data(), id: doc.id);
      pets.add(pet);
    }

    return pets;
  }

  Future<bool> switchPetFavouriteStatus(String petId, bool newState) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);

    if (newState == true) {
      userDocSnapshot.update({
        FAV_PETS_KEY: FieldValue.arrayUnion([petId])
      });
    } else {
      userDocSnapshot.update({
        FAV_PETS_KEY: FieldValue.arrayRemove([petId])
      });
    }
    return true;
  }

  Future<List<String>> get addressesList async {
    String uid = AuthentificationService().currentUser.uid;
    final snapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).get();
    final addresses = List<String>();
    snapshot.docs.forEach((doc) {
      addresses.add(doc.id);
    });

    return addresses;
  }

  Future<Address> getAddressFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final doc = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).doc(id).get();
    final address = Address.fromMap(doc.data(), id: doc.id);
    return address;
  }

  Future<bool> addAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressesCollectionReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME);
    await addressesCollectionReference.add(address.toMap());
    return true;
  }

  Future<bool> deleteAddressForCurrentUser(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressDocReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).doc(id);
    await addressDocReference.delete();
    return true;
  }

  Future<bool> updateAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressDocReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ADDRESSES_COLLECTION_NAME).doc(address.id);
    await addressDocReference.update(address.toMap());
    return true;
  }

  Future<CartItem> getCartItemFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(id);
    final docSnapshot = await docRef.get();
    final cartItem = CartItem.fromMap(docSnapshot.data(), id: docSnapshot.id);
    return cartItem;
  }

  Future<bool> addPetToCart(String petId) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(petId);
    final docSnapshot = await docRef.get();
    bool alreadyPresent = docSnapshot.exists;
    if (alreadyPresent == false) {
      docRef.set(CartItem(itemCount: 1).toMap());
    } else {
      docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(1)});
    }
    return true;
  }

  Future<List<String>> emptyCart() async {
    String uid = AuthentificationService().currentUser.uid;
    final cartItems = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME).get();
    List orderedPetsUid = List<String>();
    for (final doc in cartItems.docs) {
      orderedPetsUid.add(doc.id);
      await doc.reference.delete();
    }
    return orderedPetsUid;
  }

  Future<bool> removePetFromCart(String cartItemID) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionReference = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    await cartCollectionReference.doc(cartItemID).delete();
    return true;
  }

  Future<bool> increaseCartItemCount(String cartItemID) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(cartItemID);
    docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(1)});
    return true;
  }

  Future<bool> decreaseCartItemCount(String cartItemID) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(cartItemID);
    final docSnapshot = await docRef.get();
    int currentCount = docSnapshot.data()[CartItem.ITEM_COUNT_KEY];
    if (currentCount <= 1) {
      return removePetFromCart(cartItemID);
    } else {
      docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(-1)});
    }
    return true;
  }

  Future<List<String>> get allCartItemsList async {
    String uid = AuthentificationService().currentUser.uid;
    final querySnapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(CART_COLLECTION_NAME).get();
    List itemsId = List<String>();
    for (final item in querySnapshot.docs) {
      itemsId.add(item.id);
    }
    return itemsId;
  }

  Future<List<String>> get orderedPetsList async {
    String uid = AuthentificationService().currentUser.uid;
    final orderedPetsSnapshot =
        await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ORDERED_PETS_COLLECTION_NAME).get();
    List orderedPetsId = List<String>();
    for (final doc in orderedPetsSnapshot.docs) {
      orderedPetsId.add(doc.id);
    }
    return orderedPetsId;
  }

  Future<List<String>> get incomingOrdersPetsList async {
    String uid = AuthentificationService().currentUser.uid;
    final orderedPetsSnapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    List orderedPetsId = List<String>.from(orderedPetsSnapshot.data()["incoming_orders"]);
    return orderedPetsId;
  }

  Future<bool> addToMyOrders(List<OrderedPet> orders) async {
    String uid = AuthentificationService().currentUser.uid;
    final orderedPetsCollectionRef =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ORDERED_PETS_COLLECTION_NAME);
    for (final order in orders) {
      await orderedPetsCollectionRef.add(order.toMap());
    }
    return true;
  }

  Future<OrderedPet> getOrderedPetFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final doc = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(ORDERED_PETS_COLLECTION_NAME).doc(id).get();
    final orderedPet = OrderedPet.fromMap(doc.data(), id: doc.id);
    return orderedPet;
  }

  Future<OrderedPet> getOrderedPetFromPath(String path) async {
    final doc = await firestore.doc(path).get();
    final orderedPet = OrderedPet.fromMap(doc.data(), id: doc.id);
    return orderedPet;
  }

  Stream<DocumentSnapshot> get currentUserDataStream {
    String uid = AuthentificationService().currentUser.uid;
    return firestore.collection(USERS_COLLECTION_NAME).doc(uid).get().asStream();
  }

  Future<bool> updatePhoneForCurrentUser(String phone) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update({PHONE_KEY: phone});
    return true;
  }

  String getPathForCurrentUserDisplayPicture() {
    final String currentUserUid = AuthentificationService().currentUser.uid;
    return "user/display_picture/$currentUserUid";
  }

  Future<bool> uploadDisplayPictureForCurrentUser(String url) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {DP_KEY: url},
    );
    return true;
  }

  Future<bool> removeDisplayPictureForCurrentUser() async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {
        DP_KEY: FieldValue.delete(),
      },
    );
    return true;
  }

  Future<String> get displayPictureForCurrentUser async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    return userDocSnapshot.data()[DP_KEY];
  }
}
