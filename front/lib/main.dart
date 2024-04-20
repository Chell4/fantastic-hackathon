import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:front/screens/Login.dart';
import 'package:front/screens/Register.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NACO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black45),
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
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final GoRouter router = GoRouter(routes: [
  GoRoute(path: '/', name: "Home", builder: (_, __) => MyHomePage()),
  GoRoute(path: '/login', name: "Login", builder: (_, __) => Login()),
  GoRoute(path: '/register', name: "Register", builder: (_, __) => Register()),
  ], navigatorKey: navigatorKey,
    redirect: (context, state) async {
      final requireAuth = state.fullPath != "/login" && state.fullPath != "/register";
      final jwtToken = null; // TODO

      if (requireAuth && (jwtToken == null || jwtToken.isEmpty)) {
        return '/'; //
      }

      return "/";
});

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class _MyHomePageState extends State<MyHomePage> {
  bool isSecondHalfVisible = true;
  bool widthProp = true;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      double screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth < 600) {
        isSecondHalfVisible = false;
        widthProp = false;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    widthProp = screenWidth >= 700;
    print(screenWidth);

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
                Lottie.asset(
                  "assets/Cup.json",
                  frameRate: const FrameRate(60),
                  repeat: true,
                  width: max(128, screenWidth / 4 - 60),
                  fit: BoxFit.fitWidth,
                  onLoaded: (composition) {
                    // Configure the AnimationController with the duration of the
                    // Lottie file and start the animation.
                    var _gifController;
                    _gifController
                      ..duration = composition.duration
                      ..forward()
                      ..repeat();
                  },
                  filterQuality: FilterQuality.low,
                )
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
              child: Text(
                "Firstname Lastname",
                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              clipBehavior: Clip.hardEdge,
              child: Text(
                "+7(912) 345 67-89",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      )

    ];

    List<Widget> buttons = [
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Действия при нажатии на первую кнопку
              },
              child: Text("Button 1"),
            ),
          ),
          SizedBox(width: 10), // Промежуток между кнопками
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Действия при нажатии на вторую кнопку
              },
              child: Text("Button 2"),
            ),
          ),
          SizedBox(width: 10), // Промежуток между кнопками
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Действия при нажатии на третью кнопку
              },
              child: Text("Button 3"),
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Row(
        children: [
          // Первая половина экрана
          !isSecondHalfVisible || widthProp
              ? Container(
            color: Colors.white,
            width: widthProp ? screenWidth / 2 - 1 : screenWidth,
            height: double.infinity,
            // You can add any child widget here
          )
              : Container(), // Пустой контейнер, если вторая половина скрыта
          widthProp ? SizedBox(width: 2, height: double.infinity) : Container(),
          // Вторая половина экрана
          isSecondHalfVisible ? Expanded(
            child: Container(
              color: Colors.white,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                child: Form(
                  key: GlobalKey(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: (widthProp ? profile: <Widget>[
                            FittedBox(child: Row(children: profile,), fit: BoxFit.scaleDown,),
                          ]) + [SizedBox(height: widthProp ? min(300, screenHeight / 6) : min(screenHeight / 1.5, screenWidth / 1.5) - 40,)],
                        ),
                      ),
                    ] + buttons,
                  ),
                ),
              ),
            ),
          ) : Container(),
        ],
      ),
      // Кнопка для открытия/скрытия второй половины экрана
      floatingActionButton: widthProp ? null : FloatingActionButton(
        onPressed: () {
          setState(() {
            isSecondHalfVisible = !isSecondHalfVisible; // Переключение состояния видимости второй половины экрана
          });
        },
        isExtended: true,
        child: Icon(isSecondHalfVisible ? Icons.arrow_forward : Icons.arrow_back), // Иконка меняется в зависимости от состояния
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Расположение кнопки по центру внизу
    );
  }
}
