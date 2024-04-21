import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'dart:html' as html;
import 'package:front/entities/AvatarImage.dart';
import 'package:front/screens/Admin.dart';
import 'package:front/screens/ChangeProfile.dart';
import 'package:front/utils/Constants.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:front/screens/Login.dart';
import 'package:front/screens/Register.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:url_strategy/url_strategy.dart';

import 'entities/Coffee.dart';
import 'entities/User.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NACO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 222, 0)),
        useMaterial3: true,
        fontFamily: "Montserrat",
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.1,
          fontSizeDelta: 1.5,
        ),
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      routerConfig: router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  static _MyHomePageState? instance;

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final GoRouter router = GoRouter(routes: [
  GoRoute(path: '/', name: "Home", builder: (_, __) {
    User.updateProfile();
    return MyHomePage();
  }),
  GoRoute(path: '/login', name: "Login", builder: (_, __) {
    Map<String, dynamic>? args =
    __.extra as Map<String, dynamic>?;
    return Login(ref: args?["ref"]);
  }),
  GoRoute(path: '/register', name: "Register", builder: (_, __) => Register()),
  GoRoute(path: '/changeProfile', name: "ChangeProfile", builder: (_, __) => ChangeProfile()),
  GoRoute(path: '/admin', name: "Admin", builder: (_, __) => Admin()),
  ], navigatorKey: navigatorKey,
    redirect: (context, state) async {
      final requireAuth = state.fullPath != "/login" && state.fullPath != "/register";
      final jwtToken = html.window.localStorage["authToken"]; // TODO

      if (requireAuth && (jwtToken == null || jwtToken.isEmpty)) {
        return '/login'; //
      }

      return null;
});

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class _MyHomePageState extends State<MyHomePage> {
  bool isSecondHalfVisible = true;
  bool widthProp = true;

  late Future<void> _initFuture;

  bool _loaded = false;

  Uint8List? avatar;

  User? currentUser;

  Future<void> initialize() async {
    bool profile = await User.updateProfile();
    if (!profile) {
      context.go("/login");
    }
    Uint8List? avatari = await currentUser?.getMedia();
    setState(() {
      avatar = avatari;
    });
  }

  @override
  void initState() {
    super.initState();
    MyHomePage.instance = this;
    _initFuture = initialize();
    // TODO: implement initState
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      double screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth < 600) {
        isSecondHalfVisible = false;
        widthProp = false;
      }
    });
  }

  Key imageKey = GlobalKey();

  bool newAvatar = false;

  AvatarImage? image;

  @override
  Widget build(BuildContext context) {
    if(html.window.location.href.split("\?").length >= 2 && html.window.location.href.split("\?").contains("changedProfile=true")) {
      setState(() {
        newAvatar = true;
        _loaded = false;
        html.window.location.href = html.window.location.href.split("\?")[0];
      });
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    widthProp = screenWidth >= 700;

    image = AvatarImage(avatar: avatar, width: max(128, screenWidth / 4 - 60));


    List<Widget> profile = [
      FittedBox(fit: BoxFit.scaleDown, child: Material(
        elevation: 8, // Adjust the elevation value as needed
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: max(128, screenWidth / 4 - 60),
          height: max(128, screenWidth / 4 - 60),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white,
                  ),
                ),
                image!
              ],
            ),
          ),
        ),
      )),
      const SizedBox(width: 40, height: 40),
      FittedBox (
        fit: BoxFit.scaleDown,
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              clipBehavior: Clip.hardEdge,
              child: currentUser == null ? const CircularProgressIndicator() : Text(
                "${currentUser!.firstName}${currentUser!.secondName!.isEmpty ? "" : " _currentUser!.secondName"} ${currentUser!.lastName}",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              clipBehavior: Clip.hardEdge,
              child: currentUser == null ? SizedBox(height: 1, width: 1,) : Text(
                currentUser!.phone!,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(height: 10,),
            FittedBox(
              fit: BoxFit.scaleDown,
              clipBehavior: Clip.hardEdge,
              child: currentUser == null ? SizedBox(height: 1, width: 1,) : Text(
                currentUser!.description!,
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
            ),
          ],
        ),
      )

    ];

    List<Widget> floatingButtons = [
      Padding(
        padding: widthProp ? EdgeInsets.fromLTRB(20, 40, 20, 8) : EdgeInsets.all(8.0), // Adjust padding as needed
        child: FloatingActionButton(
          onPressed: () async {
            currentUser!.ready(!currentUser!.isReady!);
          },
          child: Icon(Icons.front_hand),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0), // Adjust padding as needed
        child: FloatingActionButton(
          onPressed: () {
            context.push("/changeProfile");
          },
          child: Icon(Icons.person),
          tooltip: "Edit profile",
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0), // Adjust padding as needed
        child: currentUser != null && currentUser!.isAdmin!
            ? FloatingActionButton(
          onPressed: () {
            context.go("/admin");
          },
          child: Icon(Icons.admin_panel_settings),
          tooltip: "Admin Panel",
        )
            : FloatingActionButton(
          onPressed: () {
            html.window.localStorage.remove("authToken");
            context.go("/login");
          },
          child: Icon(Icons.logout),
          tooltip: "Logout",
        ),
      ),
    ];


    return FutureBuilder<void>(
        future: _initFuture, // Pass the future that represents the asynchronous operation
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If an error occurred while fetching data, display an error message
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (!_loaded) {
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                setState(() {
                  _loaded = true;
                });
              });
            }
            return Scaffold(
              backgroundColor: Color.fromARGB(255, 237, 180, 0),
              body: Row(
                children: [
                  // Первая половина экрана
                  !isSecondHalfVisible || widthProp
                      ? Container(
                    color: Colors.transparent,
                    width: widthProp ? screenWidth / 2 : screenWidth,
                    height: double.infinity,
                    child: Container(
                        color: Colors.transparent,
                        height: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Column(
                            children: [
                              Coffee(id: "1", width: widthProp ? screenWidth / 2 : screenWidth - 40)
                            ],
                          )
                          )
                        ),
                    ) : Container(),
                  isSecondHalfVisible ? Expanded(
                    child: Container(
                      color: Colors.transparent,
                      height: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
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
                          child: Form(
                            key: GlobalKey(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: (widthProp ? profile : <Widget>[
                                      FittedBox(child: Row(children: profile,),
                                        fit: BoxFit.scaleDown,),
                                    ]) + [
                                      SizedBox(height: widthProp ? min(
                                          300, screenHeight / 6) : min(
                                          screenHeight / 1.5, screenWidth / 1.5) -
                                          40,)
                                    ],
                                  ),
                                ),
                              ] ,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
                ],
              ),
              // Кнопка для открытия/скрытия второй половины экрана
              floatingActionButton: widthProp ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: floatingButtons,
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: floatingButtons + [ // Add additional FloatingActionButton here if needed
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        isSecondHalfVisible = !isSecondHalfVisible;
                      });
                    },
                    isExtended: true,
                    child: Icon(isSecondHalfVisible ? Icons.arrow_forward : Icons.arrow_back),
                  ),
                ],
              ),
              floatingActionButtonLocation: widthProp ? FloatingActionButtonLocation.endDocked : FloatingActionButtonLocation
                  .endDocked, // Расположение кнопки по центру внизу
            );
          }
        });
  }
}
