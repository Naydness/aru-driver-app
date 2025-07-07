import 'dart:io';

import 'package:aru/src/components/button.dart';
import 'package:aru/src/components/custom_dropdown.dart';
import 'package:aru/src/components/custom_text_field.dart';
import 'package:aru/src/components/otp.dart';
import 'package:aru/src/components/phone_field.dart';
import 'package:aru/src/constants.dart';
import 'package:aru/src/helper.dart';
import 'package:aru/src/services/http.dart';
import 'package:aru/src/services/popup_manager.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import 'login.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupController controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light
        ),
        centerTitle: true,
        title: Obx(() {
          if (controller.stage.value == SignupStage.initial) {
            late String title;
            switch (controller.step.value) {
              case 1:
                title = 'Experience';
                break;
              case 2:
                title = 'Uploads';
                break;
              case 3:
                title = 'Vehicle Information';
                break;
              default:
                title = 'Personal Information';
            }
            return Text(title);
          }
          return Container();
        }),
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.stage.value == SignupStage.initial) {  
              return Padding(
                padding: EdgeInsets.only(top: 100),
                child: Stepper(
                  controller: controller.scrollController,
                  elevation: 0,
                  type: StepperType.horizontal,
                  stepIconMargin: EdgeInsets.zero,
                  stepIconHeight: 48,
                  stepIconWidth: 48,
                  connectorColor: WidgetStateColor.resolveWith((states) => colorPrimary),
                  currentStep: controller.step.value,
                  controlsBuilder: (context, details) => Container(),
                  stepIconBuilder: (idx, stepState) {
                    final step = idx + 1;
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('$step'.padLeft(2, '0'), style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: controller.step >= idx ? Colors.white : colorPrimary
                      ))
                    );
                  },
                  steps: [
                    Step(
                      title: Text(''), 
                      content: Form(
                        key: controller.step1FormKey,
                        autovalidateMode: controller.validateMode.value,
                        child: ListView(
                          controller: controller.scrollController,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 80),
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 60
                              ),
                              child: CustomTextField(
                                controller: controller.nameCtrl,
                                label: 'Name',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Name is required';
                                  } return null;
                                },
                              )
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 60
                              ),
                              child: CustomTextField(
                                controller: controller.emailCtrl,
                                label: 'Email',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Email address is required';
                                  } return null;
                                },
                              )
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 44
                              ),
                              child: PhoneField(
                                controller: controller.phoneCtrl,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Phone number is required';
                                  } return null;
                                },
                                onChanged: (phone) {
                                  controller.phoneData = phone;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 60),
                              child: CustomTextField(
                                controller: controller.licenseNoCtrl,
                                label: 'Driver\'s License Number',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'License number is required';
                                  } return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 60
                              ),
                              child: CustomTextField(
                                controller: controller.passwordCtrl,
                                label: 'Password',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  } return null;
                                },
                                obscureText: controller.hidePassword.value,
                                suffixIcon: controller.hidePassword.value
                                  ? TablerIcons.eye_off
                                  : TablerIcons.eye,
                                onSuffixIconTap: () => controller.hidePassword.toggle(),
                              ),
                            ),
                            const SizedBox(height: 16,),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => controller.agreeTerms.toggle(),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF333333)
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: controller.agreeTerms.value, 
                                      fillColor: WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return colorPrimary;
                                        }

                                        return colorPrimary.withValues(alpha: 0.05);
                                      }),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide.none,
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      side: BorderSide.none,
                                      onChanged: (v) {
                                        controller.agreeTerms.value = v!;
                                      }
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Wrap(
                                        children: [
                                          Text('I agree to the '),
                                          InkWell(
                                            onTap: () {},
                                            child: Text('Terms of Service ', style: TextStyle(
                                              color: colorAccent
                                            )),
                                          ),
                                          Text('and '),
                                          InkWell(
                                            onTap: () {},
                                            child: Text('Privacy Policy ', style: TextStyle(
                                              color: colorAccent
                                            )),
                                          )
                                        ],
                                      ),
                                    )
                                  ]
                                )
                              ),
                            ),
                            const SizedBox(height: 32),
                            Stack(
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: Buttons
                                    .text(
                                      'Continue',
                                      onPressed: () {
                                        if (controller.agreeTerms.value) {
                                          FocusScopeNode focus = FocusScope.of(context);
                                          if (!focus.hasPrimaryFocus) {
                                            focus.unfocus();
                                          }

                                          controller.toStep2();
                                        }
                                      }
                                    )
                                    .primary
                                    .build(),
                                ),
                                if (!controller.agreeTerms.value)
                                Container(
                                  height: 60, 
                                  width: double.infinity, 
                                  color: Colors.white.withValues(alpha: .5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DefaultTextStyle(
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF333333)
                              ),
                              child: Row(
                                children: [
                                  Text('Already have an account? '),
                                  InkWell(
                                    onTap: () => Get.off(Login(), id: 0),
                                    child: Text('Sign In', style: TextStyle(
                                      color: colorAccent
                                    )),
                                  )
                                ]
                              )
                            )
                          ],
                        )
                      ),
                      stepStyle: _buildStepStyle(controller.step.value, 0)
                    ),
                    Step(
                      title: Text(''), 
                      content: Form(
                        key: controller.step2FormKey,
                        child: ListView(
                          controller: controller.scrollController,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 80),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Have you worked with a ride-hailing or delivery platform before?', style: TextStyle(
                                  fontWeight: FontWeight.w600
                                )),
                                const SizedBox(height: 8,),
                                FormField<bool>(
                                  validator: (v) {
                                    if (v == null) {
                                      return 'This field is required';
                                    } return null;
                                  },
                                  builder: (FormFieldState<bool> field) {
                                    return Obx(() {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Radio.adaptive(
                                                      value: true, 
                                                      groupValue: controller.pastExp.value, 
                                                      onChanged: (v) {
                                                        field.didChange(v);
                                                        controller.pastExp.value = true;
                                                      }
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('Yes'),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12,),
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Radio.adaptive(
                                                      value: false, 
                                                      groupValue: controller.pastExp.value, 
                                                      onChanged: (v) {
                                                        field.didChange(v);
                                                        controller.pastExp.value = false;
                                                      }
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('No'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (field.hasError) ...[
                                            const SizedBox(height: 12),
                                            Text('${field.errorText}', style: TextStyle(color: Colors.red),)
                                          ]
                                        ]
                                      );
                                    });
                                  }
                                )
                              ],
                            ),
                            const SizedBox(height: 28,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('If yes, which platforms have you worked with?', style: TextStyle(
                                  fontWeight: FontWeight.w600
                                ),),
                                // const SizedBox(height: 8,),
                                FormField<List<String>>(
                                  initialValue: [],
                                  validator: (v) {
                                    if (controller.pastExp.value ?? false) {
                                      if (v!.isEmpty) {
                                        return 'Select a platform';
                                      } return null;
                                    }
                                  },
                                  builder: (FormFieldState<List> field) {
                                    return Obx(() {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Checkbox.adaptive(
                                                      value: controller.platforms.contains('uber'), 
                                                      onChanged: (v) {
                                                        if (v ?? false) {
                                                          controller.platforms.addIf(
                                                            !controller.platforms.contains('uber'), 
                                                            'uber'
                                                          );
                                                        } else {
                                                          controller.platforms.removeWhere((p) => p == 'uber');
                                                        }
                                                        field.didChange(controller.platforms);
                                                      }
                                                    ),
                                                    Text('Uber'),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12,),
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Checkbox.adaptive(
                                                      value: controller.platforms.contains('bolt'), 
                                                      onChanged: (v) {
                                                        if (v ?? false) {
                                                          controller.platforms.addIf(
                                                            !controller.platforms.contains('bolt'),
                                                            'bolt'
                                                          );
                                                        } else {
                                                          controller.platforms.removeWhere((p) => p == 'bolt');
                                                        }

                                                        field.didChange(controller.platforms);
                                                      }
                                                    ),
                                                    Text('Bolt'),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12,),
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Checkbox.adaptive(
                                                      value: controller.platforms.contains('gokada'), 
                                                      onChanged: (v) {
                                                        if (v ?? false) {
                                                          controller.platforms.addIf(
                                                            !controller.platforms.contains('gokada'),
                                                            'gokada'
                                                          );
                                                        } else {
                                                          controller.platforms.removeWhere((p) => p == 'gokada');
                                                        }

                                                        field.didChange(controller.platforms);
                                                      }
                                                    ),
                                                    Text('Gokada'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (field.hasError) ...[
                                            const SizedBox(height: 12,),
                                            Text('${field.errorText}', style: TextStyle(color: Colors.red),)
                                          ]
                                        ],
                                      );
                                    });
                                  }
                                )
                              ],
                            ),
                            const SizedBox(height: 20,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Are you comfortable using mobile apps for navigation and job tracking?', style: TextStyle(
                                  fontWeight: FontWeight.w600
                                ),),
                                const SizedBox(height: 8,),
                                FormField(
                                  validator: (v) {
                                    if (v == null) {
                                      return 'This field is required';
                                    } return null;
                                  },
                                  builder: (FormFieldState<bool> field) {
                                    return Obx(() {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Radio.adaptive(
                                                      value: true, 
                                                      groupValue: controller.tracking.value, 
                                                      onChanged: (v) {
                                                        field.didChange(v);
                                                        controller.tracking.value = true;
                                                      }
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('Yes'),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12,),
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Radio.adaptive(
                                                      value: false, 
                                                      groupValue: controller.tracking.value, 
                                                      onChanged: (v) {
                                                        field.didChange(v);
                                                        controller.tracking.value = false;
                                                      }
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('No'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (field.hasError) ...[
                                            const SizedBox(height: 12,),
                                            Text('${field.errorText}', style: TextStyle(color: Colors.red),)
                                          ]
                                        ],
                                      );
                                    });
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Are you open to completing both rides and delivery requests?', style: TextStyle(
                                  fontWeight: FontWeight.w600
                                ),),
                                const SizedBox(height: 8,),
                                FormField(
                                  validator: (v) {
                                    if (v == null) {
                                      return 'This field is required';
                                    } return null;
                                  },
                                  builder: (FormFieldState<String> field) {
                                    return Obx(() {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Radio.adaptive(
                                                      value: 'all', 
                                                      groupValue: controller.requestTypes.value, 
                                                      onChanged: (v) {
                                                        field.didChange(v);
                                                        controller.requestTypes.value = 'all';
                                                      }
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('Yes'),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12,),
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Radio.adaptive(
                                                      value: 'rides', 
                                                      groupValue: controller.requestTypes.value, 
                                                      onChanged: (v) {
                                                        field.didChange(v);
                                                        controller.requestTypes.value = 'rides';
                                                      }
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('Only rides'),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12,),
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                child: Row(
                                                  children: [
                                                    Radio.adaptive(
                                                      value: 'deliveries', 
                                                      groupValue: controller.requestTypes.value, 
                                                      onChanged: (v) {
                                                        field.didChange(v);
                                                        controller.requestTypes.value = v;
                                                      }
                                                    ),
                                                    const SizedBox(width: 8,),
                                                    Text('On deliveries'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (field.hasError) ...[
                                            const SizedBox(height: 12,),
                                            Text('${field.errorText}', style: TextStyle(color: Colors.red))
                                          ]
                                        ],
                                      );
                                    });
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(height: 40,),
                            SizedBox(
                              height: 60,
                              child: Buttons.text('Continue', onPressed: () {
                                controller.toStep3();
                              }).primary.build(),
                            ),
                            const SizedBox(height: 16,),
                            SizedBox(
                              height: 60,
                              child: Buttons.text('Go back', onPressed: () {
                                controller.step--;
                              }).primary.outlined.build(),
                            )
                          ],
                        ),
                      ),
                      stepStyle: _buildStepStyle(controller.step.value, 1)
                    ),
                    Step(
                      title: Text(''), 
                      content: Form(
                        key: controller.step3FormKey,
                        child: ListView(
                          controller: controller.scrollController,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 80),
                          children: [
                            Text('Upload checklists'),
                            const SizedBox(height: 16,),
                            FormField<int>(
                              initialValue: 0,
                              validator: (v) {
                                if (v! < 1) {
                                  return 'Profile picture required';
                                } return null;
                              },
                              builder: (field) {
                                controller.profilePhotoFieldState = field;
                                return Obx(() => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Material(
                                      child: ListTile(
                                        leading: Icon(TablerIcons.photo, size: 40,),
                                        title: Text('Profile Picture'),
                                        subtitle: Text(
                                          controller.profilePhoto.value != null
                                          ? '1/1' : '0/1'
                                        ),
                                        trailing: controller.profilePhoto.value != null ? CircleAvatar(
                                          radius: 12,
                                          backgroundColor: colorGreen,
                                          foregroundColor: Colors.white,
                                          child: Icon(TablerIcons.check, size: 16,)
                                        ) : null,
                                        shape: controller.checklistIdx.value == 0 ? RoundedRectangleBorder(
                                          side: BorderSide(color: colorPrimary.withValues(alpha: .2))
                                        ) : null,
                                        onTap: () => controller.checklistIdx.value = 0,
                                      ),
                                    ),
                                    if (field.hasError) ...[
                                      const SizedBox(height: 12,),
                                      Text('${field.errorText}', style: TextStyle(color: Colors.red),)
                                    ]
                                  ],
                                ));
                              }
                            ),
                            const SizedBox(height: 8,),
                            FormField<int>(
                              initialValue: 0,
                              validator: (v) {
                                if (v! < 2) {
                                  return 'Driver\'s license is required';
                                } return null;
                              },
                              builder: (field) {
                                controller.licenseFieldState = field;
                                return Obx(() => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: Icon(TablerIcons.photo, size: 40,),
                                      title: Text('Driver\'s License'),
                                      subtitle: Text(
                                        '${controller.licenseSelected}/2'
                                      ),
                                      trailing: controller.licenseSelected == 2 ? CircleAvatar(
                                        radius: 12,
                                        backgroundColor: colorGreen,
                                        foregroundColor: Colors.white,
                                        child: Icon(TablerIcons.check, size: 16,)
                                      ) : null,
                                      shape: controller.checklistIdx.value == 1 ? RoundedRectangleBorder(
                                        side: BorderSide(color: colorPrimary.withValues(alpha: .2))
                                      ) : null,
                                      onTap: () => controller.checklistIdx.value = 1,
                                    ),
                                    if (field.hasError) ...[
                                      const SizedBox(height: 12,),
                                      Text('${field.errorText}', style: TextStyle(color: Colors.red))
                                    ]
                                  ],
                                ));
                              }
                            ),
                            const SizedBox(height: 8,),
                            FormField<int>(
                              initialValue: 0,
                              validator: (v) {
                                if (v! < 4) {
                                  return 'Vehicle photos are required';
                                } return null;
                              },
                              builder: (field) {
                                controller.vehiclePhotoFieldState = field;
                                return Obx(() => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: Icon(TablerIcons.photo, size: 40,),
                                      title: Text('Vehicle Photos'),
                                      subtitle: Text(
                                        '${controller.vehiclePhotoSelected}/4'
                                      ),
                                      trailing: controller.vehiclePhotoSelected == 4 ? CircleAvatar(
                                        radius: 12,
                                        backgroundColor: colorGreen,
                                        foregroundColor: Colors.white,
                                        child: Icon(TablerIcons.check, size: 16,)
                                      ) : null,
                                      shape: controller.checklistIdx.value == 2 ? RoundedRectangleBorder(
                                        side: BorderSide(color: colorPrimary.withValues(alpha: .2))
                                      ) : null,
                                      onTap: () => controller.checklistIdx.value = 2,
                                    ),
                                    if (field.hasError) ...[
                                      const SizedBox(height: 12,),
                                      Text('${field.errorText}', style: TextStyle(color: Colors.red))
                                    ]
                                  ],
                                ));
                              }
                            ),
                            const SizedBox(height: 8,),
                            FormField<int>(
                              initialValue: 0,
                              validator: (v) {
                                if (v! < 1) {
                                  return 'Proof of ownership is required';
                                } return null;
                              },
                              builder: (field) {
                                controller.proofFieldState = field;
                                return Obx(() => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: Icon(TablerIcons.photo, size: 40,),
                                      title: Text('Proof of Ownership'),
                                      subtitle: Text(
                                        controller.ownershipProof.value != null
                                        ? '1/1' : '0/1'
                                      ),
                                      trailing: controller.ownershipProof.value != null ? CircleAvatar(
                                        radius: 12,
                                        backgroundColor: colorGreen,
                                        foregroundColor: Colors.white,
                                        child: Icon(TablerIcons.check, size: 16,)
                                      ) : null,
                                      shape: controller.checklistIdx.value == 3 ? RoundedRectangleBorder(
                                        side: BorderSide(color: colorPrimary.withValues(alpha: .2))
                                      ) : null,
                                      onTap: () => controller.checklistIdx.value = 3,
                                    ),
                                    if (field.hasError) ...[
                                      const SizedBox(height: 12,),
                                      Text('${field.errorText}', style: TextStyle(color: Colors.red))
                                    ]
                                  ],
                                ));
                              }
                            ),
                            const SizedBox(height: 24,),
                            Container(
                              constraints: BoxConstraints(minHeight: 150),
                              child: ResponsiveGridList(
                                listViewBuilderOptions: ListViewBuilderOptions(
                                  controller: controller.scrollController,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero
                                ),
                                minItemWidth: 300, 
                                children: [
                                  if (controller.checklistIdx.value == 0)
                                  if (controller.profilePhoto.value == null)
                                  DottedBorder(
                                    options: RectDottedBorderOptions(
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('Upload Profile Picture', style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700
                                        ),),
                                        const SizedBox(height: 8,),
                                        Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                          fontSize: 12
                                        ), textAlign: TextAlign.center,),
                                        const SizedBox(height: 8,),
                                        Buttons.text('Upload photo', onPressed: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                                            type: FileType.image
                                          );

                                          if (result != null) {
                                            controller.profilePhoto.value = result.files.single;
                                            controller.profilePhotoFieldState.didChange(1);
                                          }
                                        }).white.build()

                                      ],
                                    ),
                                  )
                                  else
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(controller.profilePhoto.value!.path!)
                                        ),
                                        fit: BoxFit.contain
                                      )
                                    ),
                                  ),

                                  if (controller.checklistIdx.value == 1) ...[
                                    if (controller.driversLicense[0] == null)
                                    DottedBorder(
                                      options: RectDottedBorderOptions(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('Upload License (Front)', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700
                                          ),),
                                          const SizedBox(height: 8,),
                                          Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                            fontSize: 12
                                          ), textAlign: TextAlign.center,),
                                          const SizedBox(height: 8,),
                                          Buttons.text('Upload photo', onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.image
                                            );

                                            if (result != null) {
                                              controller.driversLicense[0] = result.files.single;
                                              controller.licenseFieldState.didChange(controller.licenseSelected);
                                            }
                                          }).white.build()

                                        ],
                                      ),
                                    )
                                    else
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(controller.driversLicense[0]!.path!)
                                          ),
                                          fit: BoxFit.contain
                                        )
                                      ),
                                    ),
                                    if (controller.driversLicense[1] == null)
                                    DottedBorder(
                                      options: RectDottedBorderOptions(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('Upload License (Back)', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700
                                          ),),
                                          const SizedBox(height: 8,),
                                          Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                            fontSize: 12
                                          ), textAlign: TextAlign.center,),
                                          const SizedBox(height: 8,),
                                          Buttons.text('Upload photo', onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.image
                                            );

                                            if (result != null) {
                                              controller.driversLicense[1] = result.files.single;
                                              controller.licenseFieldState.didChange(controller.licenseSelected);
                                            }
                                          }).white.build()

                                        ],
                                      ),
                                    )
                                    else
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(controller.driversLicense[1]!.path!)
                                          ),
                                          fit: BoxFit.contain
                                        )
                                      ),
                                    ),
                                  ],

                                  if (controller.checklistIdx.value == 2) ...[
                                    if (controller.vehiclePhotos[0] == null)
                                    DottedBorder(
                                      options: RectDottedBorderOptions(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('Upload Vehicle Photo 1', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700
                                          ),),
                                          const SizedBox(height: 8,),
                                          Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                            fontSize: 12
                                          ), textAlign: TextAlign.center,),
                                          const SizedBox(height: 8,),
                                          Buttons.text('Upload photo', onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.image
                                            );

                                            if (result != null) {
                                              controller.vehiclePhotos[0] = result.files.single;
                                              controller.vehiclePhotoFieldState.didChange(controller.vehiclePhotoSelected);
                                            }
                                          }).white.build()

                                        ],
                                      ),
                                    )
                                    else
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(controller.vehiclePhotos[0]!.path!)
                                          ),
                                          fit: BoxFit.contain
                                        )
                                      ),
                                    ),
                                    if (controller.vehiclePhotos[1] == null)
                                    DottedBorder(
                                      options: RectDottedBorderOptions(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('Upload Vehicle Photo 2', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700
                                          ),),
                                          const SizedBox(height: 8,),
                                          Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                            fontSize: 12
                                          ), textAlign: TextAlign.center,),
                                          const SizedBox(height: 8,),
                                          Buttons.text('Upload photo', onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.image
                                            );

                                            if (result != null) {
                                              controller.vehiclePhotos[1] = result.files.single;
                                              controller.vehiclePhotoFieldState.didChange(controller.vehiclePhotoSelected);
                                            }
                                          }).white.build()

                                        ],
                                      ),
                                    )
                                    else
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(controller.vehiclePhotos[1]!.path!)
                                          ),
                                          fit: BoxFit.contain
                                        )
                                      ),
                                    ),
                                    if (controller.vehiclePhotos[2] == null)
                                    DottedBorder(
                                      options: RectDottedBorderOptions(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('Upload Vehicle Photo 3', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700
                                          ),),
                                          const SizedBox(height: 8,),
                                          Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                            fontSize: 12
                                          ), textAlign: TextAlign.center,),
                                          const SizedBox(height: 8,),
                                          Buttons.text('Upload photo', onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.image
                                            );

                                            if (result != null) {
                                              controller.vehiclePhotos[2] = result.files.single;
                                              controller.vehiclePhotoFieldState.didChange(controller.vehiclePhotoSelected);
                                            }
                                          }).white.build()

                                        ],
                                      ),
                                    )
                                    else
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(controller.vehiclePhotos[2]!.path!)
                                          ),
                                          fit: BoxFit.contain
                                        )
                                      ),
                                    ),
                                    if (controller.vehiclePhotos[3] == null)
                                    DottedBorder(
                                      options: RectDottedBorderOptions(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('Upload Vehicle Photo 4', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700
                                          ),),
                                          const SizedBox(height: 8,),
                                          Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                            fontSize: 12
                                          ), textAlign: TextAlign.center,),
                                          const SizedBox(height: 8,),
                                          Buttons.text('Upload photo', onPressed: () async {
                                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.image
                                            );

                                            if (result != null) {
                                              controller.vehiclePhotos[3] = result.files.single;
                                              controller.vehiclePhotoFieldState.didChange(controller.vehiclePhotoSelected);
                                            }
                                          }).white.build()

                                        ],
                                      ),
                                    )
                                    else
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(controller.vehiclePhotos[3]!.path!)
                                          ),
                                          fit: BoxFit.contain
                                        )
                                      ),
                                    ),
                                  ],

                                  if (controller.checklistIdx.value == 3)
                                  if (controller.ownershipProof.value == null)
                                  DottedBorder(
                                    options: RectDottedBorderOptions(
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('Upload Proof', style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700
                                        ),),
                                        const SizedBox(height: 8,),
                                        Text('Please upload a clear photo in JPG or PNG format', style: TextStyle(
                                          fontSize: 12
                                        ), textAlign: TextAlign.center,),
                                        const SizedBox(height: 8,),
                                        Buttons.text('Upload photo', onPressed: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                                              type: FileType.image
                                            );

                                            if (result != null) {
                                              controller.ownershipProof.value = result.files.single;
                                              controller.proofFieldState.didChange(1);
                                            }
                                        }).white.build()

                                      ],
                                    ),
                                  )
                                  else
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(controller.ownershipProof.value!.path!)
                                        ),
                                        fit: BoxFit.contain
                                      )
                                    ),
                                  ),
                                ]
                              ),
                            ),
                            const SizedBox(height: 40,),
                              SizedBox(
                                height: 60,
                                child: Buttons.text('Continue', onPressed: () {
                                  controller.toStep4();
                                }).primary.build(),
                              ),
                              const SizedBox(height: 16,),
                              SizedBox(
                                height: 60,
                                child: Buttons.text('Go back', onPressed: () {
                                  controller.step--;
                                }).primary.outlined.build(),
                              )
                          ],
                        ),
                      ),
                      stepStyle: _buildStepStyle(controller.step.value, 2)
                    ),
                    Step(
                      title: Text(''), 
                      content: Form(
                        key: controller.step4FormKey,
                        child: ListView(
                          controller: controller.scrollController,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 80),
                          children: [
                            Container(
                              constraints: BoxConstraints(minHeight: 60),
                              decoration: BoxDecoration(
                                color: colorPrimary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: CustomDropdown(
                                hint: 'Select Vehicle Type',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Vehicle type is required';
                                  } return null;
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 'car',
                                    child: Text('Car')
                                  ),
                                  DropdownMenuItem(
                                    value: 'van',
                                    child: Text('Van')
                                  ),
                                  DropdownMenuItem(
                                    value: 'bike',
                                    child: Text('Bike')
                                  )
                                ],
                                onChanged: (v) {
                                  controller.vehicleType = v;
                                },
                              ),
                            ),
                            const SizedBox(height: 16,),
                            ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 60),
                              child: CustomTextField(
                                controller: controller.makeModelCtrl,
                                label: 'Make and Model',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Make and Model are required';
                                  } return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16,),
                            ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 60),
                              child: CustomTextField(
                                controller: controller.yearOfManufactureCtrl,
                                label: 'Year of Manufacture',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Year of manufacture is required';
                                  } return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16,),
                            ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 60),
                              child: CustomTextField(
                                controller: controller.plateNumCtrl,
                                label: 'License Plate Number',
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'License plate is required';
                                  } return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 40,),
                            SizedBox(
                              height: 60,
                              child: Buttons.text('Sign Up', onPressed: () {
                                controller.signup();
                              }).primary.build(),
                            ),
                            const SizedBox(height: 16,),
                            SizedBox(
                              height: 60,
                              child: Buttons.text('Go back', onPressed: () {
                                controller.step--;
                              }).primary.outlined.build(),
                            )
                          ],
                        ),
                      ),
                      stepStyle: _buildStepStyle(controller.step.value, 3)
                    )
                  ]
                ),
              );
            }

            if (controller.stage.value == SignupStage.verify) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  children: [
                    Image.asset('assets/images/app_logo.png', width: 100, height: 100,),
                    const SizedBox(height: 16,),
                    Align(
                      alignment: Alignment.center,
                      child: Text('Enter OTP', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700
                      ))
                    ),
                    const SizedBox(height: 16,),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 450,
                        child: OTP(
                          formKey: controller.otpFormKey,
                          tokenController: controller.otpCtrl,
                          onSubmit: () => controller.verifyToken(),
                        )
                      )
                    ),
                    const SizedBox(height: 16,),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF333333)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Did\'t get an OTP? '),
                          InkWell(
                            onTap: () => controller.resendOTP(),
                            child: Text('Resend OTP', style: TextStyle(
                              color: colorAccent
                            )),
                          )
                        ]
                      )
                    ),
                  ],
                ),
              );
            }

            return Container();
          }),
          /* Loader overlay */
          Obx(() {
            if (controller.processing.value) {
              return buildLoader();
            }

            return Container();
          })
        ],
      )
    );
  }

  StepStyle _buildStepStyle(int stepIdx, int idx) {
    return StepStyle(
      color: stepIdx >= idx ? colorPrimary : Colors.transparent,
      border: Border.all(color: colorPrimary)
    );
  }
}

class SignupController extends GetxController {
  RxInt step = 0.obs;
  Rx<SignupStage> stage = SignupStage.initial.obs;
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();
  final step4FormKey = GlobalKey<FormState>();
  Rx<AutovalidateMode> validateMode = AutovalidateMode.disabled.obs;
  final HttpService http = Get.find();
  RxBool hidePassword = true.obs;
  RxBool processing = false.obs;

  ScrollController scrollController = ScrollController();

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController licenseNoCtrl;
  late TextEditingController passwordCtrl;
  PhoneNumber phoneData = PhoneNumber();
  RxBool agreeTerms = false.obs;

  Rx<bool?> pastExp = Rxn();
  RxList<String> platforms = RxList.empty();
  Rx<bool?> tracking = Rxn();
  Rx<String?> requestTypes = Rxn();

  RxInt checklistIdx = 0.obs;
  late Rx<PlatformFile?> profilePhoto;
  late RxList<PlatformFile?> driversLicense;
  late RxList<PlatformFile?> vehiclePhotos;
  late Rx<PlatformFile?> ownershipProof;
  FormFieldState<int> profilePhotoFieldState = FormFieldState();
  FormFieldState<int> licenseFieldState = FormFieldState();
  FormFieldState<int> vehiclePhotoFieldState = FormFieldState();
  FormFieldState<int> proofFieldState = FormFieldState();

  String? vehicleType;
  late TextEditingController makeModelCtrl;
  late TextEditingController yearOfManufactureCtrl;
  late TextEditingController plateNumCtrl;

  late Map<String, dynamic> regPersonal;
  late Map<String, dynamic> regExp;
  late Map<String, dynamic> regUpload;
  late Map<String, dynamic> regVehicle;

  final otpFormKey = GlobalKey<FormState>();
  late TextEditingController otpCtrl;

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    licenseNoCtrl = TextEditingController();
    passwordCtrl = TextEditingController();

    profilePhoto = Rxn<PlatformFile>();
    driversLicense = RxList.filled(2, null);
    vehiclePhotos = RxList.filled(4, null);
    ownershipProof = Rxn<PlatformFile>();

    makeModelCtrl = TextEditingController();
    yearOfManufactureCtrl = TextEditingController();
    plateNumCtrl = TextEditingController();

    otpCtrl = TextEditingController();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    licenseNoCtrl.dispose();
    passwordCtrl.dispose();
    makeModelCtrl.dispose();
    yearOfManufactureCtrl.dispose();
    plateNumCtrl.dispose();
    otpCtrl.dispose();
    super.onClose();
  }

  int get licenseSelected {
    return driversLicense.where((l) => l != null).length;
  }

  int get vehiclePhotoSelected {
    return vehiclePhotos.where((v) => v != null).length;
  }

  void toStep2() async {
    if (step1FormKey.currentState!.validate()) {
      processing.value = true;

      final names = nameCtrl.text.trim().split(RegExp(r'\s{1,}'));
      regPersonal = {
        'personal[firstName]': names[0],
        'personal[lastName]': names.sublist(1).join(' '),
        'personal[email]': emailCtrl.text,
        'personal[phoneNumber]': phoneData.phoneNumber,
        'personal[licenseNumber]': licenseNoCtrl.text,
        'personal[password]': passwordCtrl.text,
        'personal[countryCode]': phoneData.isoCode
      };
      print('Reg Personal: $regPersonal');


      /*final result = await http.signup(data);
      if (result is String) {
        PopupManager.error(
          title: 'Registration Failed!',
          message: result
        );
      } else {
        PopupManager.success(
          title: 'Registration Successful',
          message: 'Verify account to continue.'
        );
      }*/
      step.value = 1;

      processing.value = false;
    } else {
      validateMode.value = AutovalidateMode.onUserInteraction;
    }
  }

  void toStep3() async {
    if (step2FormKey.currentState!.validate()) {
      regExp = {
        'experience[previousExperience]': pastExp.value,
        /*...platforms
          .map((f) => 'experience[previousPlatform][]')
          .toList()
          .asMap(),*/
        // for (var p in platforms) 'experience[previousPlatform][]': p,
        'experience[previousPlatform][]': platforms,
        'experience[navigationTrackingConsent]': tracking.value,
        'experience[requestTypes]': requestTypes.value
      };
      print('Reg Exp: $regExp');

      step.value = 2;
    }
  }

  void toStep4() async {
    if (step3FormKey.currentState!.validate()) {
      final licenseImages = driversLicense.map((lic) {
        final file = File(lic!.path!);
        return MultipartFile(
          file, 
          filename: lic.name
        );
      }).toList();

      final vehicleImages = vehiclePhotos.map((v) {
        final file = File(v!.path!);
        return MultipartFile(
          file, 
          filename: v.name
        );
      }).toList();

      final file = File(ownershipProof.value!.path!);
      final regDocs = MultipartFile(
        file, 
        filename: ownershipProof.value!.name
      );

      regUpload = {
        'licenseImages': licenseImages,
        'vehicleImages': vehicleImages,
        'registrationDocuments': [
          regDocs,
          regDocs
        ],
        'profileImage': MultipartFile(
          File(profilePhoto.value!.path!), 
          filename: profilePhoto.value!.name
        )
      };

      step.value = 3;
    }
  }

  void signup() async {
    if (step4FormKey.currentState!.validate()) {
      final makeModel = makeModelCtrl.text.split(' ');
      print('MM: $makeModel');
      regVehicle = {
        'vehicleInfo[make]': makeModel[0],
        'vehicleInfo[model]': makeModel[1],
        'vehicleInfo[plateNumber]': plateNumCtrl.text,
        'vehicleInfo[year]': yearOfManufactureCtrl.text,
        'vehicleInfo[color]': 'Black',
        'vehicleInfo[category]': '6848996c6f6c33af02dac315',
        'vehicleInfo[capacity]': 4,
      };

      print('regV: $regVehicle');

      final data = {
        ...regPersonal,
        ...regExp,
        ...regUpload,
        ...regVehicle
      };

      final result = await http.signup(data);
      if (result is String) {
        PopupManager.error(
          title: 'Registration Failed!',
          message: result
        );
      } else {
        PopupManager.success(
          title: 'Registration Successful',
          message: 'Verify account to continue'
        );
      }
    }
  }

  void verifyToken() async {
    if (otpFormKey.currentState!.validate()) {
      processing.value = true;
      final result = await http.verifyEmail(emailCtrl.text, otpCtrl.text);
      if (result is String) {
        PopupManager.error(
          title: 'Failed',
          message: result
        );
      } else {
        PopupManager.success(
          title: 'Success',
          message: 'Email verification completed.'
        );

        Get.off(Login(), id: 0);
      }

      processing.value = false;
    }
  }

  void resendOTP() async {
    if (true) {
      processing.value = true;
      final result = await http.resendOTP(emailCtrl.text);
      if (result) {
        PopupManager.success(
          title: 'OTP sent',
          message: 'OTP was sent to your email address.'
        );
      } else {
        PopupManager.error(
          title: 'Failed',
          message: 'Error sending OTP.'
        );
      }

      processing.value = false;
    }
  }
}

enum SignupStage {
  initial,
  verify
}