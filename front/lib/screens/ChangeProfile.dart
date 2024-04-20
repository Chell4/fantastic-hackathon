import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:io' as io;
import 'dart:io';
import 'dart:math';

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:front/main.dart';
import 'package:go_router/go_router.dart';
import 'package:iosish_shaker/iosish_shaker.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../utils/Constants.dart';
import '../utils/Validation.dart';

class ChangeProfile extends StatefulWidget {
  const ChangeProfile({Key? key});

  @override
  State<ChangeProfile> createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _keey = GlobalKey<FormState>();

  final TextEditingController _firstController = TextEditingController(text: MyHomePage.instance.currentUser!.firstName!);
  final TextEditingController _lastController = TextEditingController(text: MyHomePage.instance.currentUser!.lastName!);
  final TextEditingController _passwordController = TextEditingController();

  final ShakerController shakeController = ShakerController();

  Key phoneKey = GlobalKey();

  late final AnimationController _gifController;

  final PhoneController phoneController = PhoneController(initialValue: PhoneNumber.parse(MyHomePage.instance!.currentUser!.phone!),);

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

  onSubmitBtnPressed() async {
    phoneError = null;
    passError = null;
    try {
      Map data = {
        "phone": "+${phoneController.value.countryCode}${phoneController.value.nsn}",
        "first_name": _firstController.text,
        "last_name": _lastController.text,
      };

      if (_passwordController.text.isNotEmpty && _passwordController.text.length >= 8)
        data["password"] = _passwordController.text;

      print(json.encode(data));

      final response = await http.post(
        Uri.parse(BACKEND + 'profile'),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}"
        },
        body: json.encode(data),
      );
      var dataa = response;

      print("!-!-!-");
      if (response.statusCode == HttpStatus.ok) {
        context.pop();
        context.pushReplacement("/");
      }
    } catch (e) {
      print(e);
    }
    // context.go("/login", extra: {"ref": "register"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = max(500, MediaQuery.of(context).size.width * 0.3);

          DropzoneViewController controller;
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width -
                  MediaQuery.of(context).size.width / 15,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.height / 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                  ),
                  body: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width / 15 -
                                40,
                            height: (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).size.height / 15) /
                                4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                DropzoneView(
                                  operation: DragOperation.copy,
                                  cursor: CursorType.grab,
                                  onCreated: (DropzoneViewController ctrl) =>
                                  controller = ctrl,
                                  onError: (String? ev) =>
                                      print('Error: $ev'),
                                  onDrop: (ev) =>
                                      print('Drop: ${(ev as html.File).type}'),
                                ),
                                Center(
                                  child: Text("Drop image here"),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: min(maxWidth, constraints.maxWidth) * 0.05,
                        ),
                        PhoneFormField(
                            key: phoneKey,
                            controller: phoneController,
                            validator: PhoneValidator.compose([
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
                                width: (min(maxWidth, constraints.maxWidth) - 40),
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
                                ),
                              ),
                              SizedBox(
                                width: (min(maxWidth, constraints.maxWidth) - 40),
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
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Apply Changes',
                            textScaler: TextScaler.linear(1.2),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}