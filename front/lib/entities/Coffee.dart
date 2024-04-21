import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Coffee extends StatefulWidget {
  final String id;
  final double width;

  const Coffee({super.key, required this.id, required this.width});

  @override
  State<Coffee> createState() => _CoffeeState();
}

class _CoffeeState extends State<Coffee> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
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
      height: 300,
      child: Row(
        children: [
          Lottie.asset(
            "assets/Cup.json",
            frameRate: const FrameRate(60),
            repeat: true,
            width: 300,
            fit: BoxFit.fitWidth,
            onLoaded: (composition) {
              var _gifController;
              _gifController
                ..duration = composition.duration
                ..forward()
                ..repeat();
            },
            filterQuality: FilterQuality.low,
          ),
          Padding(padding: EdgeInsets.all(40), child: Column(
            mainAxisAlignment: MainAxisAlignment.center ,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You have a meeting", style: Theme.of(context).textTheme!.headlineLarge,),
                Text("Phone: +79397893141 (Ignat Ignat)", style: Theme.of(context).textTheme!.headlineSmall,),
                Text("Description: Оплачу энергос, попьём в коворкинге", style: Theme.of(context).textTheme!.bodyMedium, softWrap: true,),
                Spacer(),
                ElevatedButton(onPressed: () {}, child: Text("Mark meeting as completed"))
              ]
          ),)
        ],
      ),
    );
  }
}
