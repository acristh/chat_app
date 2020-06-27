import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage);

  final Function({String text, File imageFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final _messageTextController = TextEditingController();
  bool _isComposing = false;
  final picker = ImagePicker();
  File _image;

  Future<File> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  void _resetTextField() {
    _messageTextController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.photo_camera,
              size: 24.0,
            ),
            onPressed: () async {
              final image = await _getImage();
              setState(
                () {
                  _image = image;
                },
              );
              if (_image == null) {
                return;
              }
              widget.sendMessage(imageFile: _image);
            },
          ),
          Expanded(
            child: TextField(
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma Mensagem"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _resetTextField();
              },
              controller: _messageTextController,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              size: 24.0,
            ),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _messageTextController.text);
                    _resetTextField();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
