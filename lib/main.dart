import 'package:flutter/material.dart';
import 'package:ynov_chat_flutter/LoginPage.dart';
import 'package:ynov_chat_flutter/RegisterPage.dart';

import 'HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ynov Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        if (settings.name == '/register') {
          return MaterialPageRoute(builder: (BuildContext context) =>
            RegisterPage(settings.arguments as String));
        }
      },
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => LoginPage(),
        //'/register': (BuildContext context) => RegisterPage(),
        '/home': (BuildContext context) => HomePage(title: "Home Page"),
      },
    );
  }
}
