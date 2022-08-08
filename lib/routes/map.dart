import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

import 'package:realestate/controller/camera.dart';

class MapPage extends GetView<CameraController> {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      body: NaverMap(
        locationButtonEnable: true,
        initLocationTrackingMode: LocationTrackingMode.Follow),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          controller.getImage();
        },
        label: Text('사진'),
        icon: Icon(Icons.camera_enhance),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      )
    );
    // return const NaverMap(
      // locationButtonEnable: true,
      // initLocationTrackingMode: LocationTrackingMode.Follow,);

  }
}
