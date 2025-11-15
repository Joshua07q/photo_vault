import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryProvider with ChangeNotifier {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  List<File> get images => _images;

  Future<void> pickImages() async {
    try {
      final picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        _images.addAll(picked.map((x) => File(x.path)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void clear() {
    _images.clear();
    notifyListeners();
  }
}
