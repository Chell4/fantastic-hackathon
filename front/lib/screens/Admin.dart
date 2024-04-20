import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Админ', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Добавьте код для выхода из аккаунта
            },
          ),
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
