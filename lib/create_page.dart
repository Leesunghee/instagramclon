import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePage extends StatefulWidget {

  final FirebaseUser user;

  CreatePage(this.user);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  File _image;

  final textEditingController = TextEditingController();
  final picker = ImagePicker();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(onPressed: _getImage,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            final firebaseStorageRef = FirebaseStorage.instance
                .ref()
                .child('post')
                .child('${DateTime.now().millisecondsSinceEpoch}.png');

            final task = firebaseStorageRef.putFile(_image, StorageMetadata(contentType: 'image/png'));
            
            task.onComplete.then((value) {
              var downloadUrl = value.ref.getDownloadURL();

              downloadUrl.then((url) {
                var doc = Firestore.instance.collection('post').document();
                doc.setData({
                  'id': doc.documentID,
                  'photoUrl': url.toString(),
                  'contents': textEditingController.text,
                  'displayName': widget.user.displayName,
                  'userPhotoUrl': widget.user.photoUrl,
                  'email': widget.user.email
                }).then((onValue) {
                  Navigator.pop(context);
                });
              });
            });
          },
        )
      ],
    );

  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _image == null ? Text('No Image') : Image.file(_image),
          TextField(
            decoration: InputDecoration(hintText: '내용을 입력하세요'),
            controller: textEditingController,
          )
        ],
      ),
    );
  }


  Future<File> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }
}
