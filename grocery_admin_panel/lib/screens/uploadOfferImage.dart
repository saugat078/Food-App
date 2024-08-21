import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/controllers/MenuControllerr.dart';
import 'package:grocery_admin_panel/inner_screens/all_products.dart';
import 'package:grocery_admin_panel/responsive.dart';
import 'package:grocery_admin_panel/widgets/side_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class OfferImageUpload extends StatefulWidget {
  @override
  _OfferImageUploadState createState() => _OfferImageUploadState();
}

class _OfferImageUploadState extends State<OfferImageUpload> {
  Uint8List? _imageData;
  String? _imageExtension;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final extension = pickedFile.name.split('.').last;

      setState(() {
        _imageData = bytes;
        _imageExtension = extension;
      });
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_imageData == null || _imageExtension == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.$_imageExtension';
      Reference ref = _storage.ref().child('offerImages/$fileName');
      await ref.putData(_imageData!);
      String downloadURL = await ref.getDownloadURL();
      await _firestore.collection('offers').add({'imageUrl': downloadURL});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!')),
      );
      _navigateToAllProductsScreen();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteImage(String documentId, String imageUrl) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('offers').doc(documentId).delete();
      await _storage.refFromURL(imageUrl).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAllProductsScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AllProductsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuControllerr>().getEditProductscaffoldKey,
      appBar: AppBar(title: Text('Upload Offer Images')),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context))
            const Expanded(
              child: SideMenu(),
            ),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_isLoading)
                      CircularProgressIndicator(),
                    if (_imageData != null)
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                        ),
                        child: Image.memory(
                          _imageData!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    if (_imageData == null)
                      Text('No image selected.'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Pick Image'),
                    ),
                    if (_imageData != null)
                      ElevatedButton(
                        onPressed: _uploadImageToFirebase,
                        child: Text('Save to Firebase'),
                      ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('offers').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                            return ListTile(
                              title: Image.network(data['imageUrl'], height: 100),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteImage(doc.id, data['imageUrl']),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}