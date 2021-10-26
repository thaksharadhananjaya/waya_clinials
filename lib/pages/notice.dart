import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/popeties.dart';
import 'package:wayamba_medicine/util/comfirmDailogBox.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class Notice extends StatefulWidget {
  final String index;
  final String group;
  Notice({Key key, @required this.index, @required this.group})
      : super(key: key);

  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  StreamController streamControllerNotice = new StreamController.broadcast();
  Mysql db = new Mysql();
  bool internet = true;
  @override
  void initState() {
    super.initState();
    getNotice();
  }

  @override
  void dispose() {
    streamControllerNotice.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if (internet) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: buildNotice(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.notes),
          onPressed: () {
            buildPostDialog();
          },
        ),
      );
    } else {
      return InternetError(
        onPress: () {
          setState(() {
            internet = true;
          });

          getNotice();
        },
      );
    }
  }

  Widget buildNotice() {
    return RefreshIndicator(
      onRefresh: () async {
        streamControllerNotice.add(null);
        getNotice();
      },
      child: StreamBuilder(
          stream: streamControllerNotice.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                alignment: Alignment.center,
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (snapshot.data.toString() != "[]") {
                        var data = snapshot.data[index];
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onLongPress: () {
                              if (data['member_index'] == widget.index)
                                buildDeleteBox(data['post_id']);
                            },
                            child: Container(
                              height: 200,
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3)),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SelectableLinkify(
                                      linkStyle:
                                          TextStyle(color: Colors.deepPurple),
                                      onOpen: (link) async {
                                        if (await canLaunch(link.url))
                                          await launch(link.url);
                                      },
                                      text: data['notice'],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.person,
                                            size: 20, color: Colors.grey),
                                        Text(" By ${data['name']}   ",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        Icon(Icons.access_time,
                                            size: 20, color: Colors.grey),
                                        Text(" ${data['date']}",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Text('Not Found');
                      }
                    }),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future buildPostDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          double height = MediaQuery.of(context).size.height - 100;
          double width = MediaQuery.of(context).size.width - 30;
          TextEditingController textEditingControllerNotice =
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
                    "Enter Your Notice",
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
                alignment: Alignment.topCenter,
                width: width,
                height: height / 1.9,
                child: TextFormField(
                  controller: textEditingControllerNotice,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration:
                      CustomDecoration.decorationTextAria('Type Here...'),
                  maxLines: 12,
                  maxLength: 250,
                ),
              ),
              actions: [
                Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  // ignore: deprecated_member_use
                  child: FlatButton(
                      onPressed: () => textEditingControllerNotice.clear(),
                      child: Text(
                        "Clear",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  // ignore: deprecated_member_use
                  child: FlatButton(
                      onPressed: () {
                        if (textEditingControllerNotice.text.isNotEmpty)
                          insertNotice(textEditingControllerNotice.text);
                      },
                      child: Text(
                        "Post",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                )
              ],
            ),
          );
        });
  }

  Future buildDeleteBox(int postID) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              // ignore: deprecated_member_use
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () => deleteNotice(postID),
              ),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Future<void> getNotice() async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        await conn
            .query("Delete from `notice` WHERE date < now() - interval 1 day;");

        String sql =
            "SELECT `notice`.`post_id`, `notice`.`member_index`, `user`.`name`, `notice`.`notice`, DATE_FORMAT(`notice`.`date`, '%M %d  %h:%i %p') AS 'date' FROM `notice` INNER JOIN `user` ON `notice`.`member_index`= `user`.`member_index` WHERE `user`.`group`= '${widget.group}' OR `user`.`group`= '${widget.group}' ORDER BY `notice`.`date` DESC";

        var result = await conn.query(sql);
        //result = result.toList();
        if (!streamControllerNotice.isClosed)
          streamControllerNotice.add(result.toList());
        conn.close();
      });
    } on SocketException catch (_) {
      setState(() => internet = false);
    } catch (e) {
      setState(() {
        getNotice();
      });
    }
  }

  void insertNotice(String notice) {
    db.getConnection().then((conn) async {
      try {
        await InternetAddress.lookup('google.com');

        DateTime now = new DateTime.now();
        var format = DateFormat('yyyy-MM-dd HH:mm');
        String date = format.format(DateTime.parse(now.toString()));
        String sql =
            "INSERT INTO `notice`(`member_index`, `notice`, `date`) VALUES (?, ?, ?)";
        await conn.query(sql, [widget.index, notice, date]);

        Navigator.pop(context);
        getNotice();

        await Flushbar(
          message: 'Notice Post Success!',
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

      conn.close();
    });
  }

  void deleteNotice(int postID) {
    db.getConnection().then((conn) async {
      String sql = "DELETE FROM `notice` WHERE `post_id` = $postID";

      try {
        final result = await InternetAddress.lookup('google.com');
        await conn.query(sql);
        Navigator.pop(context);
        getNotice();
        await Flushbar(
          message: 'Notice Delete!',
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

      conn.close();
    });
  }
}
