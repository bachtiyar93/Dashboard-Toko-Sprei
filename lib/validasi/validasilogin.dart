
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:custom_progress_dialog/custom_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tnb_srm/library/sumberapi.dart';

import 'notification.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

 enum LoginStatus {
  admin,
  notSignIn
}

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;
  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() async {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
      _progressDialog.showProgressDialog(context,
          dismissAfter: Duration(seconds: 5),
          textToBeDisplayed: 'Waiting Connection...', onDismiss: () {
            //things to do after dismissing -- optional
          });
      //dismissAfter - if null then progress dialog won't dismiss until dismissProgressDialog is called from the code.
    }
  }

  ProgressDialog _progressDialog = ProgressDialog();

//Base Pengecekan Login
  login() async {
    final response = await http.post(SumberApi.login,
        body: {"id_username": username, "password": password});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    String usernameAPI = data['id_username'];
    String namaAPI = data['id_nama'];
    String ktp = data['id_ktp'];
    _progressDialog.dismissProgressDialog(context);
    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.admin;
        savePref1(value, usernameAPI, namaAPI, ktp);
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesan),
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesan),
            );
          });
    }
  }

  savePref1(int value, String usernameApi, String namaApi, String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("id_nama", namaApi);
      preferences.setString("id_username", usernameApi);
      preferences.setString("id_ktp", id);
      // ignore: deprecated_member_use
      preferences.commit();
      _loginStatus = LoginStatus.admin;
    });
  }

  var value,
      ktp,
      admin;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      ktp = preferences.getString("id_ktp");
      if (value == 1) {
        _loginStatus = value == 1 ? LoginStatus.admin : LoginStatus.notSignIn;
      } else {
        _loginStatus = LoginStatus.notSignIn;
      }
    });
  }

  signOut() async {
    _progressDialog.showProgressDialog(context,
        dismissAfter: Duration(seconds: 5),
        textToBeDisplayed: 'System in Progress...',
        onDismiss: () {});
    final response = await http.post(SumberApi.logout, body: {"id_ktp": ktp});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    _progressDialog.dismissProgressDialog(context);
    if (value == 0) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesan),
            );
          });
      setState(() {
        preferences.clear();
        // ignore: deprecated_member_use
        preferences.commit();
        _loginStatus = LoginStatus.notSignIn;
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(pesan),
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

//Form Pengisian Formulir Login
  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          body: Form(
            key: _key,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                new Image.asset(
                  'lib/assets/square.JPG',
                  width: 200.0,
                  height: 200.0,
                ),
                new Center(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                            "Selamat Datang",
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
                          return "Please insert username";
                        }
                      },
                      onSaved: (e) => username = e,
                      decoration: InputDecoration(
                        labelText: "Username",
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  // ignore: missing_return
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Please insert password";
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
      case LoginStatus.admin:
        return Admin(signOut);
        // TODO: Handle this case.
        break;
    }
  }
}