import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
                  title: Text("Message ${snapshot.data![index].content}")
                )
          );
        }
      )
    );
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