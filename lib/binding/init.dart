
import 'package:get/get.dart';
import 'package:realestate/controller/bottom_nav.dart';

class InitBinding extends Bindings {

  @override
  void dependencies() {
    Get.put(BottomNavController(), permanent: true);
  }
}