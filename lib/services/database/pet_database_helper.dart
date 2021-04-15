import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/models/Review.dart';
import 'package:e_commerce_app_flutter/services/authentification/authentification_service.dart';
import 'package:enum_to_string/enum_to_string.dart';

class PetDatabaseHelper {
  static const String PETS_COLLECTION_NAME = "pets";
  static const String REVIEWS_COLLECTION_NAME = "reviews";

  PetDatabaseHelper._privateConstructor();
  static PetDatabaseHelper _instance = PetDatabaseHelper._privateConstructor();
  factory PetDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore;
  }

  Future<List<Pet>> searchInPets(String query, {PetType petType}) async {
    Query queryRef;
    if (petType == null) {
      queryRef = firestore.collection(PETS_COLLECTION_NAME);
    } else {
      final petTypeStr = EnumToString.convertToString(petType);
      print(petTypeStr);
      queryRef = firestore.collection(PETS_COLLECTION_NAME).where(Pet.PET_TYPE_KEY, isEqualTo: petTypeStr);
    }

    Set pets = Set<Pet>();
    final querySearchInTags = await queryRef.where(Pet.SEARCH_TAGS_KEY, arrayContains: query).get();
    for (final doc in querySearchInTags.docs) {
      pets.add(doc.id);
    }
    final queryRefDocs = await queryRef.get();
    for (final doc in queryRefDocs.docs) {
      final pet = Pet.fromMap(doc.data(), id: doc.id);
      if (pet.name.toString().toLowerCase().contains(query) ||
          pet.description.toString().toLowerCase().contains(query) ||
          pet.highlights.toString().toLowerCase().contains(query) ||
          pet.variant.toString().toLowerCase().contains(query) ||
          pet.seller.toString().toLowerCase().contains(query)) {
        pets.add(pet);
      }
    }
    return pets.toList();
  }

  Future<bool> addPetReview(String petId, Review review) async {
    final reviewesCollectionRef = firestore.collection(PETS_COLLECTION_NAME).doc(petId).collection(REVIEWS_COLLECTION_NAME);
    final reviewDoc = reviewesCollectionRef.doc(review.reviewerUid);
    if ((await reviewDoc.get()).exists == false) {
      reviewDoc.set(review.toMap());
      return await addUsersRatingForPet(
        petId,
        review.rating,
      );
    } else {
      int oldRating = 0;
      oldRating = (await reviewDoc.get()).data()[Pet.RATING_KEY];
      reviewDoc.update(review.toUpdateMap());
      return await addUsersRatingForPet(petId, review.rating, oldRating: oldRating);
    }
  }

  Future<bool> addUsersRatingForPet(String petId, int rating, {int oldRating}) async {
    final petDocRef = firestore.collection(PETS_COLLECTION_NAME).doc(petId);
    final ratingsCount = (await petDocRef.collection(REVIEWS_COLLECTION_NAME).get()).docs.length;
    final petDoc = await petDocRef.get();
    final prevRating = petDoc.data()[Review.RATING_KEY];
    double newRating;
    if (oldRating == null) {
      newRating = (prevRating * (ratingsCount - 1) + rating) / ratingsCount;
    } else {
      newRating = (prevRating * (ratingsCount) + rating - oldRating) / ratingsCount;
    }
    final newRatingRounded = double.parse(newRating.toStringAsFixed(1));
    await petDocRef.update({Pet.RATING_KEY: newRatingRounded});
    return true;
  }

  Future<Review> getPetReviewWithID(String petId, String reviewId) async {
    final reviewesCollectionRef = firestore.collection(PETS_COLLECTION_NAME).doc(petId).collection(REVIEWS_COLLECTION_NAME);
    final reviewDoc = await reviewesCollectionRef.doc(reviewId).get();
    if (reviewDoc.exists) {
      return Review.fromMap(reviewDoc.data(), id: reviewDoc.id);
    }
    return null;
  }

  Stream<List<Review>> getAllReviewsStreamForPetId(String petId) async* {
    final reviewesQuerySnapshot =
        firestore.collection(PETS_COLLECTION_NAME).doc(petId).collection(REVIEWS_COLLECTION_NAME).get().asStream();
    await for (final querySnapshot in reviewesQuerySnapshot) {
      List<Review> reviews = List<Review>();
      for (final reviewDoc in querySnapshot.docs) {
        Review review = Review.fromMap(reviewDoc.data(), id: reviewDoc.id);
        reviews.add(review);
      }
      yield reviews;
    }
  }

  Future<Pet> getPetWithID(String petId) async {
    final docSnapshot = await firestore.collection(PETS_COLLECTION_NAME).doc(petId).get();

    if (docSnapshot.exists) {
      return Pet.fromMap(docSnapshot.data(), id: docSnapshot.id);
    }
    return null;
  }

  Future<String> addUsersPet(Pet pet) async {
    String uid = AuthentificationService().currentUser.uid;
    final petMap = pet.toMap();
    pet.owner = uid;
    final petsCollectionReference = firestore.collection(PETS_COLLECTION_NAME);
    final docRef = await petsCollectionReference.add(pet.toMap());
    await docRef.update({
      Pet.SEARCH_TAGS_KEY: FieldValue.arrayUnion([petMap[Pet.PET_TYPE_KEY].toString().toLowerCase()])
    });
    return docRef.id;
  }

  Future<bool> deleteUserPet(String petId) async {
    final petsCollectionReference = firestore.collection(PETS_COLLECTION_NAME);
    await petsCollectionReference.doc(petId).delete();
    return true;
  }

  Future<String> updateUsersPet(Pet pet) async {
    final petMap = pet.toUpdateMap();
    final petsCollectionReference = firestore.collection(PETS_COLLECTION_NAME);
    final docRef = petsCollectionReference.doc(pet.id);
    await docRef.update(petMap);
    if (pet.petType != null) {
      await docRef.update({
        Pet.SEARCH_TAGS_KEY: FieldValue.arrayUnion([petMap[Pet.PET_TYPE_KEY].toString().toLowerCase()])
      });
    }
    return docRef.id;
  }

  Future<List<String>> getCategoryPetsList(PetType petType) async {
    final petsCollectionReference = firestore.collection(PETS_COLLECTION_NAME);
    final queryResult =
        await petsCollectionReference.where(Pet.PET_TYPE_KEY, isEqualTo: EnumToString.convertToString(petType)).get();
    List petsId = List<String>();
    for (final pet in queryResult.docs) {
      final id = pet.id;
      petsId.add(id);
    }
    return petsId;
  }

  Future<List<String>> get usersPetsList async {
    String uid = AuthentificationService().currentUser.uid;
    final petsCollectionReference = firestore.collection(PETS_COLLECTION_NAME);
    final querySnapshot = await petsCollectionReference.where(Pet.OWNER_KEY, isEqualTo: uid).get();
    List usersPets = List<String>();
    querySnapshot.docs.forEach((doc) {
      usersPets.add(doc.id);
    });
    return usersPets;
  }

  Future<List<Pet>> get allPetsList async {
    final petsDocs = await firestore.collection(PETS_COLLECTION_NAME).get();
    List pets = List<Pet>();
    for (final doc in petsDocs.docs) {
      Pet pet = Pet.fromMap(doc.data(), id: doc.id);
      pets.add(pet);
    }
    return pets;
  }

  Future<bool> updatePetsImages(String petId, List<String> imgUrl) async {
    final Pet updatePet = Pet(null, images: imgUrl);
    final docRef = firestore.collection(PETS_COLLECTION_NAME).doc(petId);
    await docRef.update(updatePet.toUpdateMap());
    return true;
  }

  String getPathForPetImage(String id, int index) {
    String path = "pets/images/$id";
    return path + "_$index";
  }
}
