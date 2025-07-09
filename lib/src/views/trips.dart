import 'package:aru/src/components/button.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:aru/src/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import 'dart:math' as math;

import 'package:text_scroll/text_scroll.dart';

class Trips extends StatelessWidget {
  const Trips({super.key});

  @override
  Widget build(BuildContext context) {
    WalletController controller = Get.put(WalletController());
    AuthManager authManager = Get.find();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text('Trips'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 24, 47),
          image: DecorationImage(
            image: AssetImage('assets/images/map_bg_overlay.png'),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 140, 16, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
                child: controller.obx(
                  (state) {
                    final List allRequests = state!;

                    return Column(
                      children: [
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
                              Tab(text: 'Upcoming'),
                              Tab(text: 'Past'),
                            ]
                          )
                        ),
                        const SizedBox(height: 16,),
                        Expanded(
                          child: TabBarView(
                            controller: controller.tabCtrl,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(),

                              if (allRequests.isEmpty)
                              buildEmptyPlaceholder()
                              else
                              RefreshIndicator.adaptive(
                                onRefresh: () async => controller.init(),
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (ctx, idx) {
                                    final req = allRequests[idx];

                                    return Material(
                                      child: _buildListItem(
                                        title: req['pickupLocation']['address']['full'],
                                        subtitle: req['createdAt'],
                                        trailing: '\$${req['estimatedPrice'].toStringAsFixed(2)}'
                                      ),
                                    );
                                  }, 
                                  separatorBuilder: (ctx, idx) => const SizedBox(height: 16,), 
                                  itemCount: allRequests.length
                                ),
                              ),
                            ]
                          )
                        )
                      ],
                    );
                    /*return RefreshIndicator.adaptive(
                      onRefresh: () async => controller.init(),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          
                          const SizedBox(height: 16),
                          TabBarView(
                            controller: controller.tabCtrl,
                            children: [

                            ]
                          )
                          Text('20 May, 10:30 AM', style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF858585)
                          )),
                          const SizedBox(height: 20),
                          Material(
                            child: _buildListItem(
                              type: TxnType.incoming,
                              icon: TablerIcons.arrow_up,
                              title: 'Xch00210Wfr',
                              subtitle: 'Wallet funding - Paystack'
                            )
                          ),
                          const SizedBox(height: 16),
                          Material(
                            child: _buildListItem(
                              type: TxnType.outgoing,
                              icon: TablerIcons.arrow_up,
                              title: 'Xch00210Wfr',
                              subtitle: 'Ride payment - Paystack'
                            )
                          ),
                          const SizedBox(height: 16),
                          Text('18 May, 10:30 AM', style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF858585)
                          )),
                          const SizedBox(height: 20),
                          Material(
                            child: _buildListItem(
                              type: TxnType.outgoing,
                              icon: TablerIcons.arrow_up,
                              title: 'Xch00210Wfr',
                              subtitle: 'Ride payment - Paystack'
                            )
                          ),
                          const SizedBox(height: 16),
                          Material(
                            child: _buildListItem(
                              type: TxnType.incoming,
                              icon: TablerIcons.arrow_up,
                              title: 'Xch00210Wfr',
                              subtitle: 'Wallet funding - Paystack'
                            )
                          ),
                          const SizedBox(height: 16),
                          Text('16 May, 10:30 AM', style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF858585)
                          )),
                          const SizedBox(height: 20),
                          Material(
                            child: _buildListItem(
                              type: TxnType.incoming,
                              icon: TablerIcons.arrow_up,
                              title: 'Xch00210Wfr',
                              subtitle: 'Wallet funding - Paystack'
                            )
                          ),
                          const SizedBox(height: 16),
                          Material(
                            child: _buildListItem(
                              type: TxnType.outgoing,
                              icon: TablerIcons.arrow_up,
                              title: 'Xch00210Wfr',
                              subtitle: 'Ride payment - Paystack'
                            )
                          ),
                        ],
                      )
                    );*/
                  },
                  onLoading: buildLoader(opacity: 0),
                  onEmpty: buildEmptyPlaceholder(),
                  onError: (error) => buildErrorPlaceholder(text: error),
                )
              )
            )
          ],
        ),
      )
    );
  }

  Widget _buildListItem({String? title, String? subtitle, String? trailing, Function()? onTap}) {
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

class WalletController extends GetxController with GetSingleTickerProviderStateMixin, StateMixin {
  late TabController tabCtrl;
  final HttpService http = Get.find();
  RxList requests = RxList.empty();
  RxBool funding = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
  }

  @override
  void onReady() {
    init();
  }

  /*void init() async {
    change(null, status: RxStatus.loading());
    final result = await http.getAllTransactions();
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: result
      );
      change(null, status: RxStatus.error());
    } else {
      // transactions.value = result;
      final data = await loadJson('data.json');
      transactions.value = data['transactions'];

      change(transactions, status: transactions.isEmpty
        ? RxStatus.empty() : RxStatus.success());
    }
  }*/

  void init() async {
    change(null, status: RxStatus.loading());
    final result = await http.getAllRequests();
    if (result is String) {
      change(result, status: RxStatus.error());
    } else {
      requests.value = result;
      change(requests, status: requests.isEmpty
        ? RxStatus.empty() : RxStatus.success());
    }
  }
}

enum TxnType {
  incoming,
  outgoing;

  static fromString(String type) {
    late TxnType tnxType;
    switch (type) {
      case 'credit':
        tnxType = TxnType.incoming;
        break;
      default:
        tnxType = TxnType.outgoing;
    }

    return tnxType;
  }
}