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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

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
            final title;
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
                                                      value: false, 
                                                      onChanged: (v) {}
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
                                                      value: false, 
                                                      onChanged: (v) {}
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
                      content: ListView(
                        controller: controller.scrollController,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 80),
                        children: [
                          Text('Upload checklists'),
                          const SizedBox(height: 16,),
                          ListTile(
                            leading: Icon(TablerIcons.photo, size: 40,),
                            title: Text('Profile Picture'),
                            subtitle: Text('1/1'),
                            trailing: Icon(TablerIcons.fidget_spinner),
                          ),
                          const SizedBox(height: 8,),
                          ListTile(
                            leading: Icon(TablerIcons.photo, size: 40,),
                            title: Text('Driver\'s License'),
                            subtitle: Text('0/2'),
                            trailing: Icon(TablerIcons.fidget_spinner),
                          ),
                          const SizedBox(height: 8,),
                          ListTile(
                            leading: Icon(TablerIcons.photo, size: 40,),
                            title: Text('Vehicle Photos'),
                            subtitle: Text('0/4'),
                            trailing: Icon(TablerIcons.fidget_spinner),
                          ),
                          const SizedBox(height: 8,),
                          ListTile(
                            leading: Icon(TablerIcons.photo, size: 40,),
                            title: Text('Proof of Ownership'),
                            subtitle: Text('0/1'),
                            trailing: Icon(TablerIcons.fidget_spinner),
                          ),
                          const SizedBox(height: 24,),
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
                                Buttons.text('Upload photo', onPressed: () {
                                  
                                }).white.build()

                              ],
                            ),
                          ),
                          const SizedBox(height: 40,),
                            SizedBox(
                              height: 60,
                              child: Buttons.text('Continue', onPressed: () {

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
                      stepStyle: _buildStepStyle(controller.step.value, 2)
                    ),
                    Step(
                      title: Text(''), 
                      content: ListView(
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
                              value: 1, 
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Select vehicle type')
                                )
                              ]
                            ),
                          ),
                          const SizedBox(height: 16,),
                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 60),
                            child: CustomTextField(
                              label: 'Make and Model',
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'This field is required';
                                } return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16,),
                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 60),
                            child: CustomTextField(
                              label: 'Year of Manufacture',
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'This field is required';
                                } return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16,),
                          ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 60),
                            child: CustomTextField(
                              label: 'License Plate Number',
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'This field is required';
                                } return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 40,),
                          SizedBox(
                            height: 60,
                            child: Buttons.text('Sign Up', onPressed: () {

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
    otpCtrl = TextEditingController();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    licenseNoCtrl.dispose();
    passwordCtrl.dispose();
    otpCtrl.dispose();
    super.onClose();
  }

  void toStep2() async {
    if (step1FormKey.currentState!.validate()) {
      processing.value = true;

      final names = nameCtrl.text.trim().split(RegExp(r'\s{1,}'));
      final personalInfo = {
        'personal[firstBame]': names[0],
        'personal[lastName]': names.sublist(1).join(' '),
        'personal[email]': emailCtrl.text,
        'personal[phoneNumber]': phoneData.phoneNumber,
        'personal[licenseNumber]': licenseNoCtrl.text,
        'personal[password]': passwordCtrl.text,
        // 'countryCode': phoneData.isoCode
      };
      print('Reg Personal: $personalInfo');

      final experienceInfo = {

      };


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
    print('to step 3');

    } else {
    print('step 2 not valid');

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