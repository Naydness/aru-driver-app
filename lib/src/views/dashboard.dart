import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
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
import 'earnings.dart';
import 'profile.dart';
import 'trips.dart';

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
              Trips(),
              Earnings(),
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
  late StreamSubscription<ably.Message> subscription;

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 4, vsync: this, animationDuration: Duration.zero);
  }

  @override
  void onReady() async {
    await init();

    final ably.Realtime realtime = ably.Realtime(options: ably.ClientOptions(
      // key: ablyKey
      key: 'RbvVsQ.q4uDvQ:JlsQNqGVMJ9Ojikn5a-sINinYqRBsWOdRQD8pFv0HJQ'
    ));

    final userId = authManager.user['_id'];
    print('user ID: $userId');
    ably.RealtimeChannel channel = realtime.channels.get('driver:$userId');
    print('Channel: $channel');
    subscription = channel.subscribe().listen((ably.Message message) {
      print('Ably Event (Driver): ${message.name}');
      final payload = message.data as Map;
      debugPrint('Payload: $payload', wrapWidth: 2000);
      switch (message.name) {
        case 'ride-request':
          showRequest(payload);
          break;

        case 'ride-timeout':
        case 'ride-cancelled':
          _closeRequest();
          break;

        default:
      }
    });
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

  void showRequest(Map r) {
    final reqId = r['rideRequestId'];
    final req = r['rideRequest'];
    final fullname = '${req['rider']['firstName']} ${req['rider']['lastName']}';

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
                        Text('${req['estimatedDistance'].toStringAsFixed(2)} Km - ${req['estimatedDuration'].toStringAsFixed(0)} mins')
                      ],
                    ),
                  ),
                  const SizedBox(width: 8,),
                  Text('\$${req['estimatedPrice'].toStringAsFixed(2)}', style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorBlack2
                  ))
                ],
              ),
              const SizedBox(height: 16,),
              RouteSummary(
                pickup: req['pickupLocation']['address']['full'], 
                destination: req['dropoffLocation']['address']['full'], 
                stops: req['stops']
              ),
              const SizedBox(height: 16,),
              Text('Addons', style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorBlack2
              )),
              const SizedBox(height: 4,),
              Wrap(
                children: (req['addons'] as List).map((a) {
                  return Text('$a ');
                }).toList()
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
                  Text('${req['specialInstructions']}'),
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
                            Text(fullname, style: TextStyle(
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
                          rejectRequest(reqId);
                        }).red.build()
                      ),
                      const SizedBox(width: 24,),
                      Expanded(
                        child: Buttons.text('Accept', onPressed: () {
                          acceptRequest(reqId);
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

  void _closeRequest() {
    Get.until((route) => route.settings.name == '/');
  }

  void acceptRequest(String reqId) async {
    final result = await http.acceptRideRequest(reqId);
    _closeRequest();
  }

  void rejectRequest(String reqId) async {
    final result = await http.rejectRideRequest(reqId);
    _closeRequest();
  }
}

