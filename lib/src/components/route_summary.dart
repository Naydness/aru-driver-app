import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:timelines_plus/timelines_plus.dart';

class RouteSummary extends StatelessWidget {
  const RouteSummary({
    super.key, 
    required this.pickup, 
    required this.destination, 
    required this.stops,
    this.onTap, 
  });

  final String pickup;
  final String destination;
  final List stops;
  final Function()? onTap;


  @override
  Widget build(BuildContext context) {
    final fieldHeight = 60;
    final fieldSpacing = 16;
    final timelineMargin = 25;

    return Row(
      children: [
        Container(
          // min. fields: 2
          height: ( ((fieldHeight * 2) + fieldSpacing) + (stops.length * (fieldHeight + fieldSpacing)) ) 
            - (timelineMargin * 2), // top/bottom space
          margin: EdgeInsets.symmetric(vertical: timelineMargin.toDouble()),
          constraints: BoxConstraints(
            // minHeight: 140
          ),
          // width: 16,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.red)
          ),
          child: FixedTimeline(
            children: [
              OutlinedDotIndicator(
                color: colorPrimary,
                size: 16,
                child: DotIndicator(size: 6, color: colorPrimary,),
              ),
              for (var i = 0; i < stops.length; i++) ...[
                Expanded(
                  child: DashedLineConnector(
                    color: colorPrimary,
                    indent: 8,
                    endIndent: 4,
                    gap: 2
                  ),
                ),
                Icon(TablerIcons.map_pin_filled, color: colorAccent,)
              ],
              Expanded(
                child: DashedLineConnector(
                  color: colorPrimary,
                  indent: 8,
                  endIndent: 4,
                  gap: 2
                ),
              ),
              Icon(TablerIcons.map_pin_filled, color: colorAccent,)
            ],
          )
        ),
        const SizedBox(width: 8,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pick-up location', style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: colorBlack2
                    )),
                    const SizedBox(height: 4),
                    Text(
                      pickup,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorBlack2,
                        fontSize: 14
                      )
                    )
                  ],
                )
              ),
              for (var i = 0; i < stops.length; i++) ...[
                const SizedBox(height: 16,),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Stop', style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: colorBlack2
                      )),
                      const SizedBox(height: 4),
                      Text(
                        stops[i]['location']['address']['full'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorBlack2,
                          fontSize: 14
                        )
                      )
                    ],
                  )
                ),
              ],
              const SizedBox(height: 16,),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Destination', style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: colorBlack2
                    )),
                    const SizedBox(height: 4),
                    Text(
                      destination,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorBlack2,
                        fontSize: 14
                      )
                    )
                  ],
                )
              ),
            ],
          )
        )
        
      ],
    );
  }
}

class RouteSummaryController extends GetxController {

}