import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker picker = ImagePicker();
  var image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Center(
        child: Column(
          children: [
            FilledButton(
              onPressed: () async {
                image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  log(image.path.toString());
                  setState(() {});
                } else {
                  log('No Image');
                }
              },
              child: const Text('Gallery'),
            ),
            FilledButton(
              onPressed: () async {
                image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  log(image!.path.toString());
                  setState(() {});
                } else {
                  log('No Image');
                }
              },
              child: const Text('Camera'),
            ),

            (image != null) ? Image.file(File(image!.path)) : Container(),
          ],
        ),
      ),
    );
  }
}
