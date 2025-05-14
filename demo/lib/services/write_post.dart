import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:demo/components/post_status.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/user_provider.dart';
// import 'package:libphonenumber/libphonenumber.dart';

/// A page that allows users to create and submit a new post.
class WritePostPage extends StatefulWidget {
  /// The latitude coordinate for the post's location.
  final double latitude;

  /// The longitude coordinate for the post's location.
  final double longitude;

  /// Creates a [WritePostPage] with the specified [latitude] and [longitude].
  const WritePostPage({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  XFile? _selectedVideo;
  String? _selectedCategory;
  String? _selectedSize;
  bool _locationAttached = false;

  /// Uploads a file to Firebase Storage under the specified [folderName].
  ///
  /// Returns the download URL of the uploaded file or `null` if the upload fails.
  Future<String?> _uploadFile(XFile file, String folderName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('$folderName/${file.name}');
      final uploadTask = storageRef.putFile(File(file.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload $folderName: ${e.toString()}'))
      );
      return null;
    }
  }

  /// Opens the image picker to select an image from the gallery.
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo selected: ${image.name}'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select photo: ${e.toString()}'))
      );
    }
  }

  /// Opens the video picker to select a video from the gallery.
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video selected: ${video.name}'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select video: ${e.toString()}'))
      );
    }
  }

  /// Validates and sends the post data to Firestore.
  ///
  /// Displays error messages if required fields are missing or if the submission fails.
  void _sendData() async {
    if (_textController.text.isEmpty || _numberController.text.isEmpty || _selectedCategory == null || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields: your post content, phone number, and animal category'))
      );
      return; // Stops the function from proceeding if any field is empty
    }

    // if (!(await isValidPhoneNumber(_numberController.text))) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please enter a valid phone number'))
    //   );
    //   return;
    // }

    try {
      // String? imageUrl;
      // String? videoUrl;

      // if (_selectedImage != null) {
      //   imageUrl = await _uploadFile(_selectedImage!, 'images');
      // }

      // if (_selectedVideo != null) {
      //   videoUrl = await _uploadFile(_selectedVideo!, 'videos');
      // }

      final postData = {
        'latitude': widget.latitude,
        'longitude': widget.longitude,
        'content': _textController.text,
        'phone': _numberController.text,
        'address': _addressController.text,
        'category': _selectedCategory, 
        'subCategory': _selectedSize,
        'status': PostStatus.rideNeeded.toDatabaseValue(), // Ride needed, In transfer, At hospital
        'date': FieldValue.serverTimestamp(),
        'userId': context.read<UserProvider>().user?.uid ?? 'anonymous',
        // 'imageUrl': imageUrl,
        // 'videoUrl': videoUrl,
      };

      final collectionRef = FirebaseFirestore.instance.collection('post');
      await collectionRef.add(postData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post sent successfully!'))
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send post: ${e.toString()}'))
      );
    }
  }

  // Future<bool> isValidPhoneNumber(String phoneNumber) async {
  //   try {
  //     bool? isValid = await PhoneNumberUtil.isValidPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       isoCode: 'US', 
  //     );
  //     return isValid ?? false; 
  //   } catch (e) {
  //     print('Failed to validate phone number: $e');
  //     return false;  
  //   }
  // }

  /// Attaches the current location to the post.
  void _attachLocation() {
    setState(() {
      _locationAttached = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location attached: (${widget.latitude}, ${widget.longitude})'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Post', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendData,
            tooltip: 'Send post data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                height: 2 * MediaQuery.of(context).size.height / 7,
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'Your Post...',
                    // border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  expands: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: TextField(
                controller: _numberController,
                maxLines: 1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Leave a phone number',
                  prefixIcon: Icon(Icons.phone), // Adding a leading icon for phone
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none, // Keeping the border side none as commented
                    borderRadius: BorderRadius.circular(8), // Optional: Adding rounded corners
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: TextField(
                controller: _addressController,
                maxLines: 1,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Leave an address',
                  prefixIcon: Icon(Icons.my_location), // Adding a leading icon for phone
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none, // Keeping the border side none as commented
                    borderRadius: BorderRadius.circular(8), // Optional: Adding rounded corners
                  ),
                ),
              ),
            ),
            // Padding(padding: const EdgeInsets.fromLTRB(16, 2, 16, 2), 
            //   child: ListTile(
            //     leading: Icon(Icons.my_location),
            //     title: Text('Attach Location', style: TextStyle(fontSize: 15)),
            //     onTap: _attachLocation,
            //     subtitle: _locationAttached ? Text('Latitude: ${widget.latitude}, Longitude: ${widget.longitude}') : null,
            //   ),
            // ),
            // Padding(padding: const EdgeInsets.fromLTRB(16, 2, 16, 2), 
            //   child: ListTile(
            //     leading: Icon(Icons.photo_library),
            //     title: Text('Attach Photos', style: TextStyle(fontSize: 15)),
            //     onTap: _pickImage, 
            //   ),
            // ),
            // Padding(padding: const EdgeInsets.fromLTRB(16, 2, 16, 2), 
            //   child: ListTile(
            //     leading: Icon(Icons.videocam),
            //     title: Text('Attach Videos', style: TextStyle(fontSize: 15)),
            //     onTap: _pickVideo,
            //   ),
            // ),
            // Padding(padding: const EdgeInsets.fromLTRB(16, 2, 16, 2), 
            //   child: ListTile(
            //     leading: Icon(Icons.science),
            //     title: Text('Auto-identify the species', style: TextStyle(fontSize: 15)),
            //     onTap: () {}, 
            //   ),
            // ),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: Text('Select Animal Category'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: <String>["Mammal", "Bat", "Bird", "Waterfowl", "Reptiles", "Amphibians", "Raptor", "Marine Mammals"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _selectedSize,
              hint: Text('Select Animal Size'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSize = newValue;
                });
              },
              items: <String>["Large", "Medium", "Small", "Baby"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
