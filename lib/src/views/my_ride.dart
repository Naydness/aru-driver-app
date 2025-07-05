import 'package:aru/src/components/address_picker.dart';
import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class MyRide extends StatelessWidget {
  const MyRide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
        title: Text('My Ride'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 13, 24, 47),
          image: DecorationImage(
            image: AssetImage('assets/images/map_bg_overlay.png'),
            fit: BoxFit.cover
          )
        ),
        child: Container(
          margin: EdgeInsets.only(top: 120),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24)
            )
          ),
          child: ListView(
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
                    )
                  ],
                )
              ),
              const SizedBox(height: 16,),
              Image.asset('assets/images/map_route.png', fit: BoxFit.cover,),
              const SizedBox(height: 16,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      // child: AddressPicker(isSummary: true)
                      child: Container(),
                    ),
                    const SizedBox(width: 8,),
                    Text('\$50', style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                    ))
                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}