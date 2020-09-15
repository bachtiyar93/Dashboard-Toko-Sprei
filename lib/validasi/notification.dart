import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class Homepage extends StatefulWidget {
  final VoidCallback signOut;
  Homepage(this.signOut);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }
  final scaffoldState = GlobalKey<ScaffoldState>();
  final notifikasiFCM = FirebaseMessaging();
  final kontrolTopic = TextEditingController();
  bool isSubscribed = false;
  String token = '';
  static String dataName = '';
  static String dataAge = '';


  @override
  Widget build(BuildContext context) {
    debugPrint('token: $token');
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('Sprei & Gordyn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'TOKEN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(token),
            Divider(thickness: 1),
            Text(
              'TOPIC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: kontrolTopic,
              enabled: !isSubscribed,
              decoration: InputDecoration(
                hintText: 'Enter a topic',
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text('Subscribe'),
                    onPressed: isSubscribed ? null : () {
                      String topic = kontrolTopic.text;
                      if (topic.isEmpty) {
                        scaffoldState.currentState.showSnackBar(SnackBar(
                          content: Text('Topic invalid'),
                        ));
                        return;
                      }
                      notifikasiFCM.subscribeToTopic(topic);
                      setState(() {
                        isSubscribed = true;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: RaisedButton(
                    child: Text('Unsubscribe'),
                    onPressed: !isSubscribed ? null : () {
                      String topic = kontrolTopic.text;
                      notifikasiFCM.unsubscribeFromTopic(topic);
                      setState(() {
                        isSubscribed = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            Divider(thickness: 1),
            Text(
              'DATA',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildWidgetTextDataFcm(),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetTextDataFcm() {
    if (dataName == null || dataName.isEmpty || dataAge == null || dataAge.isEmpty) {
      return Text('Your data FCM is here');
    } else {
      return Text('Name: $dataName & Age: $dataAge');
    }
  }

  void getDataFcm(Map<String, dynamic> message) {
    String name = '';
    String age = '';
    if (Platform.isIOS) {
      name = message['name'];
      age = message['age'];
    } else if (Platform.isAndroid) {
      var data = message['data'];
      name = data['name'];
      age = data['age'];
    }
    if (name.isNotEmpty && age.isNotEmpty) {
      setState(() {
        dataName = name;
        dataAge = age;
      });
    }
    debugPrint('getDataFcm: name: $name & age: $age');
  }
}