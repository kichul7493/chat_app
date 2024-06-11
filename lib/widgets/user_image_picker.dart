import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onImagePick});

  final void Function(File pickedImage) onImagePick;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    final imagePicker = ImagePicker();

    final imageFile = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (imageFile == null) {
      return;
    }

    widget.onImagePick(File(imageFile.path));

    setState(() {
      _pickedImage = File(imageFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          label: const Text('Add Image'),
          icon: const Icon(Icons.image),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        )
      ],
    );
  }
}
