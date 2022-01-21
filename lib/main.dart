import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';
import 'package:ynov_chat_flutter/pages/LoginPage.dart';
import 'package:ynov_chat_flutter/pages/MapPage.dart';
import 'package:ynov_chat_flutter/pages/RegisterPage.dart';
import 'package:ynov_chat_flutter/routes.dart';

import 'pages/HomePage.dart';

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
      darkTheme: ThemeData(
        primarySwatch: Colors.blue
      ),

      onGenerateRoute: (settings) {
        if(settings.name == ROUTE_MAP_PAGE) {
          return MaterialPageRoute(builder: (context) =>
          MapPage(settings.arguments as LatLng));
        }
      },
      initialRoute: ROUTE_LOGIN,
      routes: <String, WidgetBuilder> {
        ROUTE_LOGIN: (BuildContext context) => LoginPage(),
        ROUTE_REGISTER: (BuildContext context) => RegisterPage(),
        ROUTE_HOME_PAGE: (BuildContext context) => HomePage(),
        //'/map': (BuildContext context) => MapPage(),
      },
    );
  }
}
