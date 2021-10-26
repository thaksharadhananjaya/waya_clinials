import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/util/comfirmDailogBox.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class AdminBedType extends StatefulWidget {
  AdminBedType({Key key}) : super(key: key);

  @override
  _AdminBedTypeState createState() => _AdminBedTypeState();
}

class _AdminBedTypeState extends State<AdminBedType> {
  Mysql db = new Mysql();
  bool internet = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        bottomNavigationBar: Container(
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
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (context, index) {
                    String type = index != 0
                        ? snapshot.data[index-1]['bed_type']
                        : 'Normal';
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: type != 'Normal'
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4)
                                : Colors.orange),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(type),
                            IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: type != 'Normal'
                                        ? Colors.red
                                        : Colors.grey[400]),
                                tooltip: 'Delete this Bed Type',
                                onPressed: type != 'Normal'
                                    ? () => buildDeleteBox(type)
                                    : null)
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

  Future buildDeleteBox(String index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () => deleteBedType(index),
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
                    "Add New Bed Type",
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
                  decoration: CustomDecoration.decoration('Bed Type'),
                  validator: (text) {
                    RegExp regex = new RegExp("[']");
                    if (text.isEmpty)
                      return '';
                    else if (regex.hasMatch(text)) {
                      return 'Invalid Bed Type !';
                    }
                    return null;
                  },
                  maxLength: 20,
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
                          insertBedType(textEditingControllerName.text);
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
      var result = await conn.query("SELECT * FROM `bed_type` WHERE `bed_type` != 'Normal'");
      conn.close();
      return result.toList();
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

  void insertBedType(String bedType) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("INSERT INTO `bed_type` VALUES ('$bedType')");

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

  void deleteBedType(String bedType) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("DELETE FROM `bed_type` WHERE `bed_type` = '$bedType'");
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Bed Type Delete!',
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
      await conn.query("DELETE FROM `bed_type`");
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
