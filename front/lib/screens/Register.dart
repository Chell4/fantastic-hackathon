import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:js_util';
import 'dart:math';
import 'dart:ui';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iosish_shaker/iosish_shaker.dart';
import 'package:lottie/lottie.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../utils/Constants.dart';
import '../utils/Validation.dart';

class Register extends StatefulWidget{
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin  {

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  final ShakerController shakeController = ShakerController();

  Key phoneKey = GlobalKey();

  late final AnimationController _gifController;

  final PhoneController phoneController = PhoneController(initialValue: PhoneNumber.parse("+7"));

  String? phoneError = null;
  String? passError = null;

  @override
  void initState() {
    _gifController = AnimationController(vsync: this);
    super.initState();
  }

  String? passValidator(String? password) {
    if (passError != null) return passError;
    var ph = FormValidation.requiredTextField(password);
    if (ph == null && phoneError == null) return null;
    if (ph != null) return ph;
    return null;
  }

  String? passValidator2(String? password) {
    if (passError != null) return passError;
    var ph = FormValidation.requiredTextField(password);
    if (ph != null) return ph;
    if (_passwordController2.value.text != _passwordController.value.text) {
      return "Passwords are not matching";
    }
    return null;
  }

  onSubmitBtnPressed() async {
    phoneError = null;
    passError = null;
    if (_key.currentState?.validate() == true) {
      _gifController.forward(from: 0.0);
      try {


        Map data = {
          "phone": "+${phoneController.value.countryCode}${phoneController.value.nsn}",
          "password": _passwordController.text,
          "first_name": _firstController.text,
          "last_name": _lastController.text,
        };

        print(json.encode(data));

        final response = await http.post(
          Uri.parse(BACKEND + 'auth/register'),
          headers: <String, String>{
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: json.encode(data), // Передаем JSON-тело запроса
        );
        var dataa = response;

        try {
          var jsonResp = jsonDecode(dataa.body) as Map<String, dynamic>;
          if (jsonResp.containsKey("reason")) {
            switch (jsonResp["reason"]) {
              case "phone_exist" : {
                phoneError = jsonResp["explain"];
                var value = phoneController.value;
                phoneController.value = phoneController.initialValue;
                phoneController.value = value;
                break;
              }
            }
            shakeController.shake();
            _key.currentState?.validate();
            return;
          }
        } catch (e) {
          print(e);
          return;
        }
      } catch (e) {
        print(e);
      }
      context.go("/login", extra: {"ref": "register"});
    } else {
      shakeController.shake();
    }
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

            return Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 237, 180, 0),
              ),
              child: Center(
                child: Container(
                  width: min(maxWidth, constraints.maxWidth),
                  height: constraints.maxHeight - 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Цвет тени
                        spreadRadius: 3, // Радиус размытия тени
                        blurRadius: 7, // Радиус размытия тени
                        offset: Offset(0, 3), // Смещение тени по горизонтали и вертикали
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                    child: Form(
                      key: _key,
                      child: SingleChildScrollView(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Shaker(controller: shakeController, child:
                            Lottie.asset(
                              "assets/IdentificationCard.json",
                              controller: _gifController,
                              width: min(maxWidth, constraints.maxWidth) * 0.5,
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
                                key: phoneKey,
                                controller: phoneController,
                                validator: PhoneValidator.compose(
                                    [
                                      PhoneValidator.required(context),
                                      PhoneValidator.validMobile(context),
                                      <String>(String phone) {
                                        return phoneError;
                                      }
                                    ]),
                                enabled: true,
                                isCountrySelectionEnabled: true,
                                isCountryButtonPersistent: true,

                                onChanged: (PhoneNumber a) {
                                  phoneError = null;
                                },

                                countryButtonStyle: const CountryButtonStyle(
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
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              hint: "Password",
                              labelText: "Password",
                              theme: FilledOrOutlinedTextTheme(
                                enabledColor: Colors.grey,
                                focusedColor: Colors.grey.shade400,
                                fillColor: Colors.transparent,
                              ),
                              errorText: passError,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.lock),
                              validator: passValidator,
                            ),
                            SizedBox(
                              height: min(maxWidth, constraints.maxWidth) * 0.025,
                            ),
                            MaterialTextField(
                              controller: _passwordController2,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              hint: "Confirm Password",
                              labelText: "Confirm Password",
                              theme: FilledOrOutlinedTextTheme(
                                enabledColor: Colors.grey,
                                focusedColor: Colors.grey.shade400,
                                fillColor: Colors.transparent,
                              ),
                              errorText: passError,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.lock),
                              validator: passValidator2,
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
                                    width: (min(maxWidth, constraints.maxWidth) - 40) / 2 - 30,
                                    child: MaterialTextField(
                                      controller: _firstController,
                                      keyboardType: TextInputType.name,
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
                                    width: (min(maxWidth, constraints.maxWidth) - 40) / 2 - 30,
                                    child: MaterialTextField(
                                      controller: _lastController,
                                      keyboardType: TextInputType.name,
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
                              height: min(maxWidth, constraints.maxWidth) * 0.025,
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
                            )
                          ],
                        ),
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
}