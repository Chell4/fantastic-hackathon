import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:front/entities/AvatarImage.dart';
import 'package:front/main.dart';
import 'package:go_router/go_router.dart';

import '../entities/Admin.dart';
import '../entities/User.dart';
import '../utils/Constants.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Future<List<User>> _fetchUsers() async {
    List<User> users = List.empty(growable: true);
    var json = jsonDecode(await listUsers());
    for (dynamic i in json["users"]) {
      users.add(User.fromJson(i));
    }
    return users;
  }

  Future<List<User>> _fetchRequest() async {
    List<User> users = List.empty(growable: true);
    var json = jsonDecode(await listRequests());
    for (dynamic i in json["requests"]) {
      users.add(User.fromJson(i));
    }
    return users;
  }

  Future<List<List<User>>> _fetch() async {
    return [await _fetchRequest(), await _fetchUsers()];
  }

  @override
  Widget build(BuildContext context) {
    if (MyHomePage.instance == null) context.go("/");

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200,
        elevation: 0,
        titleSpacing: 0,
        title: Image.asset("assets/logo-2x.png", width: 400),
        actions: [
          CircleAvatar(
            radius: 50,
            backgroundImage: MyHomePage.instance!.avatar != null
                ? Image.memory(MyHomePage.instance!.avatar!, width: 128,)!.image
                : null,
            child: MyHomePage.instance!.avatar == null
                ? Icon(Icons.person)
                : Container(),
          ),
          SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 50,
            onPressed: () {
              context.go("/");
            },
          ),
          SizedBox(width: 48), // Add space between admin icon and logout button
        ],
      ),
      body: FutureBuilder<List<List<User>>>(
        future: _fetch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<User> requests = snapshot.data![0] ?? [];
            List<User> users = snapshot.data![1] ?? [];
            return Scaffold(
              backgroundColor: Color.fromARGB(255, 237, 180, 0),
              body: Container(
                width: double.infinity,
                height: double.infinity, // Set a fixed height or adjust as needed
                padding: EdgeInsets.all(40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side list view
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: requests.length + users.length,
                          itemBuilder: (context, index) {
                            return requests.length <= index
                                ? Card(
                                    shape: RoundedRectangleBorder( // Set the shape of the Card
                                      borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
                                    ),
                                    elevation: 5, // Add elevation for a shadow effect
                                    child: ListTile(
                                      leading: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: SizedBox(
                                          width: 1024,
                                          height: 1024,
                                          child: Image.network("$BACKEND/media/${users[index-requests.length].id}", fit: BoxFit.cover, width: 256,),
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(

                                      ),
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text("${users[index-requests.length].firstName!} ${users[index-requests.length].lastName!}"),
                                              users[index-requests.length].isAdmin! ? Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue, // Change the color as needed
                                                      borderRadius: BorderRadius.circular(20), // Adjust the border radius to make it pill-shaped
                                                    ),
                                                    child: Text(
                                                      'Admin',
                                                      style: TextStyle(
                                                        color: Colors.white, // Change the text color as needed
                                                        fontSize: 16, // Adjust the font size as needed
                                                      ),
                                                    ),
                                                  )) : Container(),
                                            ],
                                          ),
                                          Text(users[index-requests.length].phone!, textAlign: TextAlign.left,)
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.admin_panel_settings, color: Colors.blueGrey),
                                            onPressed: () async {
                                              bool ans = await addAdmin(users[index-requests.length].id!);
                                              showGeneralDialog(context: context, barrierDismissible: true, barrierLabel: "Dialog", pageBuilder: (context, animtion, animtion2) {
                                                return Center(child: Container(
                                                    width: 300,
                                                    height: 300,
                                                    color: Colors.white,
                                                    child: Center(child: Text(ans ? "Added admin!" : "Could not add admin", style: Theme.of(context).textTheme.headlineLarge,),)
                                                ));
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.blueGrey),
                                            onPressed: () async {
                                              // Add your reject logic here
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        // Add your user tap logic here
                                      },
                                    ),
                                  ) :
                            Card(
                              shape: RoundedRectangleBorder( // Set the shape of the Card
                                borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
                              ),
                              elevation: 5, // Add elevation for a shadow effect
                              child: ListTile(
                                shape: RoundedRectangleBorder(

                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text("${requests[index].firstName!} ${requests[index].lastName!}"),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green, // Change the color as needed
                                                borderRadius: BorderRadius.circular(20), // Adjust the border radius to make it pill-shaped
                                              ),
                                              child: Text(
                                                'Request',
                                                style: TextStyle(
                                                  color: Colors.white, // Change the text color as needed
                                                  fontSize: 16, // Adjust the font size as needed
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                    Text(requests[index].phone!, textAlign: TextAlign.left,)
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check, color: Colors.green),
                                      onPressed: () async {
                                        await answerRequest(requests[index].id!, true);
                                        context.pushReplacement("/admin");
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await answerRequest(requests[index].id!, false);
                                        context.pushReplacement("/admin");
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Add your user tap logic here
                                },
                              ),
                            )

                            ;
                          },
                        ),
                      ),
                      // Right side list view
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: 0,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(users[index].id!),
                              // Add other list view item UI here
                            );
                          },
                        ),
                      ),
                      // Add more list views or other widgets as needed
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
