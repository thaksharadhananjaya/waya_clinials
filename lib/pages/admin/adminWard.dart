import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/util/comfirmDailogBox.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class AdminWard extends StatefulWidget {
  AdminWard({Key key}) : super(key: key);

  @override
  _AdminWardState createState() => _AdminWardState();
}

class _AdminWardState extends State<AdminWard> {
  Mysql db = new Mysql();
  String wardType = "Male";
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
          onPressed: buildAddWardBox,
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
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['ward_no'].toString()),
                            Text(data['gender']),
                            IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                tooltip: 'Delete this ward',
                                onPressed: () =>
                                    buildDeleteBox(data['ward_no']))
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

  Future buildDeleteBox(int wardNo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () => deleteWard(wardNo),
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

  Future buildAddWardBox() {
    int groupValue = 0;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController textEditingControllerWardNo =
              new TextEditingController();
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
                        "Add New Ward",
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
                  content: Container(
                    height: 60,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          child: TextFormField(
                            inputFormatters: [
                              new WhitelistingTextInputFormatter(
                                  RegExp("[0-9]")),
                            ],
                            controller: textEditingControllerWardNo,
                            decoration: CustomDecoration.decoration('Ward No'),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            groupValue = 0;
                            wardType = "Male";
                            FocusScope.of(context).unfocus();
                          }),
                          child: Container(
                            height: 90,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("  Male"),
                                Container(
                                  height: 8,
                                  width: 8,
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Radio(
                                    value: 0,
                                    groupValue: groupValue,
                                    focusColor: Colors.transparent,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (int value) {
                                      setState(() {
                                        groupValue = 0;
                                        wardType = "Male";
                                        FocusScope.of(context).unfocus();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => setState(() {
                            groupValue = 1;
                            wardType = "Female";
                            FocusScope.of(context).unfocus();
                          }),
                          child: Container(
                            height: 90,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Female"),
                                Container(
                                  height: 8,
                                  width: 8,
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Radio(
                                    value: 1,
                                    groupValue: groupValue,
                                    focusColor: Colors.transparent,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (int value) {
                                      setState(() {
                                        groupValue = 1;
                                        wardType = "Female";
                                        FocusScope.of(context).unfocus();
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
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
                            if (textEditingControllerWardNo.text.isNotEmpty) {
                              insertWard(textEditingControllerWardNo.text);
                              FocusScope.of(context).unfocus();
                            }
                          },
                          child: Text(
                            "Add",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                  ],
                ),
              ));
        });
  }

  Future getData() async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      var result;
      result = await conn.query('SELECT * FROM `ward`');
      result = result.toList();
      conn.close();
      return result;
    } on SocketException catch (_) {
      setState(() => internet = false);
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

  void insertWard(String wardNo) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("INSERT INTO `ward` VALUES ('$wardNo', '$wardType')");

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

  void deleteWard(int wardNo) async {
    try {
      await InternetAddress.lookup('google.com');
      var conn = await db.getConnection();
      await conn.query("DELETE FROM `ward` WHERE `ward_no` = '$wardNo'");
      Navigator.of(context).pop();
      conn.close();
      setState(() {});

      await Flushbar(
        message: 'Ward Delete!',
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
      await conn.query("DELETE FROM `ward`");
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
