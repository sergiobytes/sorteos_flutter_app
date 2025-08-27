import 'dart:io';

import 'package:image_picker/image_picker.dart';

class UploadService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> takePhoto() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 92,
    );

    if (xfile == null) return null;
    return File(xfile.path);
  }
}
