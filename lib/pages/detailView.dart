import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/pages/detailsUpdate.dart';
import 'package:wayamba_medicine/popeties.dart';
import 'package:wayamba_medicine/util/alertButton.dart';
import 'package:wayamba_medicine/util/comfirmDailogBox.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/textContainer.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class Viewer extends StatefulWidget {
  final String date;
  final String index;
  final String group;
  final String associateGroup;
  final List<String> consultant;
  Viewer(
      {Key key,
      @required this.date,
      @required this.index,
      @required this.group,
      @required this.associateGroup,
      @required this.consultant})
      : super(key: key);

  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  StreamController streamControllerDetails = new StreamController.broadcast();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Mysql db = Mysql();
  TextEditingController textEditingControllerSearch =
      new TextEditingController();
  List<String> ward = [];
  List<String> bedType = [];
  String dropdownWard;
  String dropdownBedType;
  String dropdownStatus;
  bool internet = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  void dispose() {
    streamControllerDetails.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.date.isNotEmpty) {
      var outputFormat = DateFormat('yyyy-MMMM-dd');
      var outputDate = outputFormat.format(DateTime.parse(widget.date));

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(outputDate), centerTitle: true, actions: [
          AlertButton(
              index: widget.index,
              consultant: widget.consultant,
              group: widget.associateGroup,
              associatedGroup: widget.associateGroup)
        ]),
        body: internet
            ? buildDatails()
            : InternetError(
                onPress: () {
                  setState(() {
                    internet = true;
                  });

                  getDetails();
                },
              ),
      );
    } else {
      return internet
          ? buildDatails()
          : InternetError(
              onPress: () {
                setState(() {
                  internet = true;
                });

                getDetails();
              },
            );
    }
  }

  SingleChildScrollView buildDatails() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            // Search Box
            buildSearch(),

            SizedBox(
              height: 18,
            ),
            StreamBuilder(
                stream: streamControllerDetails.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.toString() != "[]") {
                      return Column(
                        children: [
                          buildDatailsList(snapshot),
                        ],
                      );
                    } else {
                      double top = MediaQuery.of(context).size.height / 2 - 260;
                      return Padding(
                          padding: EdgeInsets.only(top: top),
                          child: Column(
                            children: [
                              Image.asset(
                                'images/search.png',
                                fit: BoxFit.scaleDown,
                              ),
                              Text(
                                'No records found !',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ));
                    }
                  } else {
                    double top = MediaQuery.of(context).size.height / 2 - 170;
                    return Padding(
                      padding: EdgeInsets.only(top: top),
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  Row buildSearch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width - 90,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Form(
            key: _formKey,
            child: TextFormField(
              controller: textEditingControllerSearch,
              validator: (text) {
                RegExp regex = new RegExp("[']");
                if (regex.hasMatch(text)) return 'Invalid Search !';
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black87)),
                  contentPadding: EdgeInsets.only(left: 6, top: 6),
                  labelText: "Search",
                  labelStyle: TextStyle(fontSize: 17),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      streamControllerDetails.add(null);
                      setState(() {
                        textEditingControllerSearch.text.isNotEmpty
                            ? getSearchDetails(textEditingControllerSearch.text)
                            : getDetails();
                      });
                    },
                  )),
              maxLines: 1,
              onChanged: (text) {
                if (text.isEmpty) {
                  getDetails();
                }
               _formKey.currentState.validate();
              },
              onFieldSubmitted: (text) {
                if (_formKey.currentState.validate()) {
                  streamControllerDetails.add(null);
                  setState(() {
                    text.isNotEmpty ? getSearchDetails(text) : getDetails();
                  });
                }
              },
            ),
          ),
        ),
        IconButton(
            icon: Icon(
              Icons.filter_list,
            ),
            tooltip: 'Filter Records',
            iconSize: 32,
            onPressed: buildFilter)
      ],
    );
  }

  Future buildFilter() {
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
                      "Filter",
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
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextContainer(
                      child: DropdownButtonFormField(
                        value: dropdownWard,
                        hint: Text('Select Ward'),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownWard = newValue;
                          });
                        },
                        items:
                            ward.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        decoration: CustomDecoration.decorationDropDown(
                            'Ward', dropdownWard),
                      ),
                    ),
                    TextContainer(
                      child: DropdownButtonFormField(
                        value: dropdownBedType,
                        hint: Text('Select Bed Type'),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownBedType = newValue;
                          });
                        },
                        items: bedType
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        decoration: CustomDecoration.decorationDropDown(
                            'Bed Type', dropdownBedType),
                      ),
                    ),
                    // Status
                    TextContainer(
                      child: DropdownButtonFormField(
                        value: dropdownStatus,
                        validator: (text) {
                          if (dropdownStatus == null) {
                            return 'Select Status';
                          }
                          return null;
                        },
                        onChanged: (newValue) {
                          dropdownStatus = newValue;
                          FocusScope.of(context).unfocus();
                        },
                        items: <String>[
                          'New Admission',
                          'Old Admission',
                          'Not Occupied'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: CustomDecoration.decoration('Status'),
                      ),
                    ),
                  ],
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
                        onPressed: () {
                          dropdownBedType = null;
                          dropdownWard = null;
                          dropdownStatus = null;
                          streamControllerDetails.add(null);
                          getDetails();
                          Navigator.of(context).pop();
                        },
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
                          streamControllerDetails.add(null);
                          textEditingControllerSearch.text.isEmpty
                              ? getDetails()
                              : getSearchDetails(
                                  textEditingControllerSearch.text);

                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Filter",
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

  Widget buildDatailsList(AsyncSnapshot snapshot) {
    double height = widget.date.isNotEmpty
        ? MediaQuery.of(context).size.height - 170 // For Calender View
        : MediaQuery.of(context).size.height - 220; // For Record View
    return RefreshIndicator(
      onRefresh: () async {
        streamControllerDetails.add(null);
        textEditingControllerSearch.text.isEmpty
            ? getDetails()
            : getSearchDetails(textEditingControllerSearch.text);
      },
      child: Container(
        height: height,
        child: ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              var data = snapshot.data[index];
              return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: data['status'].toString() == 'Old Admission'
                        ? Colors.blue[400]
                        : (data['status'].toString() == 'New Admission'
                            ? Colors.orange[500]
                            : Colors.teal[400]),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 24.0, left: 6.0, right: 6.0, bottom: 6.0),
                      child: ExpansionTile(
                        expandedAlignment: Alignment.centerLeft,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Member Index 1",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text(data['member_index1'].toString(),
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                Text("Member Index 2",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text(
                                    data['member_index2'].toString() != 'null'
                                        ? data['member_index2'].toString()
                                        : '',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                Text(
                                  "Ward No",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(data['ward_no'].toString(),
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                Text("Bed No",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                data['bed_no'].toString() != 'Special'
                                    ? (data['bed_type'].toString() == 'null'
                                        ? Text(data['bed_no'].toString(),
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17))
                                        : Text(
                                            '${data['bed_no'].toString()} - ${data['bed_type'].toString()} Bed',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17)))
                                    : Text(
                                        '${data['bed_no'].toString()} - Special Bed',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    tooltip: 'Edit',
                                    icon: Icon(Icons.edit,
                                        color: Colors.white, size: 38),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => DetailUpdate(
                                                  index: data['member_index1']
                                                      .toString(),
                                                  wardNo: data['ward_no']
                                                      .toString(),
                                                  bedNo:
                                                      data['bed_no'].toString(),
                                                  bedType: data['bed_type'],
                                                  consultant:
                                                      data['consultant_name']
                                                          .toString(),
                                                  index2: data['member_index2']
                                                      .toString(),
                                                  history: data['history']
                                                      .toString(),
                                                  examination:
                                                      data['exmination']
                                                          .toString(),
                                                  presenting:
                                                      data['presenting_complaint']
                                                          .toString(),
                                                  possible: data['possible_dd']
                                                      .toString(),
                                                  status:
                                                      data['status'].toString(),
                                                  group: widget.group,
                                                  associatedGroup:
                                                      widget.group)));
                                    }),
                                SizedBox(
                                  height: 18,
                                ),
                                IconButton(
                                    tooltip: 'Delete',
                                    icon: Icon(Icons.delete,
                                        color: Colors.red, size: 38),
                                    onPressed: () => buildDeleteBox(
                                        data['member_index1'].toString(),
                                        data['ward_no'].toString(),
                                        data['bed_type'].toString(),
                                        data['date'].toString(),
                                        data['bed_no']))
                              ],
                            ),
                          ],
                        ),
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text("Status",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          Text(data['status'].toString(),
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          Divider(color: Colors.white70),
                          Text("Consultant Name",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          Text(
                              data['consultant_name'].toString() != 'null'
                                  ? data['consultant_name'].toString()
                                  : '',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          Divider(color: Colors.white70),
                          Text("History",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          Text(
                              data['history'].toString() != 'null'
                                  ? data['history'].toString()
                                  : '',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          Divider(color: Colors.white70),
                          Text("Exmination",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          Text(
                              data['exmination'].toString() != 'null'
                                  ? data['exmination'].toString()
                                  : '',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          Divider(color: Colors.white70),
                          Text(
                              "Presenting Complaint & DD", //Presenting Complaint --> Presenting Complaint & DD
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          SelectableLinkify(
                              linkStyle: TextStyle(color: Colors.deepPurple),
                              onOpen: (link) async {
                                if (await canLaunch(link.url))
                                  await launch(link.url);
                              },
                              text: data['presenting_complaint'].toString(),
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          Divider(color: Colors.white70),
                          Text(
                              "Management & What I Learnt", // Possible DD --> Management & What I Learnt
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          SelectableLinkify(
                              linkStyle: TextStyle(color: Colors.deepPurple),
                              onOpen: (link) async {
                                if (await canLaunch(link.url))
                                  await launch(link.url);
                              },
                              text: data['possible_dd'].toString(),
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                        ],
                      ),
                    ),
                  ));
            }),
      ),
    );
  }

  Future buildDeleteBox(
      String index, String wardNo, String bedType, String date, int bedNo) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ComfirmDailogBox(
              // ignore: deprecated_member_use
              yesButton: FlatButton(
                child: Text('Yes',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                onPressed: () =>
                    deleteRecord(index, wardNo, bedType, date, bedNo),
              ),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 48,
              ));
        });
  }

  Future<void> getDetails() async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        await conn.query(
            "Delete from `details` WHERE date < curdate() - interval 2 Month;");

        String fillterText = '';
        if (dropdownStatus != null)
          fillterText += "`status` = '$dropdownStatus'";
        if (dropdownBedType != null)
          fillterText += fillterText == ''
              ? "`bed_type` = '$dropdownBedType'"
              : " AND `bed_type` = '$dropdownBedType'";
        if (dropdownWard != null) {
          int end = dropdownWard.toString().indexOf(" W");
          String wardNo = dropdownWard.substring(0, end);
          fillterText += fillterText == ''
              ? "`ward_no` = '$wardNo'"
              : " AND `ward_no` = '$wardNo'";
        }

        String sql = fillterText == ''
            ? "SELECT * FROM `details` WHERE (`group` = '${widget.group}' OR `group` = '${widget.associateGroup}' ) AND date Like '${widget.date}%' ORDER BY `bed_no` ASC"
            : "SELECT * FROM `details` WHERE (`group` = '${widget.group}' OR `group` = '${widget.associateGroup}' ) AND date Like '${widget.date}%' AND $fillterText ORDER BY `bed_no` ASC";

        var result = await conn.query(sql);
        if (!streamControllerDetails.isClosed)
          streamControllerDetails.add(result.toList());

        sql =
            "SELECT CONCAT(`ward_no`,' -  ' ,`gender`, ' Ward') AS 'ward' FROM `ward`";
        ward = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            ward.add(row[0]);
          }
        });

        sql = "SELECT * FROM `bed_type`";
        bedType = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            bedType.add(row[0].toString());
          }
        });

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

  void getSearchDetails(String search) async {
    String fillterText = '';
    if (dropdownStatus != null) fillterText += "`status` = '$dropdownStatus'";
    if (dropdownBedType != null)
      fillterText += fillterText == ''
          ? "`bed_type` = '$dropdownBedType'"
          : " AND `bed_type` = '$dropdownBedType'";
    if (dropdownWard != null) {
      int end = dropdownWard.toString().indexOf(" W");
      String wardNo = dropdownWard.substring(0, end);
      fillterText += fillterText == ''
          ? "`ward_no` = '$wardNo'"
          : " AND `ward_no` = '$wardNo'";
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        String sql;
        if (widget.date.isEmpty) {
          sql = fillterText == ''
              ? "SELECT * FROM `details` WHERE (`group` = '${widget.group}' OR `group` = '${widget.associateGroup}' ) AND (member_index1 = '$search' OR member_index2 = '$search' OR bed_no = '$search' OR `possible_dd` LIKE '%$search%' OR `presenting_complaint` LIKE '%$search%') ORDER BY `bed_no` ASC"
              : "SELECT * FROM `details` WHERE (`group` = '${widget.group}' OR `group` = '${widget.associateGroup}' ) AND $fillterText AND (member_index1 = '$search' OR member_index2 = '$search' OR bed_no = '$search' OR `possible_dd` LIKE '%$search%' OR `presenting_complaint` LIKE '%$search%') ORDER BY `bed_no` ASC";
        } else {
          sql = fillterText == ''
              ? "SELECT * FROM `details` WHERE date Like '${widget.date}%' AND (`group` = '${widget.group}' OR `group` = '${widget.associateGroup}' ) AND (member_index1 = '$search' OR member_index2 = '$search' OR bed_no = '$search' OR `possible_dd` LIKE '%$search%' OR `presenting_complaint` LIKE '%$search%') ORDER BY `bed_no` ASC"
              : "SELECT * FROM `details` WHERE date Like '${widget.date}%' AND (`group` = '${widget.group}' OR `group` = '${widget.associateGroup}' ) AND $fillterText AND (member_index1 = '$search' OR member_index2 = '$search' OR bed_no = '$search' OR `possible_dd` LIKE '%$search%' OR `presenting_complaint` LIKE '%$search%') ORDER BY `bed_no` ASC";
        }

        var result = await conn.query(sql);
        streamControllerDetails.add(result.toList());
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

  Future<void> deleteRecord(String index, String wardNo, String bedType,
      String date, int bedNo) async {
    try {
      await InternetAddress.lookup('google.com');
      FocusScope.of(context).unfocus();
      db.getConnection().then((conn) async {
        String sql =
            "DELETE FROM `details` WHERE `ward_no` = '$wardNo' AND `bed_no`= '$bedNo' AND `bed_type` = '$bedType' AND `member_index1` ='$index' AND `date`='$date'";
        await conn.query(sql);
        conn.close();
        getDetails();
        textEditingControllerSearch.clear();
        Navigator.of(context).pop();
        FocusScope.of(context).unfocus();
        await Flushbar(
          message: 'Record Delete!',
          messageColor: Colors.orange,
          icon: Icon(
            Icons.delete_rounded,
            color: Colors.orange,
          ),
          duration: Duration(seconds: 3),
        ).show(context);
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
}
