import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:latlng/latlng.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ynov_chat_flutter/bo/message.dart';

import 'package:ynov_chat_flutter/routes.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<int> items;
  late StreamController<List<Message>> _streamControllerListMsgs;
  late Stream<List<Message>> _streamMsgs;
  late TextEditingController tecMsg;
  late FlutterSecureStorage storage ;
  final ImagePicker ip = ImagePicker();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    setLocaleMessages("fr_short", FrShortMessages());
    storage = new FlutterSecureStorage();
    tecMsg = TextEditingController();
    _streamControllerListMsgs = StreamController<List<Message>>();
    _streamMsgs = _streamControllerListMsgs.stream;
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: (){
                fetchMessages();
              }),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildList()),
          Row(children: [
            IconButton(
                onPressed: () => {_pickImage()},
                icon: Icon(Icons.upload_file)
            ),IconButton(
                onPressed: () => {_locateMe()},
                icon: Icon(Icons.my_location)
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: tecMsg,
                  decoration: const InputDecoration(
                    hintText: "Enter your message"
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _sendMessage(context),
              child: const Icon(Icons.send),
            )
          ],)
        ],
      )
    );
  }

  StreamBuilder<List<Message>> _buildList() {
    return StreamBuilder<List<Message>>(
      stream: _streamMsgs,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Icon(Icons.error);
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 1.5),
            itemBuilder: (context, index) {
              if(!snapshot.data![index].isImage){
                return InkWell(
                  onTap: () => {_launchUrl(snapshot.data![index].content)},
                  child: ListTile(
                    //leading: Image.network("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/6e443f00-bb6b-41ea-ba1a-f0c52dfb7cdc/ddrhs33-df39d039-d9ec-4450-b3a6-5c125a38e1e7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzZlNDQzZjAwLWJiNmItNDFlYS1iYTFhLWYwYzUyZGZiN2NkY1wvZGRyaHMzMy1kZjM5ZDAzOS1kOWVjLTQ0NTAtYjNhNi01YzEyNWEzOGUxZTcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.RnDoWNFkVfodcv1boGZ1lafSLMbTSwhe-37omwoGtA4"),
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
                  ),
                );
              } else {
                Uint8List _bytes;
                _bytes = const Base64Decoder().convert(snapshot.data![index].content);
                return InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("❤"),
                  )),
                  child: ListTile(
                    //leading: Image.network("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/6e443f00-bb6b-41ea-ba1a-f0c52dfb7cdc/ddrhs33-df39d039-d9ec-4450-b3a6-5c125a38e1e7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzZlNDQzZjAwLWJiNmItNDFlYS1iYTFhLWYwYzUyZGZiN2NkY1wvZGRyaHMzMy1kZjM5ZDAzOS1kOWVjLTQ0NTAtYjNhNi01YzEyNWEzOGUxZTcuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.RnDoWNFkVfodcv1boGZ1lafSLMbTSwhe-37omwoGtA4"),
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
                    subtitle: Image.memory(_bytes, fit: BoxFit.fitWidth),
                  ),
                );
              }
            }
        );
      }
    );
  }

  String formatDateString(String isoDate) {
    DateFormat df = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSZ", "fr_FR");
    DateTime dateTime = df.parse(isoDate).toLocal();
    return format(dateTime, locale: "fr_short");
  }

  void fetchMessages() async {
    String? token = await storage.read(key: "jwt");
    Future<Response> resMsgs = get(
        Uri.parse("https://flutter-learning.mooo.com/messages?_limit=-1"),
        headers: { 'Authorization':"Bearer ${token}"}
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

  void _sendMessage (BuildContext context) async {
    String? token = await storage.read(key: "jwt");
    Future<Response> res = post(
        Uri.parse("https://flutter-learning.mooo.com/messages/"),
        headers: { 'Authorization':"Bearer ${token}"},
        body: {
          "content": tecMsg.text,
        });

    res.then((value) {
      if (value.statusCode == 200) {
        Map<String,dynamic> bodyJson = jsonDecode(value.body);

        SnackBar snackbar = SnackBar(
            content: Text("Message Sent")
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);

        fetchMessages();
      }
    }, onError: (obj) {
      log("Send Error : " + obj.toString());
    });

    tecMsg.text = "";
  }

  void _launchUrl(String content) {
    RegExp urlRegex = RegExp(
        r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"
    );
    RegExp latlngRegex = RegExp(
        r"^(-?\d+(\.\d+)?),\s*(-?\d+(\.\d+)?)$"
    );

    bool isUri = urlRegex.hasMatch(content);
    if (isUri) {
      launch(urlRegex.firstMatch(content)?.group(0) ?? "");
    } else {
      String ? latLngUri = latlngRegex.firstMatch(content)?.group(0);
      if (latLngUri != null) {
        double latitude = double.parse(latLngUri.split(',')[0]);
        String? longitudeS = latLngUri.split(',')[1];
        if (longitudeS != null) {
          double longitude = double.parse(longitudeS);
          Navigator.of(context).pushNamed(ROUTE_MAP_PAGE, arguments: LatLng(latitude, longitude));
        }
      }
    }
  }

  void _pickImage() async {
    XFile? imagePicked = await ip.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      log(imagePicked.name);
    }
  }

  void _locateMe() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      Geolocator.requestPermission();
    else if (permission == LocationPermission.deniedForever)
      return;

    if (serviceEnabled && permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Geolocator.getCurrentPosition().then(
          (position) {
            tecMsg.text = '${position.latitude}, ${position.longitude}';
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Position received"),
                )
            );
          },
        onError: (_, error) => log("Error while fetching position : ${error.toString()}")
      );
    }
  }

  @override
  void dispose() {
    _streamControllerListMsgs.close();
  }
}