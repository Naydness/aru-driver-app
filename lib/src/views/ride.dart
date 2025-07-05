import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:aru/src/components/address_picker.dart';
import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_multi_select.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/components/custom_dropdown.dart';
import 'package:aru/src/components/map.dart';
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
  const Ride({super.key});

  @override
  Widget build(BuildContext context) {
    RideController controller = Get.put(RideController());

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .6,
            child: AruMap(
              onMapCreated: (GoogleMapController c) {
                controller.mapCtrl.complete(c);
              }
            )
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
                          if (controller.orderState.value == OrderState.initial) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Choose a Ride', style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121)
                                    )),
                                    InkWell(
                                      onTap: () => Get.back(),
                                      child: Text('Cancel', style: TextStyle(
                                        color: colorRed
                                      ))
                                    )
                                  ],
                                ),
                                const SizedBox(height: 28,),
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      _buildVehicleSelector(
                                        icon: 'car_3d.png',
                                        title: 'Car',
                                        capacity: 4,
                                        desc: '1.8 x 1.2 x 1.2 Meters - Up to 200kg',
                                        amount: '\$${controller.selectedOrderType.baseFare}',
                                        onTap: () {
                                          controller.selectedVehicle.value = VehicleType.car;
                                        },
                                        selected: controller.selectedVehicle.value == VehicleType.car
                                      ),
                                      const SizedBox(height: 12),
                                      _buildVehicleSelector(
                                        icon: 'van_3d.png', 
                                        title: 'Van',
                                        capacity: 8,
                                        desc: '1.8 x 1.2 x 1.2 Meters - Up to 200kg',
                                        amount: '\$${controller.selectedOrderType.baseFare}',
                                        onTap: () {
                                          controller.selectedVehicle.value = VehicleType.van;
                                        },
                                        selected: controller.selectedVehicle.value == VehicleType.van
                                      ),
                                      const SizedBox(height: 12),
                                      _buildVehicleSelector(
                                        icon: 'truck_3d.png',
                                        title: 'Truck',
                                        capacity: 2,
                                        desc: '1.8 x 1.2 x 1.2 Meters - Up to 200kg',
                                        amount: '\$${controller.selectedOrderType.baseFare}',
                                        onTap: () {
                                          controller.selectedVehicle.value = VehicleType.truck;
                                        },
                                        selected: controller.selectedVehicle.value == VehicleType.truck
                                      ),
                                      const SizedBox(height: 12),
                                      _buildVehicleSelector(
                                        icon: 'bike_3d.png',
                                        title: 'Power Bike',
                                        capacity: 2,
                                        desc: '1.8 x 1.2 x 1.2 Meters - Up to 200kg',
                                        amount: '\$${controller.selectedOrderType.baseFare}',
                                        onTap: () {
                                          controller.selectedVehicle.value = VehicleType.bike;
                                        },
                                        selected: controller.selectedVehicle.value == VehicleType.bike
                                      ),
                                    ]
                                  )
                                ),
                                const SizedBox(height: 16,),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text(
                                    'Continue', 
                                    onPressed: () {
                                      if (controller.selectedVehicle.value == VehicleType.car) {
                                        controller.orderState.value = OrderState.chooseClass;
                                      } else {
                                        controller.orderState.value = OrderState.rideDetails;
                                      }
                                    }
                                  ).primary.build()
                                )
                              ],
                            );
                          }

                          if (controller.orderState.value == OrderState.chooseClass) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Choose a class', style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121)
                                    )),
                                    InkWell(
                                      onTap: () {
                                        controller.orderState.value = OrderState.initial;
                                      },
                                      child: Text('Back', style: TextStyle(
                                        color: colorRed
                                      ))
                                    )
                                  ],
                                ),
                                const SizedBox(height: 28,),
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      _buildVehicleSelector(
                                        icon: 'car_3d.png',
                                        title: 'ARU',
                                        capacity: 4,
                                        amount: '\$${controller.selectedOrderType.baseFare}',
                                        onTap: () {
                                          controller.selectedClass.value = CarClass.regular;
                                        },
                                        selected: controller.selectedClass.value == CarClass.regular
                                      ),
                                      const SizedBox(height: 12),
                                      _buildVehicleSelector(
                                        icon: 'car_3d.png', 
                                        title: 'Comfort',
                                        capacity: 4,
                                        amount: '\$${controller.selectedOrderType.baseFare}',
                                        onTap: () {
                                          controller.selectedClass.value = CarClass.comfort;
                                        },
                                        selected: controller.selectedClass.value == CarClass.comfort
                                      ),
                                      const SizedBox(height: 12),
                                      _buildVehicleSelector(
                                        icon: 'car_3d.png',
                                        title: 'Economy',
                                        capacity: 4,
                                        amount: '\$${controller.selectedOrderType.baseFare}',
                                        onTap: () {
                                          controller.selectedClass.value = CarClass.economy;
                                        },
                                        selected: controller.selectedClass.value == CarClass.economy
                                      )
                                    ]
                                  )
                                ),
                                const SizedBox(height: 16,),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text(
                                    'Continue', 
                                    onPressed: () {
                                      controller.orderState.value = OrderState.rideDetails;
                                    }
                                  ).primary.build()
                                )
                              ],
                            );
                          }

                          if (controller.orderState.value == OrderState.rideDetails) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Ride details', style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121)
                                    )),
                                    InkWell(
                                      onTap: () {
                                        controller.orderState.value = OrderState.initial;
                                      },
                                      child: Text('Back', style: TextStyle(
                                        color: colorRed
                                      ))
                                    )
                                  ],
                                ),
                                const SizedBox(height: 28,),
                                Expanded(
                                  child: Form(
                                    key: controller.detailsFormKey,
                                    child: ListView(
                                      controller: scrollController,
                                      padding: EdgeInsets.zero,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Addons', style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF212121)
                                            )),
                                            const SizedBox(height: 16,),
                                            CustomMultiSelect(
                                              list: [
                                                {'id': 1, 'label': 'Addon 1'},
                                                {'id': 2, 'label': 'Addon 2'},
                                                {'id': 3, 'label': 'Addon 3'},
                                                {'id': 4, 'label': 'Addon 4'},
                                                {'id': 5, 'label': 'Addon 5'}
                                              ],
                                              onChanged: (list) {
                                                print('Options: $list');
                                              }
                                            )
                                          ]
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          fillColor: Colors.white,
                                          maxLines: 5,
                                          label: 'Any special instruction for the driver',
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Schedule', style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF212121)
                                            ))
                                          ],
                                        ),
                                        const SizedBox(height: 16,),
                                        Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: CustomDropdown(
                                            value: controller.bookingSchedule.value, 
                                            items: [
                                              DropdownMenuItem(
                                                value: BookingSchedule.now,
                                                child: Text('Now'),
                                              ),
                                              DropdownMenuItem(
                                                value: BookingSchedule.later,
                                                child: Text('Later'),
                                              ),
                                              DropdownMenuItem(
                                                value: BookingSchedule.recurring,
                                                child: Text('Recurring'),
                                              )
                                            ],
                                            onChanged: (v) {
                                              controller.bookingSchedule.value = v!;
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16,),
                                        if (controller.bookingSchedule.value != BookingSchedule.now) ...[
                                          Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    DateTime? result = await showOmniDateTimePicker(
                                                      context: context,
                                                      type: OmniDateTimePickerType.date,
                                                      firstDate: DateTime.now()
                                                    );
                                                    if (result != null) {
                                                      controller.bookingDate.value = DateTime(
                                                        result.year,
                                                        result.month,
                                                        result.day,
                                                        controller.bookingDate.value.hour,
                                                        controller.bookingDate.value.minute
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8)
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(TablerIcons.calendar_month),
                                                        const SizedBox(width: 8),
                                                        Text(DateFormat('dd/MM/yyyy').format(controller.bookingDate.value))
                                                      ],
                                                    )
                                                  )
                                                )
                                              ),
                                              const SizedBox(width: 8,),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    DateTime? result = await showOmniDateTimePicker(
                                                      context: context,
                                                      type: OmniDateTimePickerType.time,
                                                      firstDate: DateTime.now().add(Duration(minutes: 30))
                                                    );
                                                    if (result != null) {
                                                      controller.bookingDate.value = DateTime(
                                                        controller.bookingDate.value.year,
                                                        controller.bookingDate.value.month,
                                                        controller.bookingDate.value.day,
                                                        result.hour,
                                                        result.minute
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8)
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(TablerIcons.clock),
                                                        const SizedBox(width: 8,),
                                                        Text(DateFormat('jm').format(controller.bookingDate.value))
                                                      ],
                                                    ),
                                                  )
                                                )
                                              )
                                            ],
                                          ),
                                          if (controller.bookingSchedule.value == BookingSchedule.recurring) ...[
                                            const SizedBox(height: 16,),
                                            CustomMultiSelect(
                                              numItemLabels: 4,
                                              list: [
                                                {'id': 'monday', 'label': 'Mon'},
                                                {'id': 'tuesday', 'label': 'Tue'},
                                                {'id': 'wednesday', 'label': 'Wed'},
                                                {'id': 'thursday', 'label': 'Thu'},
                                                {'id': 'friday', 'label': 'Fri'},
                                                {'id': 'saturday', 'label': 'Sat'},
                                                {'id': 'sunday', 'label': 'Sun'},
                                              ],
                                              onChanged: (list) {}
                                            )
                                          ]
                                        ]
                                      ]
                                    )
                                  )
                                ),
                                const SizedBox(height: 16,),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Find Driver', onPressed: () {
                                    controller.findDriver();
                                  }).primary.build()
                                )
                              ],
                            );
                          }

                          if (controller.orderState.value == OrderState.creatingRequest) {
                            return Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      buildLoader(opacity: 1)
                                    ],
                                  )
                                ),
                                /*const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Make Payment', onPressed: () {
                                    controller.orderState.value = OrderState.awaitingDriver;
                                  }).primary.build(),
                                )*/
                              ],
                            );
                          }

                          if (controller.orderState.value == OrderState.requestFailed) {
                            return Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      buildErrorPlaceholder(text: 'Something went wrong')
                                    ],
                                  )
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Go back', onPressed: () {
                                    controller.orderState.value = OrderState.awaitingDriver;
                                  }).primary.build(),
                                )
                              ],
                            );
                          }

                          /*if (controller.orderState.value == OrderState.confirmation) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Confirmation', style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121)
                                    )),
                                    InkWell(
                                      onTap: () => Get.back(),
                                      child: Text('Cancel', style: TextStyle(
                                        color: colorRed
                                      ))
                                    )
                                  ],
                                ),
                                const SizedBox(height: 28,),
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(Icons.circle_outlined),
                                          const SizedBox(height: 16,),
                                          Text('Connecting you to a driver'),
                                          const SizedBox(height: 8,),
                                          Text('Estimated time: 05:00'),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        // child: AddressPicker(isSummary: true,),
                                        child: Container(),
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Payment', style: TextStyle(
                                            fontWeight: FontWeight.w600
                                          )),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  /*height: 38,
                                                  width: 38,*/
                                                  child: Image.asset('assets/images/stripe.png', fit: BoxFit.contain),
                                                ),
                                                const SizedBox(width: 12,),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Pay with', style: TextStyle(
                                                        color: Color(0xFF858585),
                                                        fontSize: 12
                                                      )),
                                                      const SizedBox(height: 4),
                                                      Text('Stripe', style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: colorBlack2
                                                      )),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8,),
                                                InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context, 
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(16),
                                                          topRight: Radius.circular(16)
                                                        )
                                                      ),
                                                      builder: (context) {
                                                        return Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                                                          decoration: BoxDecoration(
                                                            // color: Colors.red,
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(16),
                                                              topRight: Radius.circular(16)
                                                            )
                                                          ),
                                                          child: ListView(
                                                            children: [
                                                              Text('Payment Options', style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w700,
                                                                color: colorBlack2
                                                              )),
                                                              const SizedBox(height: 32,),
                                                              _buildPaymentOption(
                                                                icon: 'wallet.png',
                                                                title: 'Wallet'
                                                              ),
                                                              const SizedBox(height: 12),
                                                              _buildPaymentOption(
                                                                icon: 'paystack.png',
                                                                title: 'Paystack'
                                                              ),
                                                              const SizedBox(height: 12),
                                                              _buildPaymentOption(
                                                                icon: 'stripe.png',
                                                                title: 'Stripe'
                                                              ),
                                                              const SizedBox(height: 12),
                                                              _buildPaymentOption(
                                                                icon: 'flutterwave.png',
                                                                title: 'Flutterwave'
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                    );
                                                  },
                                                  child: Text('Change', style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: colorPrimary
                                                  )),
                                                )
                                              ],
                                            )
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total', style: TextStyle(
                                            color: colorBlack2
                                          )),
                                          Text('\$50', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: colorBlack2
                                          ))
                                        ],
                                      )
                                    ],
                                  )
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Make Payment', onPressed: () {
                                    controller.orderState.value = OrderState.awaitingDriver;
                                  }).primary.build(),
                                )
                              ],
                            );
                          }*/

                          if (controller.orderState.value == OrderState.searchingDriver) {
                            return Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: Lottie.asset('assets/loading.json', frameRate: FrameRate.max),
                                          ),
                                          const SizedBox(height: 16,),
                                          Text('Connecting you to a driver'),
                                          /*const SizedBox(height: 8,),
                                          Text('Estimated time: 05:00'),*/
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        // child: AddressPicker(isSummary: true,),
                                        child: Container(),
                                      ),
                                    ],
                                  )
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Cancel Order', onPressed: () {
                                    // controller.orderState.value = OrderState.summary;
                                    controller.startEventSub = false;
                                    Get.back();
                                  })
                                  .red
                                  .outlined
                                  .build(),
                                )
                              ],
                            );
                          }

                          if (controller.orderState.value == OrderState.driverNotFound) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Searching', style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121)
                                    )),
                                    InkWell(
                                      onTap: () => controller.orderState.value = OrderState.rideDetails,
                                      child: Text('back', style: TextStyle(
                                        color: colorRed
                                      ))
                                    )
                                  ],
                                ),
                                const SizedBox(height: 28,),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(TablerIcons.info_circle, size: 80,),
                                        const SizedBox(height: 4),
                                        Text('No driver found', style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                        ))
                                      ],
                                    ),
                                  )
                                ),
                                /*const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Cancel Order', onPressed: () {
                                    // controller.orderState.value = OrderState.summary;
                                    Get.back();
                                  })
                                  .red
                                  .outlined
                                  .build(),
                                )*/
                              ],
                            );
                          }

                          if (controller.orderState.value == OrderState.awaitingDriver) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Driver arriving', style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121)
                                    )),
                                    /*InkWell(
                                      onTap: () => controller.orderState.value = OrderState.rideDetails,
                                      child: Text('back', style: TextStyle(
                                        color: colorRed
                                      ))
                                    )*/
                                  ],
                                ),
                                const SizedBox(height: 28,),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(TablerIcons.info_circle),
                                        const SizedBox(height: 4),
                                        Text('The driver will arrive soon', style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                        ))
                                      ],
                                    ),
                                  )
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Cancel Order', onPressed: () {
                                    // controller.orderState.value = OrderState.summary;
                                    controller.startEventSub = false;
                                    Get.back();
                                  })
                                  .red
                                  .outlined
                                  .build(),
                                )
                              ],
                            );
                          }
                          
                          if (controller.orderState.value == OrderState.inProgress) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Driver has arrived', style: TextStyle(
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
                                const SizedBox(height: 28,),
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
                                                const SizedBox(width: 8,),
                                                Row(
                                                  children: [
                                                    Icon(TablerIcons.star_filled, size: 16, color: colorAccent,),
                                                    const SizedBox(width: 4,),
                                                    Text('4.5', style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: colorBlack2
                                                    ))
                                                  ],
                                                )
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
                                        // child: AddressPicker(isSummary: true,),
                                        child: Container(),
                                      )
                                    ],
                                  )
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Cancel Order', onPressed: () {
                                    // controller.orderState.value = OrderState.summary;
                                    controller.startEventSub = false;
                                    Get.back();
                                  })
                                  .red
                                  .outlined
                                  .build(),
                                )
                              ],
                            );
                          }

                          if (controller.orderState.value == OrderState.summary) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Review', style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF212121)
                                    )),
                                    InkWell(
                                      onTap: () => Get.back(),
                                      child: Text('Cancel', style: TextStyle(
                                        color: colorRed
                                      ))
                                    )
                                  ],
                                ),
                                const SizedBox(height: 28,),
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            spacing: 16,
                                            children: [
                                              Icon(TablerIcons.star_filled, color: colorAccent),
                                              Icon(TablerIcons.star_filled, color: colorAccent),
                                              Icon(TablerIcons.star_filled, color: colorAccent),
                                              Icon(TablerIcons.star_filled, color: colorAccent),
                                              Icon(TablerIcons.star_filled, color: colorAccent)
                                            ],
                                          ),
                                          const SizedBox(height: 16,),
                                          Text('Excellent', style: TextStyle(
                                            fontSize: 16,
                                            color: colorPrimary,
                                            fontWeight: FontWeight.w700
                                          )),
                                          const SizedBox(height: 16,),
                                          Text('Rate John Doe service', style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF858585)
                                          )),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      CustomTextField(
                                        fillColor: Colors.white,
                                        maxLines: 5,
                                        label: 'Write your text',
                                      )
                                    ],
                                  )
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons.text('Submit', onPressed: () {
                                    Get.back();
                                  }).primary.build(),
                                )
                              ],
                            );
                          }

                          return Container();
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

  late OrderType selectedOrderType;
  
  Rx<OrderState> orderState = OrderState.initial.obs;
  Rx<VehicleType> selectedVehicle = VehicleType.car.obs;
  Rx<CarClass> selectedClass = CarClass.regular.obs;
  final detailsFormKey = GlobalKey<FormState>();
  List<String?> addons = [];
  String? instructions;
  Rx<BookingSchedule> bookingSchedule = BookingSchedule.now.obs;
  late Rx<DateTime> bookingDate = DateTime.now().add(Duration(minutes: 30)).obs;
  List<String>? bookingRecurringDays;

  final HttpService http = Get.find();
  final AuthManager authManager = Get.find();
  late StreamSubscription<ably.Message> subscription;
  bool startEventSub = false;

  @override
  void onInit() async {
    super.onInit();
    HomeController homeCtrl = Get.find();
    selectedOrderType = OrderType.fromIndex(homeCtrl.tabCtrl.index);
    final String ablyKey = String.fromEnvironment('ABLY_KEY');
    final ably.Realtime realtime = ably.Realtime(options: ably.ClientOptions(
      // key: ablyKey
      key: 'RbvVsQ.q4uDvQ:JlsQNqGVMJ9Ojikn5a-sINinYqRBsWOdRQD8pFv0HJQ'
    ));

    final userId = authManager.user['_id'];
    print('user ID: $userId');
    ably.RealtimeChannel channel = realtime.channels.get('rider:$userId');
    print('Channel: $channel');
    await channel.attach();
    subscription = channel.subscribe().listen((ably.Message message) {
      if (startEventSub) {
        print('Ably Event: ${message.name}');
        switch (message.name) {
          case 'ride-matching':
            orderState.value = OrderState.searchingDriver;
            break;

          case 'ride-no-driver':
            orderState.value = OrderState.driverNotFound;
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

  void findDriver() async {
    orderState.value = OrderState.searchingDriver;
    final HomeController homeCtrl = Get.find();
    final OrderType orderType = OrderType.fromIndex(homeCtrl.tabCtrl.index);

    final AddressPickerController addressPickerCtrl = Get.find();
    final pickupId = addressPickerCtrl.pickupInputRef.placeId;

    AddressSearchController searchCtrl = Get.find();
    final pickupCoords = await searchCtrl.getPlaceDetails(pickupId!);

    final dsts = addressPickerCtrl.dstInputRefs;
    final dropoffId = dsts.last.placeId;
    final dstCoords = await searchCtrl.getPlaceDetails(dropoffId!);

    List<Map> stops = [];
    for (var i = 0; i < dsts.length - 1; i++) {
      final placeId = dsts[i].placeId;
      final coords = await searchCtrl.getPlaceDetails(placeId!);
      stops.add({
        'location': {
          'coordinates': [coords['lng'], coords['lat']],
          'address': {
            'full': dsts[i].controller.text,
            'city': 'Lagos',
            'state': 'Lagos',
            'country': 'Nigeria'
          }
        }
      });
    }

    final data = {
      'serviceId': orderType.id,
      'serviceType': orderType.name,
      'pickupLocation': {
        'coordinates': [pickupCoords['lng'], pickupCoords['lat']],
        'address': {
          'full': addressPickerCtrl.pickupInputRef.controller.text,
          'city': 'Lagos',
          'state': 'Lagos',
          'country': 'Nigeria'
        }
      },
      'dropoffLocation': {
        'coordinates': [dstCoords['lng'], dstCoords['lat']],
        'address': {
          'full': dsts.last.controller.text,
          'city': 'Lagos',
          'state': 'Lagos',
          'country': 'Nigeria'
        }
      },
      'stops': stops,
      'specialInstructions': 'Instructions',
      'addons': []
    };

    debugPrint('ReqData: $data');
    final reqResult = await http.createRideRequest(data);

    if (reqResult is String) {
      PopupManager.error(
        title: 'Failed',
        message: 'Unable to create ride request'
      );
    } else {
      startEventSub = true;
      startRequest();
    }

      // Get.to(Ride());
  }

  void startRequest() {
    orderState.value = OrderState.searchingDriver;
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