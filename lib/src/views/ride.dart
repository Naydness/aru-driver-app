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
import 'package:aru/src/services/popup_manager.dart';
import 'package:aru/src/views/home.dart';
import 'package:aru/src/views/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:text_scroll/text_scroll.dart';

class Ride extends StatelessWidget {
  const Ride(this.request, {super.key});

  final Map request;

  @override
  Widget build(BuildContext context) {
    RideController controller = Get.put(RideController());

    final requestCoords = {
      'pickupLocation': request['pickupLocation'],
      'dropoffLocation': request['dropoffLocation']
    };

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .6,
            child: AruMap(request: requestCoords)
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
                        child: Column(
                          children: [
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(title, style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF212121)
                                )),
                                /*InkWell(
                                  onTap: () => Get.back(),
                                  child: Text('Cancel', style: TextStyle(
                                    color: colorRed
                                  ))
                                )*/
                              ],
                            ),
                            const SizedBox(height: 28,),*/
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
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Image.asset('assets/images/car.png'),
                                            const SizedBox(width: 16,),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Toyota Camry', style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: colorBlack2
                                                  ),),
                                                  const SizedBox(height: 8,),
                                                  Text('Red - RXV-8767', style: TextStyle(
                                                    color: Color(0xFF858585),
                                                    fontSize: 12
                                                  ))
                                                ],
                                              )
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 16,),
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
                                                  Text('John Doe', style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: colorBlack2
                                                  )),
                                                  const SizedBox(height: 8,),
                                                  Text('Driver', style: TextStyle(
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
                                    /*child: RouteSummary(
                                      pickup: pickup, 
                                      destination: destination, 
                                      stops: stops
                                    )*/
                                  )
                                ],
                              )
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: Buttons.text('Start Trip', onPressed: () {
                                // controller.orderState.value = OrderState.summary;
                                
                              })
                              .primary
                              .build(),
                            )
                          ],
                        )
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

  late OrderType selectedOrderType;
  late Rx<OrderState> orderState;
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
  late StreamSubscription<ably.Message> subscription;
  final AddressPickerController addressPickerCtrl = Get.find();

  String? activeRequestId;

  RequestParams? params;

  RideController();

  RxBool showMap = false.obs;
  RxMap requestCoords = RxMap();

  @override
  void onInit() {
    super.onInit();

    if (params != null) {
      selectedOrderType = params!.orderType;
      orderState = params!.orderState;
      selectedVehicle = params!.vehicleType;
      selectedClass = params!.carClass;
      addons = params!.addons;
      bookingSchedule = params!.requestSchedule;
      bookingDate = params!.bookingDate;
      bookingRecurringDays = params!.bookingRecurringDays;
    } else {
      HomeController homeCtrl = Get.find();
      selectedOrderType = OrderType.fromIndex(homeCtrl.tabCtrl.index);
      orderState = OrderState.initial.obs;
      selectedVehicle = VehicleType.car.obs;
      selectedClass = CarClass.regular.obs;
      addons = [];
      bookingSchedule = BookingSchedule.now.obs;
      bookingDate = DateTime.now().add(Duration(minutes: 30)).obs;
    }
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
        case 'ride-matching':
          orderState.value = OrderState.searchingDriver;
          break;

        case 'ride-no-driver':
          if (payload['retry'] == false) {
            await subscription.cancel();
            orderState.value = OrderState.driverNotFound;
          }
          break;

        case 'ride-cancelled':
          Get.until((route) => route.settings.name == '/');
          PopupManager.info(
            title: 'Order Cancelled',
            message: 'Your order has been cancelled.'
          );
          break;

        case 'ride-accepted':
          orderState.value = OrderState.awaitingDriver;
          break;

        case 'driver-arrived':
          orderState.value = OrderState.driverArrived;
          break;

        case 'ride-started':
          orderState.value = OrderState.inProgress;
          break;

        case 'ride-completed':
          orderState.value = OrderState.summary;
          break;
      }
    });
  }

  @override
  void onClose() async {
    await subscription.cancel();
    super.onClose();
  }

  /*@override
  void onReady() async {
    change(null, status: RxStatus.success());
    await Future.delayed(Duration(seconds: 5));
    await mapCtrl.future;
    change(true, status: RxStatus.success());
  }*/

  void startRequest(String reqId) {
    subscribeToRequest(reqId);
  }
}

enum OrderState {
  initial,
  chooseClass,
  rideDetails,
  confirmation,
  creatingRequest,
  requestFailed,
  searchingDriver,
  driverNotFound,
  awaitingDriver,
  driverArrived,
  inProgress,
  summary
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