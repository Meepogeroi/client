import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class User {
  String username;
  String password;
  String token;
  String uuid;

  User({this.username, this.password});

  void fromMap(Map<String, dynamic> map) {
    this.token = map["token"];
    this.uuid = map["uuid"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["username"] = this.username;
    map["password"] = this.password;
    return map;
  }

  Future<Map<String, dynamic>> secure() async {
    http.Response resp = await http.get(
      'http://192.168.1.177:6001/v1/secure',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      return null;
    }
  }

  Future<int> auth() async {
    http.Response resp = await http.post(
      'http://192.168.1.177:6001/user/auth',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(toMap()),
    );
    int status = resp.statusCode;
    fromMap(jsonDecode(resp.body));
    return status;
  }

  Future<int> createAlbum() async {
    http.Response resp = await http.post(
      'http://192.168.1.177:6001/user/create',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(toMap()),
    );
    int status = resp.statusCode;
    return status;
  }
}

class HomePage extends StatelessWidget {
  User usr = User();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              hintText: "Enter your login",
            ),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
            ),
          ),
          FlatButton(
            child: Text(
              "Reg",
            ),
            onPressed: () {
              usr.username = usernameController.value.text;
              usr.password = passwordController.value.text;
              usr.createAlbum().then((value) {
                if (value == 201) {
                  print("Ok");
                  usr.auth().then((value) {
                    if (value == 200) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => MainPage(usr: usr)));
                    } else {
                      print("authError");
                    }
                  });
                } else
                  print("Err");
              });
            },
          ),
          FlatButton(
            child: Text("Auth"),
            onPressed: () {
              usr.username = usernameController.value.text;
              usr.password = passwordController.value.text;
              usr.auth().then((value) {
                if (value == 200) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MainPage(usr: usr)));
                } else{
                  print("authError");
                }
              });
            },
          )
        ],
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  final User usr;

  const MainPage({Key key, this.usr}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            """
          username: ${usr.username}
          password: ${usr.password}
          token: ${usr.token}
          uuid: ${usr.uuid}
          """,
            style: TextStyle(fontSize: 10, shadows: [
              Shadow(
                  blurRadius: 20.0,
                  color: Colors.green,
                  offset: Offset(5.0, 5.0))
            ]),
          ),
          FlatButton(
            child: Text("Secure"),
            onPressed: () async {
              var resp = await usr.secure();
              if (resp == null) {
                print("Err");
              } else {
                print(resp["token"]["Claims"]["uuid"]);
              }
            },
          ),
        ],
      ),
    );
  }
}
