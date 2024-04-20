import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iosish_shaker/iosish_shaker.dart';
import 'package:lottie/lottie.dart';

import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Constants.dart';
import '../utils/GreenAlert.dart';
import '../utils/Validation.dart';

class Login extends StatefulWidget{
  final String? ref;

  const Login({Key? key, required this.ref}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin  {
  String? ref;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ShakerController shakeController = ShakerController();

  Key phoneKey = GlobalKey();

  late final AnimationController _gifController;

  final PhoneController phoneController = PhoneController(initialValue: PhoneNumber.parse("+7"));

  @override
  void initState() {
    _gifController = AnimationController(vsync: this);
    super.initState();
  }

  String? phoneError = null;
  String? passError = null;

  onSubmitBtnPressed() async {
    phoneError = null;
    passError = null;
    if (_key.currentState?.validate() == true) {
      _gifController.forward(from: 0.0);
      try {
        Map data = {
          "phone": "+${phoneController.value.countryCode}${phoneController.value.nsn}",
          "password": _passwordController.text,
        };

        final response = await http.post(
          Uri.parse(BACKEND + 'auth/login'),
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
              case "login" : {
                phoneError = jsonResp["explain"];
                var value = phoneController.value;
                phoneController.value = phoneController.initialValue;
                phoneController.value = value;
                break;
              }
              case "password" : {
                passError = jsonResp["explain"];
                var value = _passwordController.value;
                _passwordController.value = TextEditingValue();
                _passwordController.value = value;
                break;
              }
            }
            shakeController.shake();
            _key.currentState?.validate();
          } else {
            html.window.localStorage["authToken"] = jsonResp["token"];

            context.go("/");
          }

        } catch (e) {
          print(e);
          return;
        }
      } catch (e) {
        print(e);
      }
    } else {
      shakeController.shake();
    }
  }


  String? passValidator(String? password) {
    if (passError != null) return passError;
    var ph = FormValidation.requiredTextField(password);
    if (ph == null && phoneError == null) return null;
    if (ph != null) return ph;
    return null;
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
                              "assets/Cup.json",
                              controller: _gifController,
                              width: min(maxWidth, constraints.maxWidth) * 0.6,
                              frameRate: const FrameRate(60),
                              repeat: true,
                              onLoaded: (composition) {
                                // Configure the AnimationController with the duration of the
                                // Lottie file and start the animation.
                                _gifController
                                  ..duration = composition.duration
                                  ..forward()
                                  ..repeat()
                                ;
                              },
                              filterQuality: FilterQuality.low
                          )
                          ),
                          widget.ref != null ? GreenAlert(
                            message: 'Registered successfully!',
                            width: min(maxWidth, constraints.maxWidth) - 40,
                          ) : Container(),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
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
                            key: GlobalKey<FormState>(),
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            hint: "Password",
                            labelText: "Password",
                            errorText: passError,
                            theme: FilledOrOutlinedTextTheme(
                              enabledColor: Colors.grey,
                              focusedColor: Colors.grey.shade400,
                              fillColor: Colors.transparent,
                            ),
                            onChanged: (String a) {
                              _key.currentState?.validate();
                              passError = null;
                            },
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock),
                            validator: passValidator,
                          ),
                          SizedBox(
                            height: min(maxWidth, constraints.maxWidth) * 0.05,
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.02,
                          ),
                          ElevatedButton(
                            onPressed: onSubmitBtnPressed,
                            child: Text('Login', textScaler: TextScaler.linear(1.2), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.03,
                          ),
                          GestureDetector(
                            child: Text("Or register...", style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline),),
                            onTap: () {
                              context.go("/register");
                            },
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
                          Text("Natus Coders for Oggetto, 2024")
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

}