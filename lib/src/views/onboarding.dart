import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'login.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            final activeIdx = controller.activeIdx.value;

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/onboard_bg_${activeIdx + 1}.png'),
                  fit: BoxFit.fill
                )
              ),
            );
          }),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                colorPrimary.withValues(alpha: 0),
                Color(0xFF212121)
                ]
              )
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      PageView(
                        controller: controller.pageCtrl,
                        physics: ClampingScrollPhysics(),
                        onPageChanged: (idx) {
                          controller.activeIdx.value = idx;
                        },
                        children: [
                          _Page(
                            'onboard_1.png',
                            'Drive with ARU',
                            'Earn on your schedule; accept ride and delivery requests in real time.'
                          ),
                          _Page(
                            'onboard_2.png',
                            'Clear Job Details',
                            'See pickup and drop-off locations, add-ons, and estimated fares upfront.'
                          ),
                          _Page(
                            'onboard_3.png',
                            'Instant Earnings Tracking',
                            'Monitor your trips and payputs; all in one place.'
                          )
                        ],
                      ),
                      Positioned(
                        top: 80,
                        right: 0,
                        left: 0,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              GetStorage().write('firstLaunch', false);
                              Get.off(Login(), id: 0);
                            }, 
                            child: Text('Skip', style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorBlack1
                            ))
                          )
                        )
                      )
                    ],
                  )
                ),
                const SizedBox(height: 40,),
                Container(
                  height: 150, 
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    children: [
                      Obx(() => AnimatedSmoothIndicator(
                        activeIndex: controller.activeIdx.value,
                        count: 3,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: colorPrimary,
                          dotColor: Color(0xFFD0D0D0),
                          expansionFactor: 5,
                          dotWidth: 8,
                          dotHeight: 8
                        ),
                      )),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            final idx = controller.pageCtrl.page!.toInt();
                            if (idx < 2) {
                              _jumpToPage(idx + 1);
                            } else {
                              GetStorage().write('firstLaunch', false);
                              Get.off(const Login(), id: 0);
                            }
                          }, 
                          style: TextButton.styleFrom(
                            backgroundColor: colorPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            )
                          ),
                          child: Obx(() => Text(
                            controller.activeIdx.value < 2 
                            ? 'Next'
                            : 'Get Started', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                            )
                          ))
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          )
        ]
      )
    );
  }

  void _jumpToPage(int idx) {
    OnboardingController controller = Get.find();

    controller.pageCtrl.animateToPage(
      idx, 
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear
    );

    controller.activeIdx.value = idx;
  }
}

class OnboardingController extends GetxController {
  late PageController pageCtrl;
  RxInt activeIdx = 0.obs;

  @override
  void onInit() {
    super.onInit();
    pageCtrl = PageController();
  }

  @override
  void onClose() {
    pageCtrl.dispose();
    super.onClose();
  }
}

class _Page extends StatelessWidget {
  final String icon;
  final String header;
  final String caption;

  const _Page(this.icon, this.header, this.caption);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        /*Container(
          height: MediaQuery.of(context).size.height * .5,
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 250,
              maxHeight: 300
            ),
            child: Image.asset('assets/images/$icon')
          )
        ),
        const SizedBox(height: 40,),*/
        SizedBox(
          child: Text(header, style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20
          ), textAlign: TextAlign.center,),
        ),
        const SizedBox(height: 16,),
        SizedBox(
          child: Text(caption, style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12
          ), textAlign: TextAlign.center,)
        ),
      ],
    );
  }
}