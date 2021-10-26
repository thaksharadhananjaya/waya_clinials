import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/util/comfirmDailogBox.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class AdminConsultant extends StatefulWidget {
  AdminConsultant({Key key}) : super(key: key);

  @override
  _AdminConsultantState createState() => _AdminConsultantState();
}

class _AdminConsultantState extends State<AdminConsultant> {
  Mysql db = new Mysql();
  bool internet = true;

  @override
  Widget build(BuildContext context) {
    if (internet) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: buildConsultantList(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: buildAddDialogBox,
        ),
        // ignore: deprecated_member_use
        bottomNavigationBar: Container(
          height: 50,
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

  FutureBuilder buildConsultantList() {
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
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['consultant_name']),
                            IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                tooltip: 'Delete this consultant',
                                onPressed: () =>
                                    buildDeleteBox(data['consultant_name']))
                          ],
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

  Future buildDeleteBox(String consultantName) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () => deleteConsultant(consultantName),
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
            ),
          );
        });
  }

  Future buildAddDialogBox() {
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
                    "Add New Consultant",
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
              content: TextFormField(
                controller: textEditingControllerName,
                decoration: CustomDecoration.decoration('Consultant Name'),
                inputFormatters: [
                  // ignore: deprecated_member_use
                  new WhitelistingTextInputFormatter(RegExp("[a-zA-Z-. ]")),
                ],
                maxLength: 100,
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
                        if (textEditingControllerName.text.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          insertConsultant(textEditingControllerName.text);
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
      result = await conn.query('SELECT `consultant_name` FROM `consultant`');
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

  void insertConsultant(String consultantName) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query(
          "INSERT INTO `consultant`(`consultant_name`) VALUES ('$consultantName')");
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

  void deleteConsultant(String consultantName) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query(
          "DELETE FROM `consultant` WHERE `consultant_name` = '$consultantName'");
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Consultant Deleted !',
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

  void deleteAll() async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("DELETE FROM `consultant`");
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'All Consultants Delete!',
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
}
