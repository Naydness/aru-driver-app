import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/route_summary.dart';
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
                    icon: Icon(TablerIcons.truck_delivery),
                    text: 'Trips'
                  ),
                  Tab(
                    icon: Icon(TablerIcons.currency_dollar),
                    text: 'Earnings'
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
    Get.bottomSheet(
      isDismissible: false,
      Container(
        padding: EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        // height: MediaQuery.of(Get.context!).size.height * .8,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/delivery_van_2.png'),
                  const SizedBox(width: 24,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ride Request'),
                        const SizedBox(height: 8),
                        Text('2.3 miles - 12 mins')
                      ],
                    ),
                  ),
                  const SizedBox(width: 8,),
                  Text('\$70', style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorBlack2
                  ))
                ],
              ),
              const SizedBox(height: 16,),
              RouteSummary(
                pickup: '12, James Oxford Street', 
                destination: '24, David Street', 
                stops: []
              ),
              const SizedBox(height: 16,),
              Text('Addons', style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorBlack2
              )),
              const SizedBox(height: 4,),
              Wrap(
                children: [
                  Text('Moving Item, '),
                  Text('Fragile Item'),
                ],
              ),
              const SizedBox(height: 12,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Special Instructions', style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorBlack2
                  )),
                  Text('Customer is a disable'),
                  const SizedBox(height: 16,),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: Image.asset('assets/images/user.png'),
                        /*child: Text(authManager.userInitials, style: TextStyle(
                          color: colorBlack1,
                          fontWeight: FontWeight.w600,
                          fontSize: 20
                        )),*/
                      ),
                      const SizedBox(width: 20,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('John Doe', style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorBlack2
                            )),
                            const SizedBox(height: 4,),
                            Text('Customer', style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF858585)
                            ))
                          ],
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 16,),
                  Row(
                    children: [
                      Expanded(
                        child: Buttons.text('Reject', onPressed: () {

                        }).red.build()
                      ),
                      const SizedBox(width: 24,),
                      Expanded(
                        child: Buttons.text('Accept', onPressed: () {

                        }).green.build()
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
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

