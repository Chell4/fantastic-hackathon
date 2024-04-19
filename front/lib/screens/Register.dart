import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iosish_shaker/iosish_shaker.dart';
import 'package:lottie/lottie.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../utils/Validation.dart';

class Register extends StatefulWidget{
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin  {

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ShakerController shakeController = ShakerController();

  late final AnimationController _gifController;

  final PhoneController phoneController = PhoneController(initialValue: PhoneNumber.parse("+7"));

  @override
  void initState() {
    _gifController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double maxWidth = max(500, MediaQuery
                .of(context)
                .size
                .width * 0.3);

            return Center(
              child: Container(
                width: min(maxWidth, constraints.maxWidth),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Form(
                    key: _key,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Shaker(controller: shakeController, child:
                          Lottie.asset(
                              "IdentificationCard.json",
                              controller: _gifController,
                              width: min(maxWidth, constraints.maxWidth) * 0.6,
                              frameRate: const FrameRate(60),
                              onLoaded: (composition) {
                                // Configure the AnimationController with the duration of the
                                // Lottie file and start the animation.
                                _gifController
                                  ..duration = composition.duration
                                  ..forward()
                                  ..repeat();
                              },
                              filterQuality: FilterQuality.medium,
                          )
                          ),
                          SizedBox(
                            height: min(maxWidth, constraints.maxWidth) * 0.05,
                          ),
                          PhoneFormField(
                            controller: phoneController,
                            validator: PhoneValidator.compose(
                                [PhoneValidator.required(context), PhoneValidator.validMobile(context)]),
                            enabled: true,
                            isCountrySelectionEnabled: true,
                            isCountryButtonPersistent: true,

                            countryButtonStyle: CountryButtonStyle(
                                showDropdownIcon: false,
                              showDialCode: true,
                              showFlag: true,
                              showIsoCode: false
                            ),

                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            )
                            // + all parameters of TextField
                            // + all parameters of FormField
                            // ...
                          ),
                          SizedBox(
                            height: min(maxWidth, constraints.maxWidth) * 0.025,
                          ),
                          MaterialTextField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            hint: "Password",
                            labelText: "Password",
                            theme: FilledOrOutlinedTextTheme(
                              enabledColor: Colors.grey,
                              focusedColor: Colors.grey.shade400,
                              fillColor: Colors.transparent,
                            ),
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock),
                            validator: FormValidation.requiredTextField,
                          ),
                          SizedBox(
                            height: min(maxWidth, constraints.maxWidth) * 0.025,
                          ),
                          Card(
                            clipBehavior: Clip.none,
                            borderOnForeground: false,
                            shadowColor: Colors.transparent,
                            color: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            margin: EdgeInsets.zero,
                            child: Wrap(
                              clipBehavior: Clip.hardEdge,
                              direction: Axis.horizontal,
                              spacing: 8.0,
                              runSpacing: 0.0,
                              children: [
                                SizedBox(
                                  width: (min(maxWidth, constraints.maxWidth) - 40) / 2 - 4,
                                  child: MaterialTextField(
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: true,
                                    hint: "First Name",
                                    labelText: "First Name",
                                    theme: FilledOrOutlinedTextTheme(
                                      enabledColor: Colors.grey,
                                      focusedColor: Colors.grey.shade400,
                                      fillColor: Colors.transparent,
                                    ),

                                    textInputAction: TextInputAction.next,
                                    validator: FormValidation.requiredTextField,
                                  ),
                                ),
                                SizedBox(
                                  width: (min(maxWidth, constraints.maxWidth) - 40) / 2 - 4,
                                  child: MaterialTextField(
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: true,
                                    hint: "Last Name",
                                    labelText: "Last Name",
                                    theme: FilledOrOutlinedTextTheme(
                                      enabledColor: Colors.grey,
                                      focusedColor: Colors.grey.shade400,
                                      fillColor: Colors.transparent,
                                    ),

                                    textInputAction: TextInputAction.next,
                                    validator: FormValidation.requiredTextField,
                                  ),
                                )
                              ],

                            ),
                          ),
                          SizedBox(
                            height: min(maxWidth, constraints.maxWidth) * 0.05,
                          ),
                          ElevatedButton(
                            onPressed: onSubmitBtnPressed,
                            child: Text('Register', textScaler: TextScaler.linear(1.2), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: min(maxWidth, constraints.maxWidth) * 0.025,
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go("/login");
                            },
                            child: Text("Or sign in...", style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline),),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.15,
                          ),
                          const Text("Natus Coders for Oggetto, 2024")
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  onSubmitBtnPressed() {
    if (_key.currentState?.validate() == true) {
      _gifController.forward(from: 0.0);
      // TO BACKEND
    } else {
      shakeController.shake();
    }
  }
}