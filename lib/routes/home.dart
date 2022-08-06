// packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:realestate/controller/bottom_nav.dart';
import 'package:realestate/routes/map.dart';

// routes
import 'apartment_list.dart';

class Home extends GetView<BottomNavController> {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.willPopAction,
      child: Obx(
        () => Scaffold(
          appBar: AppBar(),
          body: IndexedStack(
            index: controller.pageIndex.value,
            children: [
              Container(child: Text('home')),
              Container(child: Text('map')),
              Container(child: Text('list')),
              Container(child: Text('my')),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: controller.pageIndex.value,
              onTap: controller.changeBottomNav,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: 'map'),
                BottomNavigationBarItem(icon: Icon(Icons.share), label: 'list'),
                BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'my'),
              ]),
        ),
      ),
    );
  }
}
