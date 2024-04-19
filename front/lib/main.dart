import 'package:flutter/material.dart';
import 'package:front/screens/Login.dart';
import 'package:front/screens/Register.dart';
import 'package:go_router/go_router.dart';
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
  ], navigatorKey: navigatorKey,
    redirect: (context, state) async {
      final requireAuth = state.fullPath != "/login";
      final jwtToken = null; // TODO

      if (requireAuth && (jwtToken == null || jwtToken.isEmpty)) {
        return '/login'; //
      }

      return null;
});

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Hi)))"),
    );
  }
}
