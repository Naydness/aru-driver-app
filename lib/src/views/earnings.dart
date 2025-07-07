import 'package:aru/src/components/route_summary.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Earnings extends StatelessWidget {
  const Earnings({super.key});

  @override
  Widget build(BuildContext context) {
    OrdersController controller = Get.put(OrdersController());

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
                            '\$125.50'
                          )
                        ),
                        Expanded(
                          child: _buildOverviewItem(
                            'delivery_van.png', 
                            'Total Trips',
                            '41'
                          )
                        ),
                      ],
                    )
                  ],
                )
              ),
              const SizedBox(height: 24,),
              /*Expanded(
                child: controller.obx(
                  (state) {
                    final List allOrders = state!;
                    final List rideOrders = allOrders
                      .where((o) => OrderType.fromString(o['serviceType']) == OrderType.ride)
                      .toList();
                    final List packageOrders = allOrders
                      .where((o) => OrderType.fromString(o['serviceType']) == OrderType.package)
                      .toList();

                    return TabBarView(
                      controller: controller.tabCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (allOrders.isEmpty)
                        buildEmptyPlaceholder()
                        else
                        RefreshIndicator.adaptive(
                          onRefresh: () async => controller.init(),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (ctx, idx) {
                              final order = allOrders[idx];

                              return Material(
                                child: _buildListItem(order),
                              );
                            }, 
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 16), 
                            itemCount: allOrders.length
                          ), 
                        ),

                        if (rideOrders.isEmpty)
                        buildEmptyPlaceholder()
                        else
                        RefreshIndicator.adaptive(
                          onRefresh: () async => controller.init(),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (ctx, idx) {
                              final order = rideOrders[idx];

                              return Material(
                                child: _buildListItem(order),
                              );
                            }, 
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 16), 
                            itemCount: rideOrders.length
                          ), 
                        ),
                      ]
                    );
                  },
                  onLoading: buildLoader(opacity: 0),
                  onEmpty: buildEmptyPlaceholder(),
                  onError: (error) => buildErrorPlaceholder(text: error)
                )
              )*/
            ],
          )
          /*ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),
              Text('20 May, 10:30 AM', style: TextStyle(
                fontSize: 12,
                color: Color(0xFF858585)
              ),),
              const SizedBox(height: 20),
              Material(
                child: _buildListItem()
              ),
              const SizedBox(height: 16),
              Material(
                child: _buildListItem()
              ),
              const SizedBox(height: 16),
              Text('18 May, 10:30 AM', style: TextStyle(
                fontSize: 12,
                color: Color(0xFF858585)
              ),),
              const SizedBox(height: 20),
              Material(
                child: _buildListItem()
              ),
              const SizedBox(height: 16),
              Material(
                child: _buildListItem()
              ),
            ],
          ),*/
        )
      )
    );
  }

  Widget _buildListItem(Map order, {Function()? onTap}) {
    final String pickup = order['pickupLocation']['address']['full'];
    final String dst = order['dropoffLocation']['address']['full'];
    final List stops = order['stops'];
    final String amount = order['estimatedPrice'].toString();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RouteSummary(
              pickup: pickup, 
              destination: dst, 
              stops: stops
            )
          ),
          const SizedBox(width: 8,),
          Text('\$$amount', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black
          ))
        ],
      ),
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
}

class OrdersController extends GetxController with GetSingleTickerProviderStateMixin, StateMixin {
  late TabController tabCtrl;
  final HttpService http = Get.find();
  RxList orders = RxList.empty();

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
    final result = await http.getAllRequests();
    if (result is String) {
      PopupManager.error(
        title: 'Failed',
        message: result
      );
      change(null, status: RxStatus.error());
    } else {
      // orders.value = result;
      final data = await loadJson('data.json');
      orders.value = data['rides'];

      change(orders, status: orders.isEmpty
        ? RxStatus.empty() : RxStatus.success());
    }
  }
}