import 'package:aru/src/components/address_picker.dart';
import 'package:aru/src/components/button.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import 'ride.dart';
import 'search.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController());
    AddressPickerController addressPickerCtrl = Get.put(AddressPickerController());
    Get.put(AddressSearchController());
    AuthManager authManager = Get.find();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/map_bg_overlay.png'),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 80, 16, 0),
              // color: colorPrimary,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(16)
                    ),
                    // child: Image.asset('assets/images/user.png'),
                    child: Text(authManager.userInitials, style: TextStyle(
                      color: colorBlack1,
                      fontWeight: FontWeight.w600,
                      fontSize: 20
                    )),
                  ),
                  const SizedBox(width: 16,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Welcome', style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white
                        )),
                        const SizedBox(height: 4,),
                        Text(authManager.userFullName, style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                        ))
                      ],
                    )
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Center(
                      child: Icon(TablerIcons.bell),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(24),
                    topEnd: Radius.circular(24),
                  )
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        color: Colors.transparent,
                        child: PageView(
                          children: [
                            Image.asset('assets/images/banner.png', fit: BoxFit.cover,)
                          ],
                        )
                      ),
                    ),
                    const SizedBox(height: 24,),
                    Container(
                      height: 60,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFFEBEBEB),
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(8),
                          topEnd: Radius.circular(8)
                        )
                      ),
                      child: TabBar(
                        controller: controller.tabCtrl,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorPrimary
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: colorPrimary,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(TablerIcons.car),
                                const SizedBox(width: 8,),
                                Text('Ride')
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(TablerIcons.package),
                                const SizedBox(width: 8,),
                                Text('Package')
                              ],
                            ),
                          )
                        ]
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadiusDirectional.only(
                            bottomStart: Radius.circular(12),
                            bottomEnd: Radius.circular(12)
                          )
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                // border: Border.all(color: Colors.red)
                              ),
                              constraints: BoxConstraints(
                                minHeight: 140
                              ),
                              child: AddressPicker(
                                formKey: controller.formKey,
                                readOnly: true,
                                onTap: () async {
                                  Get.to(
                                    Search(),
                                    fullscreenDialog: true
                                  );
                                },
                              )
                            ),
                            const SizedBox(height: 16,),
                            Obx(() {
                              if (addressPickerCtrl.stops.value < addressPickerCtrl.moreStops) {
                                return InkWell(
                                  onTap: () {
                                    addressPickerCtrl.addStop();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(TablerIcons.plus, color: colorPrimary,),
                                      const SizedBox(width: 8,),
                                      Text('Add another stop', style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorPrimary
                                      ))
                                    ]
                                  )
                                );
                              }

                              return Container();
                            }),
                            const SizedBox(height: 16,),
                            SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: Buttons.text('Continue', onPressed: () {
                                controller.gotoRide();
                              }).primary.build(),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32,),
                    Text('Vehicle Types', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121)
                    )),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.red)
                      ),
                      child: ResponsiveGridList(
                        minItemsPerRow: 2,
                        horizontalGridSpacing: 36,
                        verticalGridSpacing: 16,
                        minItemWidth: 150, 
                        listViewBuilderOptions: ListViewBuilderOptions(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero
                        ),
                        children: [
                          _buildVehicleType('car_3d.png', 'Car'),
                          _buildVehicleType('van_3d.png', 'Van'),
                          _buildVehicleType('truck_3d.png', 'Truck'),
                          _buildVehicleType('bike_3d.png', 'Power Bike')
                        ]
                      ),
                    )
                  ],
                ),
              )
            )
          ],
        ),
      )
    );
  }

  Widget _buildVehicleType(String icon, String label) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/$icon', width: 40, height: 40,),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              color: Color(0xFF212121)
            ))
          ],
        ),
      )
    );
  }
}

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabCtrl;
  final formKey = GlobalKey<FormState>();
  // Rx<AutovalidateMode> validateMode = AutovalidateMode.disabled.obs;

  final OrderType orderType = OrderType.ride;

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
  }

  void gotoRide() {
    // Get.to(Ride()); return;

    if (formKey.currentState!.validate()) {
      Get.to(Ride());
    } else {
      PopupManager.error(
        title: 'Location required',
        message: 'Pickup/Destination locations required'
      );
    }
  }
}