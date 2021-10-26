import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/pages/about.dart';
import 'package:wayamba_medicine/pages/signin.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/textContainer.dart';
import 'adminWard.dart';
import 'adminBedType.dart';
import 'adminAppointment.dart';
import 'adminMember.dart';
import 'adminConsultant.dart';
import 'adminGroup.dart';

class AdminHome extends StatefulWidget {
  final String userName;
  final String password;

  AdminHome({
    Key key,
    this.userName,
    this.password,
  }) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  Mysql db = new Mysql();
  TabController tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => exitNow(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            controller: tabController,
            onTap: (index) {
              setState(() {
                tabIndex = index;
                FocusScope.of(context).unfocus();
              });
            },
            tabs: [
              Tab(
                text: 'Member',
              ),
              Tab(
                text: 'Ward',
              ),
              Tab(
                text: 'Group',
              ),
              Tab(
                text: 'Consultant',
              ),
              Tab(
                text: 'Appointment',
              ),
              Tab(
                text: 'Bed Type',
              ),
            ],
          ),
          title: Row(
            children: [
              Text('Waya Clinicals',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(' Admin',
                    style: TextStyle(fontSize: 10, color: Colors.red)),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            AdminMember(),
            AdminWard(),
            AdminGroup(),
            AdminConsultant(),
            AdminAppointment(),
            AdminBedType()
          ],
        ),
        drawer: buildDrawer(),
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
        child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.green,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green[200],
                      child: Text(
                        widget.userName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            fontSize: 58, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    widget.userName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Admin',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6)),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Signin())),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(
                              width: 4,
                            ),
                            Text('Change Username',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                    onPressed: () => buildChangeUsername(),
                  ),

                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock),
                            SizedBox(
                              width: 4,
                            ),
                            Text('Change Password',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                    onPressed: () => buildChangePassword(),
                  ),

                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info),
                            SizedBox(
                              width: 4,
                            ),
                            Text('About',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.arrow_forward_ios)),
                      ],
                    ),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => About())),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  await launch('https://www.widdev.com',
                      forceSafariVC: false, forceWebView: false);
                },
                child: Text(
                  'Developed By Widdev',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w700),
                ),
              )
            ]),
      ),
    ));
  }

  Future buildChangePassword() {
    bool passwordVisible = false;
    bool passwordOldVisible = false;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    //Pasword Decoration
    InputDecoration decPswd(
        BuildContext context, String label, StateSetter setState) {
      return InputDecoration(
        labelText: label,
        counter: Text(''),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black87)),
        contentPadding: EdgeInsets.symmetric(horizontal: 6),
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

    TextEditingController textEditingControllerOldPass =
        new TextEditingController();
    TextEditingController textEditingControllerNewPass =
        new TextEditingController();
// Change Password Dailog Box
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => null,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
                  AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Change Password",
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
                titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      // Old Password
                      TextContainer(
                        child: TextFormField(
                          validator: (text) {
                            if (text.isEmpty)
                              return 'Enter Old Password';
                            else if (text != widget.password)
                              return "Wrong Password !";
                            return null;
                          },
                          controller: textEditingControllerOldPass,
                          obscureText: passwordOldVisible ? false : true,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            labelText: 'Old Password',
                            counter: Text(''),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.black87)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 6),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordOldVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordOldVisible = !passwordOldVisible;
                                });
                              },
                            ),
                          ),
                          maxLength: 8,
                        ),
                      ),

                      // New Password
                      TextContainer(
                        child: TextFormField(
                          validator: (text) {
                            RegExp regex = new RegExp("[']");
                            if (text.isEmpty) {
                              return 'Enter Password';
                            } else if (text.length < 6) {
                              return 'Password must have at least 6 characters';
                            } else if (regex.hasMatch(text)) {
                              return 'Invalid Password !';
                            }
                            return null;
                          },
                          controller: textEditingControllerNewPass,
                          obscureText: passwordVisible ? false : true,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration:
                              decPswd(context, 'New Password', setState),
                          maxLength: 8,
                        ),
                      ),

                      // Comfirm Password
                      TextContainer(
                        child: TextFormField(
                          validator: (text) {
                            if (text.isEmpty)
                              return 'Retype Password';
                            else if (text != textEditingControllerNewPass.text)
                              return "Password Dosen't Match";
                            return null;
                          },
                          obscureText: passwordVisible ? false : true,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration:
                              decPswd(context, 'Comfirm Password', setState),
                          maxLength: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            updatePassword(textEditingControllerNewPass.text);
                          } else {
                            return;
                          }
                        },
                        child: Text(
                          "Change",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future buildChangeUsername() {
    TextEditingController textEditingControllerUsername =
        new TextEditingController();
// Change Password Dailog Box
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => null,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
                  AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Change Username",
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
                titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
                content: TextContainer(
                  child: TextFormField(
                    controller: textEditingControllerUsername,
                    decoration: CustomDecoration.decoration('New Username'),
                    maxLength: 6,
                  ),
                ),
                actions: [
                  Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.green),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                        onPressed: () {
                          if (textEditingControllerUsername.text.isNotEmpty) {
                            FocusScope.of(context).unfocus();
                            updateUsername(textEditingControllerUsername.text);
                          }
                        },
                        child: Text(
                          "Change",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  )
                ],
              ),
            ),
          );
        });
  }

  void updatePassword(String password) async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        String sql =
            "UPDATE `user` SET `password` = '$password' WHERE `member_index` = '${widget.userName}'";
        await conn.query(sql);
        conn.close();

        Navigator.pop(context);

        await Flushbar(
          message: 'Password Update Success!',
          messageColor: Colors.green,
          icon: Icon(
            Icons.info,
            color: Colors.green,
          ),
          duration: Duration(seconds: 3),
        ).show(context);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Signin()));
      });
    } on SocketException catch (_) {
      await Flushbar(
        message: 'No Internet Connection!',
        messageColor: Colors.red[500],
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.red[500],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    } catch (e) {
      await Flushbar(
        message: "Something Wrong!",
        messageColor: Colors.red[500],
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.red[500],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    }
  }

  void updateUsername(String username) async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        String sql =
            "UPDATE `user` SET `member_index` = '$username' WHERE `member_index` = '${widget.userName}'";
        await conn.query(sql);
        conn.close();

        Navigator.pop(context);

        await Flushbar(
          message: 'Username Update Success!',
          messageColor: Colors.green,
          icon: Icon(
            Icons.info,
            color: Colors.green,
          ),
          duration: Duration(seconds: 3),
        ).show(context);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Signin()));
      });
    } on SocketException catch (_) {
      await Flushbar(
        message: 'No Internet Connection!',
        messageColor: Colors.red[500],
        icon: Icon(
          Icons.warning_rounded,
          color: Colors.red[500],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
    } catch (e) {
      await Flushbar(
        message: "Something Wrong!",
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
