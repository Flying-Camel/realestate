

import 'dart:io';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CameraController extends GetxController {
  late File _image;
  final picker = ImagePicker();
  final albumName = "임장";

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      GallerySaver.saveImage(_image.path, albumName: albumName);
      // Save image to map marker
    } else {
      Fluttertoast.showToast(
          msg: "선택된 사진이 없습니다",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xff6E6E6E),
          fontSize: 15,
          toastLength: Toast.LENGTH_SHORT);
    }
    update();
  }
}