import 'dart:io';

import 'package:chat_app/components/chat_message.dart';
import 'package:chat_app/components/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoading;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  void _sendMessage({String text, File imageFile}) async {
    FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Não possível fazer o Login. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now(),
    };

    if (imageFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid)
          .child(
            DateTime.now().millisecondsSinceEpoch.toString(),
          )
          .putFile(imageFile);

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imageUrl"] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) {
      data["text"] = text;
    }

    await Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null
              ? "Olá, ${_currentUser.displayName}"
              : "Chat App",
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Você saiu com sucesso.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                )
              : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("messages")
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    break;
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          documents[index].data,
                          documents[index].data['uid'] == _currentUser?.uid,
                        );
                      },
                      reverse: true,
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
