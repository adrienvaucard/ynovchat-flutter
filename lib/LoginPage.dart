import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  late TextEditingController tecId, tecPwd;

  LoginPage({Key? key}) : super(key: key) {
    tecId = TextEditingController();
    tecPwd = TextEditingController();
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  late FlutterSecureStorage storage;

  @override
  void initState() {
    super.initState();
    storage = new FlutterSecureStorage();
    Future<void> value = storage.read(key: "jwt").then(
      (value) {
        if (value != null) {
          developer.log(value.toString());
          Navigator.of(context).pushNamed('/home');
        } else {
          developer.log("No Token Found");
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                width: 200.0,
                child:  TextFormField(
                  controller: widget.tecId,
                  decoration: const InputDecoration(
                      hintText: "Login"
                  ),
                ),
              ),
              SizedBox(
                width: 200.0,
                child: TextFormField(
                  controller: widget.tecPwd,
                  decoration: const InputDecoration(
                      hintText: "Password"
                  ),
                  obscureText: true,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text("Login".toUpperCase(),)
              ),
              OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                  child: Text("Register".toUpperCase(),)
              )
            ],
          )
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    String id = widget.tecId.text;
    String password = widget.tecPwd.text;

    Future<http.Response> res = http.post(
        Uri.parse("https://flutter-learning.mooo.com/auth/local/"),
        body: {
          "identifier": id,
          "password": password
        });

    res.then((value) async {
      if (value.statusCode == 200) {
        Map<String,dynamic> bodyJson = jsonDecode(value.body);

        await storage.write(key: "jwt", value: bodyJson["jwt"]);
        Navigator.of(context).pushNamed('/home');
      }
    }, onError: (obj) {
      developer.log("Login Error : " + obj.toString());
    });

    widget.tecId.text = "";
    widget.tecPwd.text = "";
  }
}