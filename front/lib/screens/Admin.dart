import 'package:flutter/material.dart';
import 'package:front/entities/AvatarImage.dart';
import 'package:front/main.dart';
import 'package:go_router/go_router.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  Widget build(BuildContext context) {

    if (MyHomePage.instance == null) context.go("/");

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 200,
          elevation: 0,

          titleSpacing: 0,
          title: Image.network("https://oggetto.ru/lfs-images/oggetto-logo/logo-2x.png", width: 400,),
          actions: [
            CircleAvatar(
              // Здесь можно добавить вашу иконку админа
              radius: 50,
              backgroundImage: MyHomePage.instance!.avatar != null ? Image.memory(MyHomePage.instance!.avatar!, width: 128,)!.image : null,
              child: MyHomePage.instance!.avatar == null ? Icon(Icons.person) : Container(),
            ),
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 50,
              onPressed: () {
                context.go("/");
              },
            ),
            SizedBox(width: 48), // Добавляет промежуток между иконкой админа и кнопкой выхода
          ],
        ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('Пользователь 1'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // Добавьте код, который выполнится при нажатии на кнопку Accept
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Добавьте код, который выполнится при нажатии на кнопку Reject
                  },
                ),
              ],
            ),
            onTap: () {
              // Добавьте код, который выполнится при нажатии на пользователя
            },
          ),
          ListTile(
            title: Text('Пользователь 2'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // Добавьте код, который выполнится при нажатии на кнопку Accept
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Добавьте код, который выполнится при нажатии на кнопку Reject
                  },
                ),
              ],
            ),
            onTap: () {
              // Добавьте код, который выполнится при нажатии на пользователя
            },
          ),
          // Добавьте других пользователей при необходимости
        ],
      ),
    );
  }
}
