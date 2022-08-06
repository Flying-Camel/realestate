
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realestate/controller/bottom_nav.dart';

class InitBinding extends Bindings {

  @override
  void dependencies() {
    Get.put(BottomNavController(), permanent: true);
    getPermission();
  }

  getPermission() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      Permission.contacts.request();
    }
  }
}