import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class RegisterPage extends StatefulWidget {
  late TextEditingController tecId, tecPwd, tecEmail;

  RegisterPage(String title, {Key? key}) : super(key: key) {
    tecId = TextEditingController();
    tecEmail = TextEditingController();
    tecPwd = TextEditingController();
  }

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
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
                      hintText: "Username"
                  ),
                ),
              ),
              SizedBox(
                width: 200.0,
                child:  TextFormField(
                  controller: widget.tecEmail,
                  decoration: const InputDecoration(
                      hintText: "Email"
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
                  onPressed: () => _register(context),
                  child: Text("Register".toUpperCase(),)
              ),
              OutlinedButton(
                  onPressed: () {},
                  child: Text("Login".toUpperCase(),)
              )
            ],
          )
        ),
      ),
    );
  }

  void _register(BuildContext context) {
    String id = widget.tecId.text;
    String email = widget.tecEmail.text;
    String password = widget.tecPwd.text;

    /*SnackBar snackbar = SnackBar(
      content: Text('$id:$password')
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);*/

    Future<http.Response> res = http.post(
        Uri.parse("https://flutter-learning.mooo.com/auth/local/register/"),
        body: {
          "username": id,
          "email": email,
          "password": password,

        });

    res.then((value) {
      if (value.statusCode == 200) {
        Map<String,dynamic> bodyJson = jsonDecode(value.body);
        developer.log(bodyJson['jwt']);
      }
    }, onError: (obj) {
      developer.log("Register Error : " + obj.toString());
    });

    widget.tecId.text = "";
    widget.tecEmail.text = "";
    widget.tecPwd.text = "";
  }
}