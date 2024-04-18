import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:iosish_shaker/iosish_shaker.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';

class Register extends StatefulWidget{
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin  {

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ShakerController shakeController = ShakerController();

  late final GifController _gifController;

  @override
  void initState() {
    _gifController = GifController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                        Shaker(controller: shakeController, child: Gif(
                          controller: _gifController,
                          image: const AssetImage("IdentificationCard.webp"),
                          width: min(maxWidth, constraints.maxWidth) * 0.5,
                          fps: 20,
                          autostart: Autostart.once,
                          placeholder: (BuildContext context){
                            return const CircularProgressIndicator();
                          },
                        )),
                        SizedBox(
                          height: min(maxWidth, constraints.maxWidth) * 0.15,
                        ),
                        MaterialTextField(
                          keyboardType: TextInputType.text,
                          hint: "Email",
                          labelText: "Email",
                          theme: FilledOrOutlinedTextTheme(
                            enabledColor: Colors.grey,
                            focusedColor: Colors.grey.shade400,
                            fillColor: Colors.transparent,
                          ),
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.alternate_email),
                          validator: FormValidation.emailTextField,
                        ),
                        SizedBox(
                          height: min(maxWidth, constraints.maxWidth) * 0.025,
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
                          validator: FormValidation.requiredTextField,
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
                        ElevatedButton(
                          onPressed: onSubmitBtnPressed,
                          child: Text('Register', textScaler: TextScaler.linear(1.2), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
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