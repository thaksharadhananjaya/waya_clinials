import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:wayamba_medicine/models/mysql.dart';

const myTask = "simplePeriodicTask";

class AlertButton extends StatefulWidget {
  AlertButton(
      {Key key,
      @required this.consultant,
      @required this.group,
      @required this.associatedGroup,
      @required this.index})
      : super(key: key);
  final List<String> consultant;
  final String group;
  final String associatedGroup;
  final String index;

  @override
  _AlertButtonState createState() => _AlertButtonState();
}

class _AlertButtonState extends State<AlertButton> {
  String dropdownValue;
  Mysql db = new Mysql();

  bool enable = true;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.notification_important),
      onPressed: enable
          ? () {
              if (widget.consultant.length > 0) buildDialog();
            }
          : null,
    );
  }

  Future buildDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Consultant",
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
            content: Container(
              width: double.maxFinite,
              child: widget.consultant.length == 1
                  ? Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                      child: FlatButton(
                        onPressed: () => setAlert(widget.consultant[0]),
                        child: Text(
                          widget.consultant[0],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : (widget.consultant.length == 2
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                onPressed: () => setAlert(widget.consultant[0]),
                                child: Text(
                                  widget.consultant[0],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                onPressed: () => setAlert(widget.consultant[1]),
                                child: Text(
                                  widget.consultant[1],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                onPressed: () => setAlert(widget.consultant[0]),
                                child: Text(
                                  widget.consultant[0],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                onPressed: () => setAlert(widget.consultant[1]),
                                child: Text(
                                  widget.consultant[1],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)),
                              // ignore: deprecated_member_use
                              child: FlatButton(
                                onPressed: () => setAlert(widget.consultant[2]),
                                child: Text(
                                  widget.consultant[2],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          ],
                        )),
            ),
          );
        });
  }

  void setAlert(String consultantName) async {
    Navigator.of(context).pop();
    try {
      await InternetAddress.lookup('google.com');
      setState(() => enable = false);
      var conn = await db.getConnection();
      String sql = widget.associatedGroup != 'null'
          ? "UPDATE `user` SET `consultant`='$consultantName',`alert`=1 WHERE (`group` = '${widget.group}' OR `group` = '${widget.associatedGroup}' OR `associated_group` = '${widget.associatedGroup}') AND `member_index` != '${widget.index}'"
          : "UPDATE `user` SET `consultant`='$consultantName',`alert`=1 WHERE `group` = '${widget.group}' AND `member_index` != '${widget.index}'";
      await conn.query(sql);
      setState(() => enable = true);
      conn.close();
      await Flushbar(
        message: 'Alert Sent Success!',
        messageColor: Colors.green[500],
        icon: Icon(
          Icons.info,
          color: Colors.green[500],
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

    setState(() => enable = true);
  }
}
