import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'error.dart';
import 'home.dart';
import 'my_ride.dart';
import 'orders.dart';
import 'profile.dart';
import 'wallet.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    DashboardController controller = Get.put(DashboardController());

    return controller.obx(
      (state) {
        return Scaffold(
          body: TabBarView(
            controller: controller.tabCtrl,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Home(),
              Wallet(),
              Orders(),
              Profile()
            ]
          ),
          bottomNavigationBar: SafeArea(
            child: Material(
              child: TabBar(
                controller: controller.tabCtrl,
                indicator: BoxDecoration(
                  color: Colors.transparent
                ),
                labelColor: colorPrimary,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400
                ),
                unselectedLabelColor: Color(0xFF858585),
                tabs: [
                  Tab(
                    icon: Icon(TablerIcons.home),
                    text: 'Home'
                  ),
                  Tab(
                    icon: Icon(TablerIcons.wallet),
                    text: 'Wallet'
                  ),
                  Tab(
                    icon: Icon(TablerIcons.history),
                    text: 'Orders'
                  ),
                  Tab(
                    icon: Icon(TablerIcons.user),
                    text: 'Account'
                  ),
                ]
              )
            ),
          )
        );
      },
      onLoading: Material(
        child: buildLoader()
      ),
      onError: (err) => ErrorScreen()
    );
  }
}

class DashboardController extends GetxController with GetSingleTickerProviderStateMixin, StateMixin {
  late TabController tabCtrl;
  HttpService http = Get.find();
  AuthManager authManager = Get.find();

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 4, vsync: this, animationDuration: Duration.zero);
  }

  @override
  void onReady() async {
    await init();
  }

  Future init() async {
    change(null, status: RxStatus.loading());
    final result = await http.getUserProfile();
    if (result is String) {
      change(result, status: RxStatus.error());
    } else {
      authManager.saveUser(result);
      change(null, status: RxStatus.success());
    }
  }
}

