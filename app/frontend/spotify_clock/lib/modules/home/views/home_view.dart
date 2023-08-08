import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:spotify_clock/modules/home/controllers/home_controller.dart';
import 'package:spotify_clock/components/mainappbar_component.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  static const double toolbarHeight = 1.4 * kToolbarHeight;
  final panelController = PanelController();

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
                icon: Obx(() => controller.isPanelOpen.value
                    ? Icon(Icons.close,
                        color: Color(0xFF9E2B25), size: 0.25 * toolbarHeight)
                    : Icon(Icons.add,
                        color: Color(0xFFE29837), size: 0.25 * toolbarHeight)),
                onPressed: () {
                  if (controller.isPanelOpen.value) {
                    panelController.close();
                  } else {
                    panelController.open();
                  }
                },
              ),
            ]),
        body: SlidingUpPanel(
            controller: panelController,
            onPanelOpened: () => controller.setPanelState(true),
            onPanelClosed: () => controller.setPanelState(false),
            backdropEnabled: true,
            defaultPanelState: PanelState.CLOSED,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height,
            panel: Center(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  panelController.close();
                },
              ),
            ),
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
            ])));
  }
}
