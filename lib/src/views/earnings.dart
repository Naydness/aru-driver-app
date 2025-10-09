import 'dart:math' as math;

import 'package:aru/src/components/route_summary.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:text_scroll/text_scroll.dart';

class Earnings extends StatelessWidget {
  const Earnings({super.key});

  @override
  Widget build(BuildContext context) {
    EarningsController controller = Get.put(EarningsController());
    AuthManager authManager = Get.find();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text('Earnings'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 24, 47),
          image: DecorationImage(
            image: AssetImage('assets/images/map_bg_overlay.png'),
            fit: BoxFit.cover
          )
        ),
        child: Container(
          margin: EdgeInsets.only(top: 120),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(24),
              topEnd: Radius.circular(24),
            )
          ),
          child: Column(
            children: [
              Container(

                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFFEBEBEB),
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(8),
                    topEnd: Radius.circular(8)
                  )
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: controller.tabCtrl,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorPrimary
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: colorPrimary,
                      tabs: [
                        Tab(text: 'Today'),
                        Tab(text: 'This Week'),
                      ]
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildOverviewItem(
                            'wallet_cash.png', 
                            'Total Earnings',
                            '\$${authManager.user['wallet']['balance'].toStringAsFixed(2)}'
                          )
                        ),
                        Expanded(
                          child: _buildOverviewItem(
                            'delivery_van.png', 
                            'Total Trips',
                            authManager.user['totalTrips'].toString()
                          )
                        ),
                      ],
                    )
                  ],
                )
              ),
              const SizedBox(height: 24,),
              Expanded(
                child: controller.obx(
                  (state) {
                    final List allTxns = state!;
                    final List txnsToday = allTxns
                      .where((t) {
                        final txnDate = DateTime.parse(t['createdAt']);
                        final today = DateTime.now();

                        return DateUtils.isSameDay(txnDate, today);
                      })
                      .toList();
                    final List txnsThisWeek = allTxns
                      .where((txn) {
                        final txnDate = DateTime.parse(txn['createdAt']);

                        return isSameWeek(txnDate, DateTime.now());
                      })
                      .toList();

                    return TabBarView(
                      controller: controller.tabCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (txnsToday.isEmpty)
                        buildEmptyPlaceholder()
                        else
                        RefreshIndicator.adaptive(
                          onRefresh: () async => controller.init(),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (ctx, idx) {
                              final txn = txnsToday[idx];

                              return Material(
                                child: _buildListItem(
                                  title: txn['reference'],
                                  subtitle: txn['createdAt']
                                ),
                              );
                            }, 
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 16), 
                            itemCount: txnsToday.length
                          ), 
                        ),

                        if (txnsThisWeek.isEmpty)
                        buildEmptyPlaceholder()
                        else
                        RefreshIndicator.adaptive(
                          onRefresh: () async => controller.init(),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (ctx, idx) {
                              final txn = txnsThisWeek[idx];

                              return Material(
                                child: _buildListItem(
                                  title: txn['reference'],
                                  subtitle: txn['createdAt']
                                ),
                              );
                            }, 
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 16), 
                            itemCount: txnsThisWeek.length
                          ), 
                        ),
                      ]
                    );
                  },
                  onLoading: buildLoader(opacity: 0),
                  onEmpty: buildEmptyPlaceholder(),
                  onError: (error) => buildErrorPlaceholder(text: error)
                )
              )
            ],
          )
        )
      )
    );
  }

  Widget _buildListItem({String? title, String? subtitle, Function()? onTap}) {
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
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Icon(TablerIcons.arrow_down, size: 20)
        ) 
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
      trailing: Text('\$50', style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black
      ))
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

  bool isSameWeek(DateTime txnDate, DateTime t) {
    final txnDay = DateTime(txnDate.year, txnDate.month, txnDate.day);
    final today = DateTime(t.year, t.month, t.day);
    final daysToEOW = 7 - today.weekday;
    final endOfWeek = today.add(Duration(days: daysToEOW));
    Duration diff = endOfWeek.difference(txnDay);

    return (diff.inDays + 1) <= 7;
  }
}

class EarningsController extends GetxController with GetSingleTickerProviderStateMixin, StateMixin {
  late TabController tabCtrl;
  final HttpService http = Get.find();
  RxList txns = RxList.empty();

  @override
  void onInit() {
    super.onInit();
    tabCtrl = TabController(length: 2, vsync: this, animationDuration: Duration.zero);
  }

  @override
  void onReady() {
    init();
  }

  void init() async {
    change(null, status: RxStatus.loading());
    final result = await http.getAllTransactions();
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: result
      );
      change(null, status: RxStatus.error());
    } else {
      txns.value = result;

      /*final data = await loadJson('data.json');
      txns.value = data['transactions'];
      print('Txns: $txns');*/

      change(txns, status: txns.isEmpty
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