import 'dart:async';
import 'dart:convert';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:aru/src/components/address_picker.dart';
import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_multi_select.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/components/custom_dropdown.dart';
import 'package:aru/src/components/map.dart';
import 'package:aru/src/components/route_summary.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/location_handler.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:aru/src/views/home.dart';
import 'package:aru/src/views/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:text_scroll/text_scroll.dart';

import 'dashboard.dart';

class Ride extends StatelessWidget {
  const Ride(this.request, {super.key});

  final Map request;

  @override
  Widget build(BuildContext context) {
    RideController controller = Get.put(RideController(request));

    /*print('R: $request');

    final requestCoords = {
      'pickupLocation': request['pickupLocation'],
      'dropoffLocation': request['dropoffLocation']
    };*/

    final fullname = '${request['rider']['firstName']} ${request['rider']['lastName']}}';

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .6,
            child: Obx(() {
              if (controller.showMap.value) {
                return AruMap(
                  currentLocation: controller.currentLocation, 
                  destination: controller.destination
                );
              }

              return Container();
            })
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            // snap: true,
            builder: (context, scrollController) {
              return Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)
                  )
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
                  color: Color(0xFFF6F6F6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 6,
                        width: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey
                        ),
                      ),
                      const SizedBox(height: 16,),
                      Expanded(
                        child: Obx(() {
                          if (controller.processing.value) {
                            return buildLoader();
                          }

                          return Column(
                            children: [
                              Expanded(
                                child: ListView(
                                  controller: scrollController,
                                  padding: EdgeInsets.zero,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16)
                                                ),
                                                child: Image.asset('assets/images/user.png'),
                                              ),
                                              const SizedBox(width: 16,),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(fullname, style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: colorBlack2
                                                    )),
                                                    const SizedBox(height: 8,),
                                                    Text('Customer', style: TextStyle(
                                                      color: Color(0xFF858585),
                                                      fontSize: 12
                                                    ))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16,),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 60,
                                                  child: Buttons.text(
                                                    'Call', 
                                                    prefixIcon: TablerIcons.phone_ringing,
                                                    onPressed: () {}
                                                  ).primary.build(),
                                                )
                                              ),
                                              const SizedBox(width: 24,),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 60,
                                                  child: Buttons.text(
                                                    'Chat', 
                                                    prefixIcon: TablerIcons.message,
                                                    onPressed: () {}
                                                  ).primary.outlined.build(),
                                                )
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: RouteSummary(
                                        pickup: request['pickupLocation']['address']['full'], 
                                        destination: request['dropoffLocation']['address']['full'], 
                                        stops: request['stops']
                                      )
                                    )
                                  ],
                                )
                              ),
                              const SizedBox(height: 16),
                              switch (controller.orderState.value) {
                                OrderState.rideAccepted => SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Arrived', onPressed: () {
                                    controller.arrived();
                                  })
                                  .primary
                                  .build(),
                                ),
                                OrderState.arrivedAtPickup => SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Start Trip', onPressed: () {
                                    controller.startTrip();
                                  })
                                  .primary
                                  .build(),
                                ),
                                OrderState.rideStarted => SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('End Trip', onPressed: () {
                                    controller.completeTrip();
                                    // > ride-awaiting-payment
                                  })
                                  .primary
                                  .build(),
                                ),

                                _ => Container()
                              }
                            ],
                          );
                        })
                      )
                    ],
                  )
                )
              );
            }
          )
        ],
      )
    );
  }

  Widget _buildVehicleSelector({
    String? icon, 
    String? title,
    int? capacity,
    String? desc,
    String? amount,
    bool selected = false,
    Function()? onTap
    }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: colorPrimary) : null
        ),
        child: ListTile(
          minLeadingWidth: 0,
          minVerticalPadding: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121)
          ),
          subtitleTextStyle: TextStyle(
            color: Color(0xFF858585),
            fontWeight: FontWeight.w400,
            fontSize: 10
          ),
          leadingAndTrailingTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121)
          ),
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset('assets/images/$icon', fit: BoxFit.contain),
          ),
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('$title')
          ),
          subtitle: Row(
            children: [
              Row(
                children: [
                  Icon(TablerIcons.user, size: 16),
                  const SizedBox(width: 4,),
                  Text('$capacity')
                ],
              ),
              if (desc != null) ...[
                const SizedBox(width: 8,),
                Expanded(
                  child: Row(
                    children: [
                      Icon(TablerIcons.package, size: 16,),
                      const SizedBox(width: 4,),
                      Expanded(
                        child: TextScroll(
                          desc, 
                          mode: TextScrollMode.bouncing,
                          pauseOnBounce: Duration(seconds: 2),
                          pauseBetween: Duration(seconds: 2),
                          velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                        )
                      )
                    ],
                  )
                )
              ]
            ],
          ),
          trailing: Text('$amount')
        )
      )
    );
  }

  Widget _buildPaymentOption({String? icon, String? title}) {
    return SizedBox(
      height: 60,
      child: ListTile(
        leading: Image.asset('assets/images/$icon'),
        tileColor: Colors.white,
        title: Text('$title', style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorBlack2
        )),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
      )
    );
  }
}

class RideController extends GetxController with StateMixin {
  final Completer<GoogleMapController> mapCtrl = Completer<GoogleMapController>();
  Rx<AruMapLocation> currentLocation = AruMapLocation().obs;
  Rx<AruMapLocation> destination = AruMapLocation().obs;

  late OrderType selectedOrderType;
  Rx<OrderState> orderState = OrderState.rideAccepted.obs;
  late Rx<VehicleType> selectedVehicle;
  late Rx<CarClass> selectedClass;
  final detailsFormKey = GlobalKey<FormState>();
  late List<String?> addons;
  String? instructions;
  late Rx<BookingSchedule> bookingSchedule;
  late Rx<DateTime> bookingDate;
  List<String>? bookingRecurringDays;

  final HttpService http = Get.find();
  final AuthManager authManager = Get.find();
  final DashboardController dashboardCtrl = Get.find();
  late StreamSubscription<ably.Message> subscription;

  String? activeRequestId;

  RxBool processing = false.obs;

  Map request;

  RideController(this.request);

  RxBool showMap = false.obs;
  RxMap requestCoords = RxMap();

  @override
  void onReady() {
    subscribeToRequest(request['_id']);
    destination.value.coordinates = LatLng(
      request['pickupLocation']['coordinates'][1],
      request['pickupLocation']['coordinates'][0]
    );
    destination.refresh();

    currentLocation.value.init('currLocPin', 'assets/images/pickup.png');
    destination.value.init('dstPin', 'assets/images/dropoff.png');
    dashboardCtrl.locationStream!.listen((Position? position) {
      if (position != null) {
        currentLocation.value.coordinates = LatLng(
          position.latitude,
          position.longitude
        );
        currentLocation.refresh();
      }
    });

    if (showMap.value == false) {
      showMap.value = true;
    }
  }

  @override
  void onClose() async {
    await subscription.cancel();
    super.onClose();
  }

  void subscribeToRequest(String reqId) {
    // final String ablyKey = String.fromEnvironment('ABLY_KEY');
    // final userId = authManager.user['_id'];

    final ably.Realtime realtime = ably.Realtime(options: ably.ClientOptions(
      key: 'RbvVsQ.q4uDvQ:JlsQNqGVMJ9Ojikn5a-sINinYqRBsWOdRQD8pFv0HJQ'
    ));
    ably.RealtimeChannel channel = realtime.channels.get('ride:$reqId');
    // await channel.attach();

    print('Subscribing to ${channel.name}');
    subscription = channel.subscribe().listen((ably.Message message) async {
      final payload = message.data as Map;
      print('Ride Event: ${message.name} - ${message.data}');
      switch (message.name) {
        case 'ride-cancelled':
          Get.until((route) => route.settings.name == '/');
          PopupManager.info(
            title: 'Order Cancelled',
            message: 'Order has been cancelled.'
          );
          break;

        case 'driver-arrived':
          orderState.value = OrderState.arrivedAtPickup;
          break;

        case 'ride-started':
          orderState.value = OrderState.rideStarted;
          break;

        default:
          orderState.value = OrderState.rideAccepted;
      }
    });
  }

  void arrived() async {
    processing.value = true;
    final result = await http.driverArrived(request['_id']);
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: 'Ride not marked as arrived'
      );
    } else {
      orderState.value = OrderState.arrivedAtPickup;
    }

    processing.value = false;
  }

  void startTrip() async {
    processing.value = true;
    final result = await http.startTrip(request['_id']);
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: 'Ride not marked as arrived'
      );
    } else {
      orderState.value = OrderState.rideStarted;
    }

    processing.value = false;
  }

  void stopReached() async {
    processing.value = true;
    final result = await http.stopReached(request['_id']);
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: 'Ride not marked as arrived'
      );
    } else {
      orderState.value = OrderState.stopReached;
    }

    processing.value = false;
  }

  void stopCompleted() async {
    processing.value = true;
    final result = await http.stopCompleted(request['_id']);
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: 'Ride not marked as arrived'
      );
    } else {
      orderState.value = OrderState.stopCompleted;
    }

    processing.value = false;
  }

  void skipStop() async {
    processing.value = true;
    final result = await http.skipStop(request['_id']);
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: 'Ride not marked as arrived'
      );
    } else {
      orderState.value = OrderState.stopSkipped;
    }

    processing.value = false;
  }

  void completeTrip() async {
    processing.value = true;
    final result = await http.completeTrip(request['_id']);
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: 'Ride not marked as arrived'
      );
    } else {
      // orderState.value = OrderState.awaitingPayment;
      Get.until((route) => route.settings.name == '/');
    }

    processing.value = false;
  }
}

enum OrderState {
  rideAccepted,
  arrivedAtPickup,
  rideStarted,
  stopReached,
  stopCompleted,
  stopSkipped,
  awaitingPayment,
  rideCompleted
}

enum VehicleType {
  car('6848996c6f6c33af02dac315'),
  van('68489aa8db908bf7d3d5e44c'),
  truck('68489b07928954ef90fca6a4'),
  bike('68489b2f928954ef90fca6a6');

  const VehicleType(this.id);

  final String id;
}

enum CarClass {
  regular,
  economy,
  comfort
}

enum BookingSchedule {
  now,
  later,
  recurring
}

class RequestParams {
  OrderType orderType;
  Rx<OrderState> orderState;
  Rx<VehicleType> vehicleType;
  Rx<CarClass> carClass;
  List<String?> addons;
  String? instructions;
  Rx<BookingSchedule> requestSchedule;
  Rx<DateTime> bookingDate;
  List<String>? bookingRecurringDays;

  RequestParams({
    required this.orderType,
    required this.orderState,
    required this.vehicleType,
    required this.carClass,
    this.addons = const [],
    this.instructions,
    required this.requestSchedule,
    required this.bookingDate,
    required this.bookingRecurringDays,
  });

  factory RequestParams.fromActiveRequest(data) {
    return RequestParams(
      orderType: data['orderType'], 
      orderState: data['orderState'], 
      vehicleType: data['vehicleType'], 
      carClass: data['carClass'], 
      requestSchedule: data['requestSchedule'], 
      bookingDate: data['bookingDate'], 
      bookingRecurringDays: data['bookingRecurringDays']
    );
  }
}