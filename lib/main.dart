import 'dart:convert';
import 'dart:io';
import 'package:custom_progress_dialog/custom_progress_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'library/sumberapi.dart';
import 'validasi/notification.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
enum LoginStatus { suksesSignIn, belumSignIn }
class _HomePageState extends State<HomePage> {
  LoginStatus _loginStatus = LoginStatus.belumSignIn;
  final scaffoldState = GlobalKey<ScaffoldState>();
  final firebaseMessaging = FirebaseMessaging();
  final controllerTopic = TextEditingController();
  bool isSubscribed = false;
  bool _secureText = true;
  String token = '';
  String phone, password;
  static String dataName = '';
  static String dataAge = '';

  final _key = new GlobalKey<FormState>();




  //Pengiriman data Background
  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    debugPrint('onBackgroundMessage: $message');
    if (message.containsKey('data')) {
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
      dataName = name;
      dataAge = age;
      debugPrint('onBackgroundMessage: name: $name & age: $age');
    }
    return null;
  }

  //Inisialisasi onMessage,Background dan saat launch
  @override
  void initState() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint('onMessage: $message');
        getDataFcm(message);
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (Map<String, dynamic> message) async {
        debugPrint('onResume: $message');
        getDataFcm(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('onLaunch: $message');
        getDataFcm(message);
      },
    );
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      debugPrint('Settings registered: $settings');
    });
    firebaseMessaging.getToken().then((token) => setState(() {
      this.token = token;
    }));
    super.initState();
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    debugPrint('token: $token nama:$dataName age:$dataAge');
    switch (_loginStatus) {
      case LoginStatus.belumSignIn:
        return Scaffold(
          body: Form(
            key: _key,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                // new Image.asset(
                //   'lib/assets/square.JPG',
                //   width: 200.0,
                //   height: 200.0,
                // ),
                new Center(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text("Selamat Datang",
                            style: new TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                      ],
                    )),

                Column(
                  children: <Widget>[
                    TextFormField(
                      // ignore: missing_return
                      validator: (e) {
                        if (e.isEmpty) {
                          return "Silahkan Masukan Nomor telepon terdaftar";
                        }
                      },
                      onSaved: (e) => phone = e,
                      decoration: InputDecoration(
                        labelText: "Phone",
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  // ignore: missing_return
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Masukan password anda";
                    }
                  },
                  obscureText: _secureText,
                  onSaved: (e) => password = e,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      onPressed: showHide,
                      icon: Icon(_secureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),
                //Divider Login
                Divider(
                  height: 14.0,
                  color: Colors.white,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                  const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                  alignment: Alignment.center,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new FlatButton(
                          color: Colors.green,
                          onPressed: () {
                            check();
                          },
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          child: new Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 20.0,
                            ),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Expanded(
                                  child: Text(
                                    "Login",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _buildWidgetTextDataFcm(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Akhir Divider Login
              ],
            ),
          ),
        );
        break;
      case LoginStatus.suksesSignIn:
        return Homepage(signOut);
    }
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

  void   showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  void   check() async {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
      _progressDialog.showProgressDialog(context, textToBeDisplayed: 'Menghubungi Toko',onDismiss: (){});
    }
  }
  ProgressDialog _progressDialog = ProgressDialog();
  void login() async {
    final response = await http.post(SumberApi.login,
        body: {"phone": phone, "password": password, "token": token});

    //terima data
    final data = jsonDecode(response.body);

    int valueApi = data['value'];
    int idApi = data['id'];
    String pesanApi = data['message'];
    debugPrint('valueApi:$valueApi idApi:$idApi');

    if (valueApi == 1) {
      setState(() {
        _loginStatus = LoginStatus.suksesSignIn;
        saveInformasiLogin(valueApi, idApi, phoneApi);
      });
      _progressDialog.dismissProgressDialog(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesanApi),
            );
          });
    } else {
      _progressDialog.dismissProgressDialog(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesanApi),
            );
          });
    }
  }

  void saveInformasiLogin(int valueApi, int idApi, String phoneApi) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("valueApi", valueApi);
      preferences.setInt("idApi", idApi);
      preferences.setString("phoneApi", phoneApi);
      // ignore: deprecated_member_use
      preferences.commit();
      _loginStatus = LoginStatus.suksesSignIn;
    });
  }
  var valueApi, idApi, phoneApi;
  void konfirmasiDariServer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      valueApi = preferences.getInt("valueApi");
      idApi = preferences.getInt("idApi");
      if (valueApi == 1) {
        _loginStatus = valueApi == 1 ? LoginStatus.suksesSignIn : LoginStatus.belumSignIn;
      } else {
        _loginStatus = LoginStatus.belumSignIn;
      }
    });
  }

  void  signOut() async {
    _progressDialog.showProgressDialog(context,
        dismissAfter: Duration(seconds: 5),
        textToBeDisplayed: 'System in Progress...',
        onDismiss: () {});
    final response = await http.post(SumberApi.logout, body: {"id": idApi});
    final data = jsonDecode(response.body);
    int valueApi = data['value'];
    String pesanApi = data['message'];
    _progressDialog.dismissProgressDialog(context);
    if (valueApi == 0) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesanApi),
            );
          });
      setState(() {
        preferences.clear();
        // ignore: deprecated_member_use
        preferences.commit();
        _loginStatus = LoginStatus.belumSignIn;
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesanApi),
            );
          });
    }
  }
}

