import 'package:aru/src/components/address_picker.dart';
import 'package:aru/src/components/button.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:aru/src/views/trips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:text_scroll/text_scroll.dart';

import 'search.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.put(HomeController());
    TripsController tripsController = Get.find();
    AuthManager authManager = Get.find();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/map_bg_overlay.png'),
            fit: BoxFit.cover
          )
        ),
        child: controller.obx(
          (state) {
            return Column(
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
                    child: RefreshIndicator.adaptive(
                      onRefresh: () async => controller.init(),
                      child: ListView(
                        controller: controller.scrollCtrl,
                        padding: EdgeInsets.zero,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: authManager.user['approvalStatus'] != 'approved'
                            ? Column(
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/'
                                      '${KycStatus.fromString(authManager.user['approvalStatus']).iconPath}'
                                    ),
                                    const SizedBox(width: 8,),
                                    Expanded(
                                      child: Text(
                                        'KYC verification '
                                        '${KycStatus.fromString(authManager.user['approvalStatus']).title}',
                                        style: TextStyle(
                                          color: colorBlack2,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8,),
                                Text('${KycStatus.fromString(authManager.user['approvalStatus']).message}')
                              ],
                            )
                            : ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                authManager.user['isOnline']
                                ? 'Online'
                                : 'You are offline'
                              ),
                              titleTextStyle: TextStyle(fontWeight: FontWeight.w600, color: colorBlack2, fontSize: 14),
                              subtitle: authManager.user['isOnline'] ? Text('Go online to start accepting jobs') : null,
                              trailing: Switch.adaptive(
                                activeColor: colorPrimary,
                                value: authManager.user['isOnline'], 
                                onChanged: (v) {
                                  controller.toggleAvailability();
                                }
                              ),
                            )
                          ),
                          const SizedBox(height: 24,),
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
                          if (tripsController.status.isLoading)
                          buildLoader(opacity: 0)
                          else if (tripsController.status.isError)
                          buildErrorPlaceholder()
                          else if (tripsController.status.isEmpty)
                          buildEmptyPlaceholder()
                          else
                          ListView.separated(
                            controller: controller.scrollCtrl,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemBuilder: (ctx, idx) {
                              final req = tripsController.requests.take(5).toList()[idx];
                              return Material(
                                child: _buildRecentItem(
                                  title: req['pickupLocation']['address']['full'],
                                  subtitle: req['createdAt'],
                                  trailing: '\$${req['estimatedPrice'].toStringAsFixed(2)}'
                                ),
                              );
                            }, 
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 16,), 
                            itemCount: tripsController.requests.take(5).length
                          )
                        ],
                      ),
                    )
                  )
                )
              ],
            );
          },
          onLoading: buildLoader(opacity: 1),
          onError: (err) => buildErrorPlaceholder()
        )
      )
    );
  }

  Widget _buildOverviewItem(String? icon, String title, String subtitle, {IconData? subtitleIcon}) {
    return Card(
      elevation: 0,
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

  Widget _buildRecentItem({String? title, String? subtitle, String? trailing, Function()? onTap}) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      ),
      horizontalTitleGap: 12,
      tileColor: Colors.white,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colorPrimary,
        foregroundColor: Colors.white,
        radius: 22,
        child: Icon(TablerIcons.map_pin, size: 20,)
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorBlack2,
        fontSize: 14
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 10,
        color: colorBlack2
      ),
      title: TextScroll(
        '$title', 
        mode: TextScrollMode.bouncing,
        pauseOnBounce: Duration(seconds: 2),
        pauseBetween: Duration(seconds: 2),
        velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
      ),
      subtitle: Text('$subtitle'),
      trailing: Text('$trailing', style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black
      ))
    );
  }
}

class HomeController extends GetxController with GetSingleTickerProviderStateMixin, StateMixin {
  late TabController tabCtrl;
  final scrollCtrl = ScrollController();
  HttpService http = Get.find();
  AuthManager authManager = Get.find();

  final OrderType orderType = OrderType.ride;

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    change(null, status: RxStatus.success());
  }

  void init() async {
    change(null, status: RxStatus.loading());
    final result = await http.getUserProfile();
    if (result is String) {
      change(null, status: RxStatus.error());
    } else {
      authManager.saveUser(result);
      change(null, status: RxStatus.success());
    }
  }

  void toggleAvailability() async {
    change(null, status: RxStatus.loading());
    final result = await http.toggleAvailability();
    if (result ?? false) {
      init();
    }
    change(null, status: RxStatus.success());
  }
}

enum KycStatus {
  pending('wait.png', 'in progress', 'We\'re verifying your information. This may take up to 24hrs. We\'ll let you know as soon as we\'re done.'),
  approved('', 'approved', ''),
  rejected('rejected.png', 'rejected', 'We were not able to verify the document you provided to us. Please upload a clear document for verification.');

  final String? title;
  final String? message;
  final String? iconPath;
  const KycStatus(this.iconPath, this.title, this.message);

  factory KycStatus.fromString(String status) {
    late KycStatus kycSatus;
    switch (status) {
      case 'approved':
        kycSatus = KycStatus.approved;
        break;
      case 'rejected':
        kycSatus = KycStatus.rejected;
        break;
      default:
        kycSatus = KycStatus.pending;
    }

    return kycSatus;
  }
}