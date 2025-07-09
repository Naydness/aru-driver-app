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
                  controller: controller.scrollCtrl,
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
                    Text('Overview', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121)
                    )),
                    const SizedBox(height: 16),
                    Container(
                      // constraints: BoxConstraints(minHeight: 200),
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.red)
                      ),
                      child: ResponsiveGridList(
                        minItemsPerRow: 2,
                        horizontalGridSpacing: 12,
                        verticalGridSpacing: 8,
                        minItemWidth: 150, 
                        listViewBuilderOptions: ListViewBuilderOptions(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero
                        ),
                        children: [
                          _buildOverviewItem(
                            'wallet_cash.png', 
                            'Total Earnings',
                            '\$${authManager.user['wallet']['balance']}'
                          ),
                          _buildOverviewItem(
                            'delivery_van.png', 
                            'Total Trips',
                            authManager.user['totalTrips'].toString()
                          ),
                        ]
                      ),
                    ),
                    const SizedBox(height: 16,),
                    SizedBox(
                      child: _buildOverviewItem(
                        null,
                        'Average Ratings',
                        authManager.user['averageRating'].toString(),
                        subtitleIcon: TablerIcons.star_filled
                      )
                    ),
                    const SizedBox(height: 32,),
                    Text('Recent Trips', style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121)
                    )),
                    const SizedBox(height: 16),
                    ListView.separated(
                      controller: controller.scrollCtrl,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemBuilder: (ctx, idx) {
                        return _buildRecentItem(
                          title: '18, MArk Jones Way',
                          subtitle: 'Scheduled - 20 May, 10:30AM',
                          trailing: '\$50'
                        );
                      }, 
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 16,), 
                      itemCount: 5
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

  Widget _buildOverviewItem(String? icon, String title, String subtitle, {IconData? subtitleIcon}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Image.asset('assets/images/$icon', width: 40, height: 40,),
              const SizedBox(height: 12),
            ],
            Text(title, style: TextStyle(
              fontSize: 14,
              color: colorBlack2
            )),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (subtitleIcon != null) ...[
                    Icon(subtitleIcon, color: colorAccent,),
                    const SizedBox(width: 8,),
                  ],
                  Text(subtitle, style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorBlack2
                  ))
                ]
              )
            )
          ],
        ),
      )
    );
  }

  Widget _buildRecentItem({String? title, String? subtitle, Function()? onTap, String? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 60
        ),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
              radius: 22,
              child: Icon(TablerIcons.map_pin, size: 20,)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$title', style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorBlack2
                  )),
                  const SizedBox(height: 8,),
                  Text('$subtitle', style: TextStyle(
                    fontSize: 12,
                    color: colorBlack2
                  ))
                ],
              )
            ),
            const SizedBox(width: 8,),
            Text('$trailing', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black
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
  final scrollCtrl = ScrollController();
  // Rx<AutovalidateMode> validateMode = AutovalidateMode.disabled.obs;

  final OrderType orderType = OrderType.ride;

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
  }
}