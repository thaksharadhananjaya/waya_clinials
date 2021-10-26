import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/util/comfirmDailogBox.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class AdminMember extends StatefulWidget {
  AdminMember({Key key}) : super(key: key);

  @override
  _AdminMemberState createState() => _AdminMemberState();
}

class _AdminMemberState extends State<AdminMember> {
  Mysql db = new Mysql();
  bool internet = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2;
    if (internet) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: buildMemberList(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: buildAddDialogBox,
        ),
        bottomNavigationBar: Row(
          children: [
            Container(
              height: 50,
              width: width,
              // ignore: deprecated_member_use
              child: RaisedButton.icon(
                icon: Icon(Icons.refresh_outlined),
                onPressed: buildResetAllBox,
                color: Colors.orange,
                textColor: Colors.white,
                label: Text(
                  'Reset All',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Container(
              height: 50,
              width: width,
              // ignore: deprecated_member_use
              child: RaisedButton.icon(
                icon: Icon(Icons.delete),
                onPressed: buildDeleteAll,
                color: Colors.red[400],
                textColor: Colors.white,
                label: Text(
                  'Delete All',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return InternetError(
        onPress: () {
          setState(() {
            internet = true;
          });

          getData();
        },
      );
    }
  }

  FutureBuilder buildMemberList() {
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.4)),
                        child: ListTile(
                          title: Text(data['member_index']),
                          contentPadding: EdgeInsets.only(left: 4),
                          subtitle:
                              data['isUse'] == 1 ? Text('Active', style: TextStyle(color: Colors.redAccent),) : Text(''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.refresh_outlined,
                                      color: Colors.orange, size: 28),
                                  tooltip: 'Reset this member',
                                  onPressed: () =>
                                      buildResetBox(data['member_index'])),
                              IconButton(
                                  icon: Icon(Icons.remove_circle,
                                      color: Colors.red, size: 28),
                                  tooltip: 'Delete this member',
                                  onPressed: () =>
                                      buildDeleteBox(data['member_index'])),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Future buildDeleteBox(String index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () => deleteMember(index),
              ),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Future buildDeleteAll() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: deleteAll,
              ),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Future buildResetBox(String index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () => resetMember(index),
              ),
              icon: Icon(
                Icons.refresh_outlined,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Future buildResetAllBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              // ignore: deprecated_member_use
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: resetAll,
              ),
              icon: Icon(
                Icons.refresh_outlined,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Future buildAddDialogBox() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController textEditingControllerName =
              new TextEditingController();
          return WillPopScope(
            onWillPop: () async => null,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add New Member",
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () => Navigator.of(context).pop()),
                  )
                ],
              ),
              titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
              content: Form(
                key: _formKey,
                child: TextFormField(
                  controller: textEditingControllerName,
                  inputFormatters: [
                    // ignore: deprecated_member_use
                    new WhitelistingTextInputFormatter(RegExp("[0-9]")),
                  ],
                  keyboardType: TextInputType.number,
                  validator: (text) {
                    if (text.isEmpty)
                      return '';
                    else if (text.length < 6) return 'Enter Valid Index Number';
                    return null;
                  },
                  decoration: CustomDecoration.decoration('Index'),
                  maxLength: 6,
                ),
              ),
              actions: [
                Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).primaryColor),
                  // ignore: deprecated_member_use
                  child: FlatButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          insertMember(textEditingControllerName.text);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: Text(
                        "Add",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                )
              ],
            ),
          );
        });
  }

  Future getData() async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      var result;
      result = await conn.query('SELECT * FROM `member`');
      result = result.toList();
      conn.close();
      return result;
    } on SocketException catch (_) {
      setState(() => internet = false);
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

  void insertMember(String index) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn
          .query("INSERT INTO `member`(`member_index`) VALUES ('$index')");

      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Success!',
        messageColor: Colors.green[500],
        icon: Icon(
          Icons.info,
          color: Colors.green[500],
        ),
        duration: Duration(seconds: 3),
      ).show(context);
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

  void deleteMember(String index) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("DELETE FROM `member` WHERE `member_index` = '$index'");
      deleteUser(index);
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Member Delete!',
        messageColor: Colors.orange,
        icon: Icon(
          Icons.delete_rounded,
          color: Colors.orange,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
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

  void deleteAll() async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("DELETE FROM `member`");
      deleteAllUser();
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Delete All !',
        messageColor: Colors.orange,
        icon: Icon(
          Icons.delete_rounded,
          color: Colors.orange,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
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

  void resetMember(String index) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query(
          "UPDATE `member` SET `isUse`= 0  WHERE `member_index` = '$index'");
      deleteUser(index);
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Reset Success!',
        messageColor: Colors.orange,
        icon: Icon(
          Icons.delete_rounded,
          color: Colors.orange,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
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

  void resetAll() async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("UPDATE `member` SET `isUse` = '0'");
      deleteAllUser();
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Reset Success!',
        messageColor: Colors.orange,
        icon: Icon(
          Icons.delete_rounded,
          color: Colors.orange,
        ),
        duration: Duration(seconds: 3),
      ).show(context);
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

  void deleteUser(String index) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("DELETE FROM `user` WHERE `member_index` = '$index'");
      await conn.query(
          "DELETE FROM `user_consultant` WHERE `member_index` = '$index'");
      await conn
          .query("DELETE FROM `user_ward` WHERE `member_index` = '$index'");
      conn.close();
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

  void deleteAllUser() async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("DELETE FROM `user` WHERE type != 1");
      await conn.query("DELETE FROM `user_consultant`");
      await conn.query("DELETE FROM `user_ward`");
      await conn.query("DELETE FROM `details`");
      await conn.query("DELETE FROM `notice`");
      conn.close();
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
}
