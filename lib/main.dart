/* Auother by Thakshara @ Widdev */

import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wayamba_medicine/pages/home.dart';
import 'package:wayamba_medicine/pages/signin.dart';

import 'package:wayamba_medicine/popeties.dart';
import 'package:wayamba_medicine/util/splash.dart';
import 'models/mysql.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wayamba University',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.light(),
      theme: ThemeData(
        fontFamily: 'OpenSans',
        focusColor: color,
        primarySwatch: color,
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          bodyText2: TextStyle(
            fontSize: 14.0,
          ),
        ),
      ),
      home: FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: Splash());
        } else {
          // Loading is done, return the app:
          return Main();
        }
        }
      ),
    );
  }
}

class Main extends StatefulWidget {
  Main({Key key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  Mysql db = Mysql();
  var conn;

  @override
  void initState() {
    super.initState();
    autoDelete();
    readLoging();
  }

  String user = '0';
  String password;

  Future readLoging() async {
    final storage = new FlutterSecureStorage();
    user = await storage.read(key: 'user');
    password = await storage.read(key: 'pass');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: user != null
          ? (user != '0' ? buildAutoLoging() : Splash())
          : Signin(),
    );
  }

 

  Container buildAutoLoging() {
    logingCheck();
    return Container(
      padding: EdgeInsets.only(bottom: 16, left: 40, right: 40),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/wyaclinicssplash.png', fit: BoxFit.scaleDown),
              SizedBox(
                height: 60,
              ),
              CircularProgressIndicator(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () async {
                  await launch('https://www.widdev.com',
                      forceSafariVC: false, forceWebView: false);
                },
                child: Text(
                  'Developed By Widdev',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void autoDelete() {
    try {
      db.getConnection().then((conn) async {
        await conn
            .query("Delete from `notice` WHERE date < now() - interval 1 day;");
        await conn.query(
            "Delete from `details` WHERE date < curdate() - interval 2 Month;");
        conn.close();
      });
    } catch (_) {}
  }

  void logingCheck() async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        var result;
        String sql =
            "SELECT * FROM `user` WHERE `member_index` = '$user' AND `password` = '$password'";
        result = await conn.query(sql);
        result = result.toList();

        if (result.toString() != '[]') {
          if (result[0]['type'] == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Home(
                        index: result[0]['member_index'].toString(),
                        appointment: result[0]['appointment'].toString(),
                        associateGroup:
                            result[0]['associated_group'].toString(),
                        group: result[0]['group'].toString(),
                        name: result[0]['name'].toString(),
                        password: result[0]['password'].toString())));
          }
        } else {
          await Flushbar(
            message: 'Verification error! Please sign in again',
            messageColor: Colors.red[500],
            icon: Icon(
              Icons.warning_rounded,
              color: Colors.red[500],
            ),
            duration: Duration(seconds: 3),
          ).show(context);

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Signin()));
        }
        conn.close();
      });
    } on SocketException catch (_) {
      await Flushbar(
        message: 'No Internet Connection !',
        messageColor: Colors.red[500],
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.red[500],
        ),
        mainButton: IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              logingCheck();
            }),
      ).show(context);
    } catch (e) {
      await Flushbar(
        message: "Something Wrong !",
        messageColor: Colors.red[500],
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.red[500],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }
}
