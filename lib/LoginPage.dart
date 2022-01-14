import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login / Register"),
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
                  onPressed: () {},
                  child: Text("Register".toUpperCase(),)
              )
            ],
          )
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    String id = widget.tecId.text;
    String password = widget.tecPwd.text;

    SnackBar snackbar = SnackBar(
      content: Text('$id:$password')
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);


    widget.tecId.text = "";
    widget.tecPwd.text = "";
  }
}