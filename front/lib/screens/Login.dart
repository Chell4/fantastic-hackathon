import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iosish_shaker/iosish_shaker.dart';
import 'package:lottie/lottie.dart';

import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';

import '../utils/Validation.dart';

class Login extends StatefulWidget{
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin  {

  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ShakerController shakeController = ShakerController();

  late final AnimationController _gifController;

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
                              "Cup.json",
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
                              filterQuality: FilterQuality.medium
                          )
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
                          MaterialTextField(
                            keyboardType: TextInputType.text,
                            hint: "Login",
                            labelText: "Login",
                            theme: FilledOrOutlinedTextTheme(
                              enabledColor: Colors.grey,
                              focusedColor: Colors.grey.shade400,
                              fillColor: Colors.transparent,
                            ),
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.person),
                            validator: Validation.requiredLogin,
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
                            height: constraints.maxHeight * 0.15,
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

  onSubmitBtnPressed() {
    if (_key.currentState?.validate() == true) {
      _gifController.forward(from: 0.0);
      // TO BACKEND
    } else {
      shakeController.shake();
    }
  }
}