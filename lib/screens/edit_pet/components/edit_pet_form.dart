import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:e_commerce_app_flutter/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:e_commerce_app_flutter/models/Pet.dart';
import 'package:e_commerce_app_flutter/screens/edit_pet/provider_models/PetDetails.dart';
import 'package:e_commerce_app_flutter/services/database/pet_database_helper.dart';
import 'package:e_commerce_app_flutter/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:e_commerce_app_flutter/services/local_files_access/local_files_access_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tflite/tflite.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class EditPetForm extends StatefulWidget {
  final Pet pet;
  EditPetForm({
    Key key,
    this.pet,
  }) : super(key: key);

  @override
  _EditPetFormState createState() => _EditPetFormState();
}

class _EditPetFormState extends State<EditPetForm> {
  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _describePetFormKey = GlobalKey<FormState>();
  final _tagStateKey = GlobalKey<TagsState>();

  final TextEditingController nameFieldController = TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
  final TextEditingController weightFieldController = TextEditingController();
  final TextEditingController ageFieldController = TextEditingController();
  final TextEditingController highlightsFieldController = TextEditingController();
  final TextEditingController descriptionFieldController = TextEditingController();

  bool newPet = true;
  Pet pet;
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void dispose() {
    nameFieldController.dispose();
    variantFieldController.dispose();
    weightFieldController.dispose();
    ageFieldController.dispose();
    highlightsFieldController.dispose();
    descriptionFieldController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.pet == null) {
      pet = Pet(null);
      newPet = true;
    } else {
      pet = widget.pet;
      newPet = false;
      final petDetails = Provider.of<PetDetails>(context, listen: false);
      petDetails.initialSelectedImages = widget.pet.images.map((e) => CustomImage(imgType: ImageType.network, path: e)).toList();
      petDetails.initialPetType = pet.petType;
      petDetails.initSearchTags = pet.searchTags ?? [];
    }
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        buildBasicDetailsTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildDescribePetTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildUploadImagesTile(context),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildpredictImage(context),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildPetAnimalTypeDropdown(),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildPetSearchTagsTile(),
        SizedBox(height: getProportionateScreenHeight(80)),
        DefaultButton(
            text: "Save Pet",
            press: () {
              savePetButtonCallback(context);
            }),
        SizedBox(height: getProportionateScreenHeight(10)),
      ],
    );
    if (newPet == false) {
      nameFieldController.text = pet.name;
      variantFieldController.text = pet.variant;
      weightFieldController.text = pet.weight.toString();
      ageFieldController.text = pet.age.toString();
      highlightsFieldController.text = pet.highlights;
      descriptionFieldController.text = pet.description;
    }
    return column;
  }

  Widget buildPetSearchTags() {
    return Consumer<PetDetails>(
      builder: (context, petDetails, child) {
        return Tags(
          key: _tagStateKey,
          horizontalScroll: true,
          heightHorizontalScroll: getProportionateScreenHeight(80),
          textField: TagsTextField(
            lowerCase: true,
            width: getProportionateScreenWidth(120),
            constraintSuggestion: true,
            hintText: "Add search tag",
            keyboardType: TextInputType.name,
            onSubmitted: (String str) {
              petDetails.addSearchTag(str.toLowerCase());
            },
          ),
          itemCount: petDetails.searchTags.length,
          itemBuilder: (index) {
            final item = petDetails.searchTags[index];
            return ItemTags(
              index: index,
              title: item,
              active: true,
              activeColor: kPrimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              alignment: MainAxisAlignment.spaceBetween,
              removeButton: ItemTagsRemoveButton(
                backgroundColor: Colors.white,
                color: kTextColor,
                onRemoved: () {
                  petDetails.removeSearchTag(index: index);
                  return true;
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget buildBasicDetailsTile(BuildContext context) {
    return Form(
      key: _basicDetailsFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Basic Details",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.shop,
        ),
        childrenPadding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildNameField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildVariantField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildWeightField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildAgeField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPetTypeDropdown(),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  bool validateBasicDetailsForm() {
    if (_basicDetailsFormKey.currentState.validate()) {
      _basicDetailsFormKey.currentState.save();
      pet.name = nameFieldController.text;
      pet.variant = variantFieldController.text;
      pet.weight = double.tryParse(weightFieldController.text);
      pet.age = int.tryParse(ageFieldController.text);
      pet.seller = FirebaseAuth.instance.currentUser.displayName;
      return true;
    }
    return false;
  }

  Widget buildDescribePetTile(BuildContext context) {
    return Form(
      key: _describePetFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Describe Your Pet",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.description,
        ),
        childrenPadding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildHighlightsField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDescriptionField(),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  bool validateDescribePetForm() {
    if (_describePetFormKey.currentState.validate()) {
      _describePetFormKey.currentState.save();
      pet.highlights = highlightsFieldController.text;
      pet.description = descriptionFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildPetAnimalTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Consumer<PetDetails>(
        builder: (context, petDetails, child) {
          return DropdownButton(
            value: petDetails.petType,
            items: PetType.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      EnumToString.convertToString(e),
                    ),
                  ),
                )
                .toList(),
            hint: Text(
              "Chose Pet Type",
            ),
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
            ),
            onChanged: (value) {
              petDetails.petType = value;
            },
            elevation: 0,
            underline: SizedBox(width: 0, height: 0),
          );
        },
      ),
    );
  }

  Widget buildPetTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Consumer<PetDetails>(
        builder: (context, petDetails, child) {
          return DropdownButton(
            value: petDetails.sexType,
            items: SexType.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      EnumToString.convertToString(e),
                    ),
                  ),
                )
                .toList(),
            hint: Text(
              "Choose Sex Type",
            ),
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
            ),
            onChanged: (value) {
              petDetails.sexType = value;
            },
            elevation: 0,
            underline: SizedBox(width: 0, height: 0),
          );
        },
      ),
    );
  }

  Widget buildPetSearchTagsTile() {
    return ExpansionTile(
      title: Text(
        "Search Tags",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.check_circle_sharp),
      childrenPadding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Text("Your pet info will be searched for this Tags"),
        SizedBox(height: getProportionateScreenHeight(15)),
        buildPetSearchTags(),
      ],
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Upload Images",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.image),
      childrenPadding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
              icon: Icon(
                Icons.add_a_photo,
              ),
              color: kTextColor,
              onPressed: () {
                addImageButtonCallback();
              }),
        ),
        Consumer<PetDetails>(
          builder: (context, petDetails, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  petDetails.selectedImages.length,
                  (index) => SizedBox(
                    width: 80,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(index: index);
                        },
                        child: petDetails.selectedImages[index].imgType == ImageType.local
                            ? Image.memory(File(petDetails.selectedImages[index].path).readAsBytesSync())
                            : Image.network(petDetails.selectedImages[index].path),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildNameField() {
    return TextFormField(
      controller: nameFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g.,  Ray",
        labelText: "Pet Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (nameFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildVariantField() {
    return TextFormField(
      controller: variantFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., breed",
        labelText: "breed",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (variantFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildWeightField() {
    return TextFormField(
      controller: weightFieldController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: "e.g.,  15",
        labelText: "Pet Weight",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (weightFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildAgeField() {
    return TextFormField(
      controller: ageFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "e.g.,  3",
        labelText: "Pet Age in Months",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (ageFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildHighlightsField() {
    return TextFormField(
      controller: highlightsFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: "e.g., more description",
        labelText: "Highlights",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (highlightsFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      controller: descriptionFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: "e.g., This a cat or dog",
        labelText: "Description",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (descriptionFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Future<void> savePetButtonCallback(BuildContext context) async {
    if (validateBasicDetailsForm() == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errors in Basic Details Form"),
        ),
      );
      return;
    }
    if (validateDescribePetForm() == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errors in Describe Pet adopt Form"),
        ),
      );
      return;
    }
    final petDetails = Provider.of<PetDetails>(context, listen: false);
    if (petDetails.selectedImages.length < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload at least One Image of Pet"),
        ),
      );
      return;
    }
    if (petDetails.petType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select Pet breed"),
        ),
      );
      return;
    }
    if (petDetails.searchTags.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Add at least 3 search tags"),
        ),
      );
      return;
    }
    String petId;
    String snackbarMessage;
    try {
      pet.petType = petDetails.petType;
      pet.sexType = petDetails.sexType;
      pet.searchTags = petDetails.searchTags;
      final petUploadFuture = newPet ? PetDatabaseHelper().addUsersPet(pet) : PetDatabaseHelper().updateUsersPet(pet);
      petUploadFuture.then((value) {
        petId = value;
      });
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            petUploadFuture,
            message: Text(newPet ? "Uploading Pet" : "Updating Pet"),
          );
        },
      );
      if (petId != null) {
        snackbarMessage = "Pet Info updated successfully";
      } else {
        throw "Couldn't update pet info due to some unknown issue";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    if (petId == null) return;
    bool allImagesUploaded = false;
    try {
      allImagesUploaded = await uploadPetImages(petId);
      if (allImagesUploaded == true) {
        snackbarMessage = "All images uploaded successfully";
      } else {
        throw "Some images couldn't be uploaded, please try again";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = "Something went wrong";
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    List<String> downloadUrls = petDetails.selectedImages.map((e) => e.imgType == ImageType.network ? e.path : null).toList();
    bool petFinalizeUpdate = false;
    try {
      final updatePetFuture = PetDatabaseHelper().updatePetsImages(petId, downloadUrls);
      petFinalizeUpdate = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            updatePetFuture,
            message: Text("Saving Your Adopt"),
          );
        },
      );
      if (petFinalizeUpdate == true) {
        snackbarMessage = "Pet uploaded successfully";
      } else {
        throw "Couldn't upload pet properly, please retry";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    Navigator.pop(context);
  }

  Future<bool> uploadPetImages(String petId) async {
    bool allImagesUpdated = true;
    final petDetails = Provider.of<PetDetails>(context, listen: false);
    for (int i = 0; i < petDetails.selectedImages.length; i++) {
      if (petDetails.selectedImages[i].imgType == ImageType.local) {
        print("Image being uploaded: " + petDetails.selectedImages[i].path);
        String downloadUrl;
        try {
          final imgUploadFuture = FirestoreFilesAccess()
              .uploadFileToPath(File(petDetails.selectedImages[i].path), PetDatabaseHelper().getPathForPetImage(petId, i));
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return FutureProgressDialog(
                imgUploadFuture,
                message: Text("Uploading Images ${i + 1}/${petDetails.selectedImages.length}"),
              );
            },
          );
        } on FirebaseException catch (e) {
          Logger().w("Firebase Exception: $e");
        } catch (e) {
          Logger().w("Firebase Exception: $e");
        } finally {
          if (downloadUrl != null) {
            petDetails.selectedImages[i] = CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            allImagesUpdated = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Couldn't upload image ${i + 1} due to some issue"),
              ),
            );
          }
        }
      }
    }
    return allImagesUpdated;
  }

  Future<void> addImageButtonCallback({int index}) async {
    final petDetails = Provider.of<PetDetails>(context, listen: false);
    if (index == null && petDetails.selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max 3 images can be uploaded")));
      return;
    }
    String path;
    String snackbarMessage;
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      Logger().i("Local File Handling Exception: $e");
      snackbarMessage = e.toString();
    } catch (e) {
      Logger().i("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      if (snackbarMessage != null) {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
    if (path == null) {
      return;
    }
    if (index == null) {
      petDetails.addNewSelectedImage(CustomImage(imgType: ImageType.local, path: path));
    } else {
      petDetails.setSelectedImageAtIndex(CustomImage(imgType: ImageType.local, path: path), index);
    }
  }

  Widget buildpredictImage(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "predict your pet",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.image),
      childrenPadding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
              icon: Icon(
                Icons.add_a_photo,
              ),
              color: kTextColor,
              onPressed: () {
                pickImage();
              }),
        ),
        _loading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    _image == null ? Container() : Image.file(_image),
                    SizedBox(
                      height: 20,
                    ),
                    _outputs != null
                        ? Text(
                            " result : ${_outputs[0]['label'].substring(2)} \n accuracy : ${(_outputs[0]['confidence'] * 100).toStringAsFixed(1)} %",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              background: Paint()..color = Colors.white,
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
      ],
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
      print(output[0]["confidence"].toStringAsFixed(3));
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }
}
