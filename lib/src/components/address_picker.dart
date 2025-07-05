import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/views/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:timelines_plus/timelines_plus.dart';

class AddressPicker extends StatelessWidget {
  const AddressPicker({
    super.key, 
    this.readOnly = false,
    this.onTap,
    this.formKey
  });

  final bool readOnly;
  final Function()? onTap;
  final GlobalKey<FormState>? formKey;


  @override
  Widget build(BuildContext context) {
    AddressPickerController controller = Get.find();
    final stops = controller.stops;
    final fieldHeight = controller.fieldHeight;
    final fieldSpacing = controller.fieldSpacing;
    final timelineMargin = controller.timelineMargin;

    return Obx(() => Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Container(
              // min. fields: 2
              height: ( ((fieldHeight * 2) + fieldSpacing) + (stops.value * (fieldHeight + fieldSpacing)) ) 
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
                  for (var i = 0; i < stops.value + 1; i++) ...[
                    Expanded(
                      child: DashedLineConnector(
                        color: colorPrimary,
                        indent: 8,
                        endIndent: 4,
                        gap: 2
                      ),
                    ),
                    Icon(TablerIcons.map_pin_filled, color: colorAccent,)
                  ]
                ],
              )
            ),
            const SizedBox(width: 8,),
            Expanded(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: CustomTextField(
                              controller: controller.pickupInputRef.controller,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return '';
                                } return null;
                              },
                              focusNode: controller.pickupInputRef.focus,
                              label: 'Pick-up location',
                              onTap: () {
                                if (onTap != null) {
                                  onTap!();
                                  FocusScope.of(context).requestFocus(controller.pickupInputRef.focus);
                                }
                              },
                              readOnly: readOnly,
                              errorStyle: TextStyle(
                                height: 0,
                                fontSize: 0,
                                color: Colors.transparent
                              ),
                            ),
                          ),
                        ),
                        if (controller.dstInputRefs.length > 1) ...[
                          const SizedBox(width: 16,),
                          SizedBox(width: 20, height: 20,)
                        ]
                      ],
                    ),
                    for (var i = 0; i < stops.value + 1; i++) ...[
                      const SizedBox(height: 16,),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: CustomTextField(
                                controller: controller.dstInputRefs[i].controller,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return '';
                                  } return null;
                                },
                                focusNode: controller.dstInputRefs[i].focus,
                                label: (stops.value + 1)  - i == 1 ? 'Destination' : 'Add stop',
                                onTap: () {
                                  if (onTap != null) {
                                    onTap!();
                                    FocusScope.of(context).requestFocus(controller.dstInputRefs[i].focus);
                                  }
                                },
                                readOnly: readOnly,
                                errorStyle: TextStyle(
                                  height: 0,
                                  fontSize: 0,
                                  color: Colors.transparent
                                ),
                              ),
                            ),
                          ),
                          if (controller.dstInputRefs.length > 1) ...[
                            const SizedBox(width: 16,),
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: InkWell(
                                onTap: () {
                                  controller.removeDst(i);
                                },
                                child: Icon(Icons.close, size: 20,)
                              )
                            )
                          ]
                        ],
                      )
                    ]
                  ],
                )
              )
            )
          ],
        ),
        /*if (readOnly && controller.stops.value == 0)
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle
          ),
          child: Icon(TablerIcons.arrows_up_down, color: colorRed, size: 16,)
        ),*/
      ],
    ));
  }
}

class AddressPickerController extends GetxController {
  final moreStops = 2;
  final fieldHeight = 60;
  final fieldSpacing = 16;
  final timelineMargin = 25;

  RxInt stops = 0.obs;

  late InputRef pickupInputRef;
  RxList<InputRef> dstInputRefs = RxList.empty();
  late InputRef activeField;

  @override
  void onInit() {
    super.onInit();
    activeField = InputRef.init();

    pickupInputRef = InputRef.init();
    pickupInputRef.focus.addListener(() {
      if (pickupInputRef.focus.hasFocus) {
        activeField = pickupInputRef;
      }
    });

    final dstInputRef = InputRef.init();
    dstInputRef.focus.addListener(() {
      if (dstInputRef.focus.hasFocus) {
        activeField = dstInputRef;
      }
    });
    dstInputRefs.add(dstInputRef); // Add destination controller
  }

  @override
  void onClose() {
    activeField.dispose();
    pickupInputRef.dispose();

    for (var ref in dstInputRefs) {
      ref.dispose();
    }

    super.onClose();
  }

  void addInputListener({required Function(String) onInputChanged}) {
    pickupInputRef.controller.addListener(() {
      if (pickupInputRef.prevText != pickupInputRef.controller.text) {
        print('Updating pickup...');
        pickupInputRef.placeId = null;
        pickupInputRef.prevText = pickupInputRef.controller.text;
        onInputChanged(pickupInputRef.controller.text);
      }
    });

    for (var ref in dstInputRefs) {
      ref.controller.addListener(() {
        if (ref.prevText != ref.controller.text) {
          print('Updating dst...');
          ref.placeId = null;
          ref.prevText = ref.controller.text;
          onInputChanged(ref.controller.text);
        }
      });
    }
  }

  void addStop() {
    if (dstInputRefs.length < (moreStops + 1)) {
      AddressSearchController searchCtrl = Get.find();
      final InputRef ref = InputRef.init();
      ref.focus.addListener(() {
        if (ref.focus.hasFocus) {
          activeField = ref;
        }
      });

      ref.controller.addListener(() => searchCtrl.updatePredictions(ref.controller.text));
      dstInputRefs.insert(0, ref);
      stops++;
    }
  }

  void removeDst(int idx) {
    if (dstInputRefs.length > 1) {
      final ref = dstInputRefs.removeAt(idx);
      ref.dispose();
      stops--;
    }
  }

  void validateAddresses() {
    _validateInputRef(pickupInputRef);
    for (var ref in dstInputRefs) {
      _validateInputRef(ref);
    }
  }

  void switchFocus() {
    List<InputRef> refs = [
      pickupInputRef,
      ...dstInputRefs
    ];

    bool isOk = true;

    for (var ref in refs) {
      if (ref.placeId == null || ref.placeId!.isEmpty) {
        activeField = ref;
        FocusScope.of(Get.context!).requestFocus(activeField.focus);
        isOk = false;
        break;
      }
    }

    if (isOk) {
      Get.back();
    }
  }

  _validateInputRef(InputRef ref) {
    if (ref.placeId == null || ref.placeId!.isEmpty) {
      ref.controller.text = '';
    }
  }
}

class InputRef {
  final TextEditingController controller;
  String prevText;
  final FocusNode focus;
  String? placeId;

  InputRef({
    required this.controller, 
    this.prevText = '',
    required this.focus,
    this.placeId
  });

  factory InputRef.init() {
    final controller = TextEditingController();

    final focus = FocusNode();


    return InputRef(
      controller: controller, 
      focus: focus
    );
  }

  /*void addListener({required Function(String) onInputChanged, required VoidCallback onFocusChanged}) {
    controller.addListener(() => onInputChanged(controller.text));
    focus.addListener(onFocusChanged);
  }*/

  /*void removeListener({required VoidCallback onInputChanged, required VoidCallback onFocusChanged}) {
    controller.removeListener(onInputChanged);
    focus.removeListener(onFocusChanged);
  }*/

  void dispose() {
    controller.dispose();
    focus.dispose();
  }
}