import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:admin_app/database/product.dart';
import 'package:admin_app/database/category.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  ProductService productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();
  TextEditingController productAvailable = TextEditingController();
  TextEditingController quatityController = TextEditingController();
  final priceController = TextEditingController();
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String? _currentCategory;
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  File? _image1;
  File? _image2;
  File? _image3;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items = [];
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        var data = categories[i].data() as Map<String, dynamic>?;
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(data?['category'] ?? ''),
                value: data?['category']));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add product",
          style: TextStyle(color: black),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: grey.withValues(alpha: 0.5), width: 2.5)),
                                onPressed: () {
                                  _showSelectionDialog(context, 1);
                                },
                                child: _displayChild1()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: grey.withValues(alpha: 0.5), width: 2.5)),
                                onPressed: () {
                                  _showSelectionDialog(context, 2);
                                },
                                child: _displayChild2()),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: grey.withValues(alpha: 0.5), width: 2.5)),
                              onPressed: () {
                                _showSelectionDialog(context, 3);
                              },
                              child: _displayChild3(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: productNameController,
                        decoration: InputDecoration(hintText: 'Product name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You must enter the product name';
                          } else if (value.length > 15) {
                            return 'Product name cant have more than 15 letters';
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: productDescriptionController,
                        decoration:
                            InputDecoration(hintText: 'Product description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You must enter the product description';
                          } else if (value.length > 50) {
                            return 'Product name cant have more than 50 letters';
                          }
                          return null;
                        },
                      ),
                    ),

//              select category
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Category: ',
                            style: TextStyle(color: red),
                          ),
                        ),
                        DropdownButton(
                          items: categoriesDropDown,
                          onChanged: changeSelectedCategory,
                          value: _currentCategory,
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: productAvailable,
                        decoration:
                            InputDecoration(hintText: 'Availability: Y/N'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You must enter Y(yes) or N(no)';
                          } else if (value.length > 1) {
                            return 'You must enter Y or N';
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Price',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'You must enter the product price.';
                          }
                          return null;
                        },
                      ),
                    ),

                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: white,
                      ),
                      child: Text('Add product'),
                      onPressed: () {
                        validateAndUpload();
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _showSelectionDialog(BuildContext context, int n) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("From where do you want to take the photo?"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text("Gallery"),
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          _selectImage(File(image.path), n);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text("Camera"),
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          _selectImage(File(image.path), n);
                        }
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    print(data.length);
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      if (categories.isNotEmpty) {
        var catData = categories[0].data() as Map<String, dynamic>?;
        _currentCategory = catData?['category'];
      }
    });
  }

  changeSelectedCategory(String? selectedCategory) {
    setState(() => _currentCategory = selectedCategory);
  }

  void _selectImage(File image, int imageNumber) {
    switch (imageNumber) {
      case 1:
        setState(() => _image1 = image);
        break;
      case 2:
        setState(() => _image2 = image);
        break;
      case 3:
        setState(() => _image3 = image);
        break;
    }
  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image1!,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild2() {
    if (_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image2!,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  Widget _displayChild3() {
    if (_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        _image3!,
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }

  void validateAndUpload() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      if (_image1 != null && _image2 != null && _image3 != null) {
        if (productAvailable.text.isNotEmpty) {
          String imageUrl1;
          String imageUrl2;
          String imageUrl3;

          final _storage = FirebaseStorage.instance;

          final String picture1 =
              "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          UploadTask task1 = _storage.ref().child(picture1).putFile(_image1!);

          final String picture2 =
              "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          UploadTask task2 = _storage.ref().child(picture2).putFile(_image2!);

          final String picture3 =
              "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          UploadTask task3 = _storage.ref().child(picture3).putFile(_image3!);

          TaskSnapshot snapshot1 = await task1.then((snapshot) => snapshot);
          TaskSnapshot snapshot2 = await task2.then((snapshot) => snapshot);

          task3.then((snapshot3) async {
            imageUrl1 = await snapshot1.ref.getDownloadURL();
            imageUrl2 = await snapshot2.ref.getDownloadURL();
            imageUrl3 = await snapshot3.ref.getDownloadURL();
            List<String> imageList = [imageUrl1, imageUrl2, imageUrl3];

            productService.uploadProduct({
              "name": productNameController.text,
              "description": productDescriptionController.text,
              "price": double.parse(priceController.text),
              "images": imageList,
              "available": productAvailable.text.trim().toUpperCase(),
              "category": _currentCategory
            });
            _formKey.currentState?.reset();
            setState(() => isLoading = false);
//            Fluttertoast.showToast(msg: 'Product added');
            Navigator.pop(context);
          });
        } else {
          setState(() => isLoading = false);

//          Fluttertoast.showToast(msg: 'select atleast one size');
        }
      } else {
        setState(() => isLoading = false);

//        Fluttertoast.showToast(msg: 'all the images must be provided');
      }
    }
  }
}
