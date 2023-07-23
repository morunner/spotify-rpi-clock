import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:spotify_clock/modules/home/controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
        backgroundColor: Color(0xFF9E2B25),
        body: Column(children: [
          Expanded(
              child: Obx(
            () => ListView.builder(
              itemCount: controller.itemCount.value,
              itemBuilder: ((context, index) {
                return ListTile(
                    title: Text(controller.clockEntries.value[index].time!
                        .format(context)),
                    subtitle:
                        Text(controller.clockEntries.value[index].songTitle!),
                    trailing: GestureDetector(
                        child: const Icon(Icons.delete_outline_outlined,
                            color: Color(0xFFE29837)),
                        onTap: () {
                          controller.removeCLockEntry(index);
                        }));
              }),
            ),
          ))
        ]));
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const toolbarHeight = 1.3 * kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: toolbarHeight,
      title: Padding(
          padding: EdgeInsets.only(
              top: 0.03 * toolbarHeight, bottom: 0.0 * toolbarHeight),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Bearbeiten',
                  style: TextStyle(
                      fontSize: 0.17 * toolbarHeight,
                      fontWeight: FontWeight.w100,
                      color: Color(0xFFE29837))),
              Icon(Icons.add,
                  color: Color(0xFFE29837), size: 0.2 * toolbarHeight),
            ]),
            SizedBox(height: 0.15 * toolbarHeight),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Wecker',
                    style: TextStyle(
                        fontSize: 0.32 * toolbarHeight,
                        fontWeight: FontWeight.bold)))
          ])),
      backgroundColor: Color(0xFF213438),
      foregroundColor: Color(0xFFFFF8F0),
    );
  }
}
