import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart';

import 'Message.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<int> items;
  late StreamController<List<Message>> _streamControllerListMsgs;
  late Stream<List<Message>> _streamMsgs;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    setLocaleMessages("fr_short", FrShortMessages());
    items = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    _streamControllerListMsgs = StreamController<List<Message>>();
    _streamMsgs = _streamControllerListMsgs.stream;
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: StreamBuilder<List<Message>>(
        stream: _streamMsgs,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Icon(Icons.error);
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 1.5),
              itemBuilder: (context, index) =>
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(snapshot.data![index].author.username),
                      Text(
                        formatDateString(snapshot.data![index].created_at),
                        style: TextStyle(fontStyle: FontStyle.italic)
                      ),
                    ],
                  ),
                  subtitle: Text(snapshot.data![index].content),
                )
          );
        }
      )
    );
  }

  String formatDateString(String isoDate) {
    DateFormat df = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSZ", "fr_FR");
    DateTime dateTime = df.parse(isoDate);
    return format(dateTime, locale: "fr_short");
  }

  void fetchMessages() {
    Future<Response> resMsgs = get(
        Uri.parse("https://flutter-learning.mooo.com/messages"),
        headers: { 'Authorization':"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNjQyNjcxMzMyLCJleHAiOjE2NDUyNjMzMzJ9.46AmdmoaNWPaYdDoR-4YImCSBNROendkxWD5_oz39Nc"}
    );
    resMsgs.then(
        (value) {
          if (value.statusCode == 200) {
            String jsonBody = value.body;
            List<Message> lsMsgs = List.empty(growable: true);
            
            for(Map<String, dynamic> msg in jsonDecode(jsonBody)) {
              lsMsgs.add(Message.fromJson(msg));
            }
            _streamControllerListMsgs.sink.add(lsMsgs);
          }
        }, 
        onError: (_, err) => log("Error while fetching messages"));
  }

  @override
  void dispose() {
    _streamControllerListMsgs.close();
  }
}