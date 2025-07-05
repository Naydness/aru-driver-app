import 'package:aru/src/components/address_picker.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    AddressPickerController addressPickerCtrl = Get.find();
    AddressSearchController controller = Get.find();

    return Scaffold(
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            addressPickerCtrl.validateAddresses();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/map_bg.png'),
              fit: BoxFit.cover
            )
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.9,
            snap: true,
            builder: (context, scrollController) {
              return Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)
                  )
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Search', style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorBlack2
                          )),
                          InkWell(
                            onTap: () => Get.back(),
                            child: Text('Cancel', style: TextStyle(
                              fontSize: 12,
                              color: colorRed
                            ))
                          )
                        ],
                      ),
                      const SizedBox(height: 28,),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 140
                        ),
                        child: AddressPicker()
                      ),
                      const SizedBox(height: 24,),
                      Obx(() {
                        if (addressPickerCtrl.stops.value < addressPickerCtrl.moreStops) {
                          return InkWell(
                            onTap: () {
                              addressPickerCtrl.addStop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                      const SizedBox(height: 32,),
                      Obx(() => Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: controller.predictions.length,
                          itemBuilder: (ctx, idx) {
                            final prediction = controller.predictions[idx];
                            final subtitle = prediction['terms']?[prediction['terms'].length - 2];

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              titleTextStyle: TextStyle(fontWeight: FontWeight.w600, color: colorBlack2, fontSize: 14),
                              subtitleTextStyle: TextStyle(color: colorBlack2, fontSize: 12),
                              leading: Container(
                                width: 46,
                                height: 46,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF6F6F6)
                                ),
                                child: Icon(TablerIcons.map_pin_filled, color: Colors.black,)
                              ),
                              title: Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(prediction['description'])
                              ),
                              subtitle: Text(subtitle['value']),
                              onTap: () {
                                addressPickerCtrl.activeField.controller.text = prediction['description'];
                                addressPickerCtrl.activeField.placeId = prediction['place_id'];

                                addressPickerCtrl.switchFocus();
                              },
                            );
                          },
                          separatorBuilder: (context, index) => Container(height: 12),
                        )
                      ))
                    ],
                  )
                )
              );
            }
          )
        )
      )
    );
  }
}

class AddressSearchController extends GetxController {
  final GetConnect http = GetConnect();
  RxList predictions = RxList.empty();

  @override
  void onInit() async {
    super.onInit();
    AddressPickerController addressPickerController = Get.find();
    addressPickerController.addInputListener(
      onInputChanged: updatePredictions
    );
  }

  void updatePredictions(String q) async {
    predictions.value = await getLocation(q);
  } 

  Future<List> getLocation(String query, {String? token}) async {
    const url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    const apiKey = String.fromEnvironment('GOOGLE_API_KEY');
    token ??= 'debug';
    final req = '$url?input=$query&components=country:ng&key=$apiKey&sessionToken=$token';

    final res = await http.get(req);

    if (res.status.isOk) {
      return res.body['predictions'];
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<Map> getPlaceDetails(String id) async {
    const url = 'https://maps.googleapis.com/maps/api/place/details/json';
    const apiKey = String.fromEnvironment('GOOGLE_API_KEY');
    final req = '$url?placeid=$id&key=$apiKey';

    final res = await http.get(req);
    if (res.status.isOk) {
      // print('LOC: ${res.body}');
      return res.body['result']['geometry']['location'];
    } else {
      throw Exception('Failed to load place details');
    }
  }
}