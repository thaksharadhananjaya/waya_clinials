import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/pages/admin/adminHome.dart';
import 'package:wayamba_medicine/pages/home.dart';
import 'package:wayamba_medicine/pages/signup.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/textContainer.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode focusNodePass = new FocusNode();
  final storage = new FlutterSecureStorage();
  Mysql db = Mysql();
  String index;
  String password;
  bool checkValue = true;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    //getDetails();
  }

  void saveLoging(String user, String password) async {
    await storage.write(key: 'user', value: user);
    await storage.write(key: 'pass', value: password);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => exitNow(),
      child: Scaffold(
        body: buildForm(context),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    double height = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: height > 800
                ? const EdgeInsets.fromLTRB(24, 50, 24, 10)
                : const EdgeInsets.fromLTRB(24, 36, 24, 10),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'images/wayaclinics.png',
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(
                  height: height > 800 ? 50 : 30,
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sign in to your account',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: shortestSide < 600 ? 18 : 25,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 20,
                ),

                // Index
                TextContainer(
                  child: TextFormField(
                      maxLength: 6,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Index',
                          counter: Text(''),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black87)),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 8)),
                      validator: (text) {
                        RegExp regex = new RegExp("[']");
                        if (text.isEmpty)
                          return 'Enter Index Number';
                        else if (regex.hasMatch(text))
                          return 'Invalid Index Number !';
                        return null;
                      },
                      onFieldSubmitted: (text) {
                        if (text.isNotEmpty) focusNodePass.requestFocus();
                      },
                      onSaved: (value) {
                        index = value;
                      }),
                ),

                // Password
                TextContainer(
                    child: TextFormField(
                        maxLength: 8,
                        focusNode: focusNodePass,
                        obscureText: passwordVisible ? false : true,
                        decoration: inputDecPswd(),
                        validator: (text) {
                          RegExp regex = new RegExp("[']");
                          if (text.isEmpty) {
                            return 'Enter Password';
                          } else if (text.length < 4) {
                            return 'Invalid Password !';
                          } else if (regex.hasMatch(text)) {
                            return 'Invalid Password !';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value;
                        })),
                SizedBox(
                  height: 20,
                ),

                // Loging Buttons
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  decoration: CustomDecoration.decorationButton(),
                  child: FlatButton(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        logingCheck();
                      } else {
                        return;
                      }
                    },
                  ),
                ),

                SizedBox(
                  height: 8,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                        value: checkValue,
                        onChanged: (newValue) =>
                            setState(() => checkValue = newValue)),
                    AutoSizeText(
                      'Keep me signed in ',
                    ),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText("Don't have an account"),
                    SizedBox(width: 10),
                    GestureDetector(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future buildVerifivation() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          new TextEditingController();
          return WillPopScope(
            onWillPop: () async => null,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                "Sign In...",
              ),
              titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
              content: Container(
                  alignment: Alignment.center,
                  height: 80,
                  width: double.maxFinite,
                  child: CircularProgressIndicator()),
            ),
          );
        });
  }

  InputDecoration inputDecPswd() {
    return InputDecoration(
      hintText: 'Password',
      counter: Text(''),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black87)),
      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      prefixIcon: Icon(
        Icons.lock,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          passwordVisible ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: () {
          setState(() {
            passwordVisible = !passwordVisible;
          });
        },
      ),
    );
  }

  void logingCheck() async {
    try {
      await InternetAddress.lookup('google.com');
      buildVerifivation();
      db.getConnection().then((conn) async {
        var result;
        String sql =
            "SELECT * FROM `user` WHERE `member_index` = '$index' AND `password` = '$password'";
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
            if (checkValue)
              saveLoging(result[0]['member_index'].toString(),
                  result[0]['password'].toString());
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminHome(
                        userName: result[0]['member_index'].toString(),
                        password: result[0]['password'].toString())));
          }
        } else {
          Navigator.of(context).pop();
          await Flushbar(
            message: 'Wrong Index Number Or Password !',
            messageColor: Colors.red[500],
            icon: Icon(
              Icons.warning_rounded,
              color: Colors.red[500],
            ),
            duration: Duration(seconds: 3),
          ).show(context);
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
        duration: Duration(seconds: 3),
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

  exitNow() {
    SystemChannels.platform.invokeListMethod('SystemNavigator.pop');
  }
}
