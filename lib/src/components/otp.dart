
import 'package:aru/src/components/button.dart';
import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTP extends StatelessWidget {
  const OTP({
    super.key,
    this.length = 6,
    this.formKey, 
    this.validateMode,
    this.tokenController,
    this.onCompleted,
    this.submitText = 'Verify',
    this.onSubmit,
    this.resendCallback
  });

  final GlobalKey<FormState>? formKey;
  final AutovalidateMode? validateMode;
  final TextEditingController? tokenController;
  final void Function(String)? onCompleted;
  final String submitText;
  final void Function()? onSubmit;
  final void Function()? resendCallback;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: validateMode,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Enter the OTP code sent to your registered email address',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25,),
              PinCodeTextField(
                controller: tokenController,
                autovalidateMode: validateMode ?? AutovalidateMode.disabled,
                autoDisposeControllers: false,
                appContext: context, 
                keyboardType: TextInputType.number,
                length: length, 
                cursorColor: Colors.grey,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                enableActiveFill: true,
                pinTheme: PinTheme.defaults(
                  shape: PinCodeFieldShape.box,
                  fieldHeight: 70,
                  fieldWidth: 56,
                  borderRadius: BorderRadius.circular(12),
                  inactiveColor: colorPrimary.withValues(alpha: 0.05),
                  inactiveFillColor: colorPrimary.withValues(alpha: 0.05),
                  activeFillColor: colorPrimary.withValues(alpha: 0.05),
                  selectedFillColor: colorPrimary.withValues(alpha: 0.05),
                  inactiveBorderWidth: 1,
                  activeColor: colorPrimary,
                  activeBorderWidth: 1,
                  selectedColor: colorPrimary,
                  selectedBorderWidth: 1,
                  errorBorderColor: Colors.red,
                  errorBorderWidth: 1
                ),
                validator: (v) {
                  v?.trim();
                  if (v == null || v.isEmpty || v.length < length) {
                    return 'Please enter verification code';
                  } return null;
                },
                onChanged: (v) => {},
                onCompleted: onCompleted,
                separatorBuilder: (context, index) => SizedBox(width: 14.5,),
              )
            ],
          ),
          SizedBox(height: 22,),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: Buttons.text(
              submitText,
              onPressed: () {
                FocusScopeNode focus = FocusScope.of(context);
                if (!focus.hasPrimaryFocus) {
                  focus.unfocus();
                }

                if (onSubmit != null) {
                  onSubmit!();
                }
              }
            ).primary.build()
          )
        ]
      )
    );
  }
}