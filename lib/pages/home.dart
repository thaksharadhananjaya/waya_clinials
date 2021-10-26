import 'dart:async';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/pages/detail.dart';
import 'package:wayamba_medicine/pages/notice.dart';
import 'package:wayamba_medicine/pages/pofileUpdate.dart';
import 'package:wayamba_medicine/pages/signin.dart';
import 'package:wayamba_medicine/popeties.dart';
import 'package:wayamba_medicine/util/alertBox.dart';
import 'package:wayamba_medicine/util/alertButton.dart';
import 'package:wayamba_medicine/util/internetNot.dart';
import 'package:wayamba_medicine/util/textContainer.dart';
import 'package:wayamba_medicine/pages/about.dart';
import 'detailView.dart';

class Home extends StatefulWidget {
  final String index;
  final String password;
  final String name;
  final String group;
  final String associateGroup;
  final String appointment;

  Home(
      {Key key,
      this.index,
      this.password,
      this.name,
      this.group,
      this.associateGroup,
      this.appointment})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Mysql db = Mysql();
  CalendarController _calendarController;
  final storage = new FlutterSecureStorage();
  TabController tabController;
  int tabIndex = 0;
  List<String> consultant = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer timerAlert;
  Timer timerCheckNet;
  bool internet = true;

  @override
  void initState() {
    super.initState();
    getSummery();

    _calendarController = CalendarController();
    _calendarController = CalendarController();
    tabController = new TabController(length: 3, vsync: this);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    //var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: null);
    checkAlert();
  }

  @override
  void dispose() {
    timerAlert.cancel();
    timerCheckNet.cancel();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(day);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Viewer(
                  date: outputDate,
                  index: widget.index,
                  group: widget.group,
                  associateGroup: widget.associateGroup,
                  consultant: consultant,
                )));
    setState(() {});
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {}

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {}

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        {
          MoveToBackground.moveTaskToBack();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            AlertButton(
                index: widget.index,
                consultant: consultant,
                group: widget.group,
                associatedGroup: widget.associateGroup)
          ],
          bottom: TabBar(
            controller: tabController,
            onTap: (index) {
              setState(() {
                tabIndex = index;
                FocusScope.of(context).unfocus();
              });
            },
            tabs: [
              Tab(
                text: 'Home',
              ),
              Tab(
                text: 'Record',
              ),
              Tab(
                text: 'Notice',
              ),
            ],
          ),
          title: Text('Waya Clinicals',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            internet
                ? buildDashboad(screenHeight, screenWidth)
                : InternetError(
                    onPress: () {
                      setState(() {
                        internet = true;
                      });
                      getSummery();
                    },
                  ),
            Viewer(
              date: "",
              index: widget.index,
              group: widget.group,
              associateGroup: widget.associateGroup,
              consultant: consultant,
            ),
            Notice(
              index: widget.index,
              group: widget.group,
            )
          ],
        ),
        floatingActionButton: tabIndex == 0
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Detail(
                                index: widget.index,
                                group: widget.group,
                                associatedGroup: widget.associateGroup,
                                consultant: consultant,
                              )));
                },
              )
            : null,
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
                        widget.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            fontSize: 58, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.index,
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
                      onPressed: () async {
                        if (timerAlert.isActive) timerAlert.cancel();

                        await storage.deleteAll();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Signin()));
                      },
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
                            Icon(Icons.account_box),
                            SizedBox(
                              width: 4,
                            ),
                            Text('Edit Profile',
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
                    onPressed: () {
                      int len = consultant.length;

                      switch (len) {
                        case 1:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileUpdate(
                                        index: widget.index,
                                        group: widget.group,
                                        appointment: widget.appointment,
                                        associateGroup: widget.associateGroup,
                                        consultant1: consultant[0],
                                        name: widget.name,
                                        password: widget.password,
                                      )));
                          break;
                        case 2:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileUpdate(
                                        index: widget.index,
                                        group: widget.group,
                                        appointment: widget.appointment,
                                        associateGroup: widget.associateGroup,
                                        consultant1: consultant[0],
                                        consultant2: consultant[1],
                                        name: widget.name,
                                        password: widget.password,
                                      )));
                          break;
                        case 3:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileUpdate(
                                        index: widget.index,
                                        group: widget.group,
                                        appointment: widget.appointment,
                                        associateGroup: widget.associateGroup,
                                        consultant1: consultant[0],
                                        consultant2: consultant[1],
                                        consultant3: consultant[2],
                                        name: widget.name,
                                        password: widget.password,
                                      )));
                      }
                    },
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

  Container buildTableCalendar() {
    DateTime date = DateTime.now();
    return Container(
      child: TableCalendar(
        calendarController: _calendarController,
        startingDayOfWeek: StartingDayOfWeek.monday,
        endDay: date,
        calendarStyle: CalendarStyle(
          selectedColor: color[500],
          todayColor: color[200],
          markersColor: color[700],
          outsideDaysVisible: false,
        ),
        headerStyle:
            HeaderStyle(formatButtonVisible: false, rightChevronVisible: true),
        onDaySelected: _onDaySelected,
        onVisibleDaysChanged: _onVisibleDaysChanged,
        onCalendarCreated: _onCalendarCreated,
      ),
    );
  }

  Container buildDashboad(double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight - 150,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
            Text(
              'Select Date',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 4,
            ),
            buildTableCalendar(),
            //bulildSummery(screenHeight, screenWidth),
          ],
        ),
      ),
    );
  }

  Padding bulildSummery(double screenHeight, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Container(
        height: screenHeight / 4,
        width: screenWidth - 40,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 2, color: Colors.black26)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: color[200]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Group',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${widget.group}'),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black38,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth - 40,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: color[200]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultants',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 80,
                    child: ListView.builder(
                        itemCount: consultant == null ? 0 : consultant.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text('${consultant[index]}');
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                            } else if (text.length < 4) {
                              return 'Password must have at least 4 characters';
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
                      color: color,
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            FocusScope.of(context).unfocus();
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

  void getSummery() async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        var result;

        String sql =
            "SELECT `consultant_name` FROM  `user_consultant` WHERE `member_index` = '${widget.index}'";
        result = await conn.query(sql);
        for (var row in result) {
          consultant.add(row[0]);
        }
        conn.close();
      });
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

  void updatePassword(String password) async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        String sql =
            "UPDATE `user` SET `password` = '$password' WHERE `member_index` = '${widget.index}'";
        await conn.query(sql);
        conn.close();

        Navigator.pop(context);

        await Flushbar(
          message: 'Password Update Success !',
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

  showNotification(String consutant) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.high, importance: Importance.max);
    // var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin
        .show(0, consutant, consutant, platform, payload: 'AndroidCoding.in');
  }

  void checkAlert() async {
    var conn = await db.getConnection();
    timerAlert = new Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      try {
        await InternetAddress.lookup('google.com');
        var result;
        result = await conn.query(
            "SELECT `alert`, `consultant` FROM `user` WHERE `member_index` = '${widget.index}'");

        await conn.query(
            "UPDATE `user` SET `consultant`= '', `alert`=0 WHERE  `member_index` = '${widget.index}'");

        result = result.toList();
        if (result[0]['alert'] == 1) {
          showNotification(result[0]['consultant']);
          FlutterRingtonePlayer.playRingtone();
          buildMassage(result[0]['consultant']);
        }
      } on SocketException catch (_) {
        timerAlert.cancel();
        timer.cancel();
        checkConnection();
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
        timerAlert.cancel();
        timer.cancel();
        checkConnection();
      }
    });
  }

  void checkConnection() async {
    timerCheckNet =
        new Timer.periodic(Duration(milliseconds: 500), (Timer timer) async {
      try {
        await InternetAddress.lookup('google.com');
        timerCheckNet.cancel();
        timer.cancel();
        checkAlert();
      } catch (_) {}
    });
  }

  Future buildMassage(String cosultant) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => null,
              child: AlertBox(
                consltant: cosultant,
              ));
        });
  }

  exitNow() {
    SystemChannels.platform.invokeListMethod('SystemNavigator.pop');
  }
}
