import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ImagePickerExample extends StatefulWidget {
  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Picker Example')),
      body: SingleChildScrollView(
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
            ],
          ),
        ),
      ),
    );
  }
}
