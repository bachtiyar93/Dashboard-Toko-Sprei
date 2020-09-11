import 'package:flutter/material.dart';
import 'package:tnb_srm/validasi/validasilogin.dart';
import 'validasi/notification.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}

