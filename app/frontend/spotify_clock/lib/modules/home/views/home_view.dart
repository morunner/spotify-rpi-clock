import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:spotify_clock/modules/home/controllers/home_controller.dart';
import 'package:spotify_clock/components/mainappbar_component.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  static const double toolbarHeight = 1.4 * kToolbarHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF9E2B25),
        appBar: MainAppBar(
            title: 'Wecker',
            toolbarHeight: toolbarHeight,
            navigationChildren: [
              Text('Bearbeiten',
                  style: TextStyle(
                      fontSize: 0.17 * toolbarHeight,
                      fontWeight: FontWeight.w100,
                      color: Color(0xFFE29837))),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Color(0xFFE29837),
                  size: 0.25 * toolbarHeight,
                ),
                onPressed: () {
                  TimeOfDay now = TimeOfDay.now();
                  Get.find<HomeController>().addClockEntry(
                      now, 'I guess I just feel like', 'John Mayer', true);
                },
              )
            ]),
        body: Column(children: [
          Expanded(
              child: Obx(
            () => ListView.builder(
              itemCount: controller.itemCount.value,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(
                      controller.clockEntries.value[index].time!
                          .format(context),
                      style: TextStyle(
                        color: Color(0xFF213438),
                        fontSize: 0.3 * toolbarHeight,
                      )),
                  subtitle: Text(
                      ' ${controller.clockEntries.value[index].songTitle!} (${controller.clockEntries.value[index].artist!}',
                      style: TextStyle(
                        color: Color(0xFF213438),
                        fontSize: 0.15 * toolbarHeight,
                      )),
                  trailing: IconButton(
                      icon: Icon(Icons.delete_outline_outlined,
                          color: Color(0xFF9E2B25)),
                      onPressed: () {
                        controller.removeCLockEntry(index);
                      }),
                  tileColor: Color(0xFFD5D5D5),
                );
              }),
            ),
          ))
        ]));
  }
}
