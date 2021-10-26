import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/util/alertButton.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/textContainer.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class DetailUpdate extends StatefulWidget {
  final String index;
  final String wardNo;

  final String bedNo;
  final String status;

  final String consultant;
  final String index2;
  final String history;
  final String examination;
  final String presenting;
  final String possible;
  final String group;
  final String associatedGroup;
  String bedType;

  DetailUpdate(
      {Key key,
      @required this.index,
      @required this.wardNo,
      @required this.bedNo,
      @required this.consultant,
      @required this.index2,
      @required this.history,
      @required this.examination,
      @required this.presenting,
      @required this.possible,
      @required this.status,
      @required this.group,
      @required this.associatedGroup,
      this.bedType})
      : super(key: key);

  @override
  _DetailUpdateState createState() => _DetailUpdateState();
}

class _DetailUpdateState extends State<DetailUpdate> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textControllerBedNo = TextEditingController();
  TextEditingController textControllerIndex = TextEditingController();
  TextEditingController textControllerIndex2 = TextEditingController();
  TextEditingController textControllerPresenting = TextEditingController();
  TextEditingController textControllerPossible = TextEditingController();

  List<String> consultant = [];
  List<DropdownMenuItem<String>> ward = new List();
  List<String> bedType = [];
  String dropdownWard = '';
  String dropdownConsultantValue;
  String dropdownStatusValue;
  String dropdownHistoryValue;
  String dropdownExamValue;
  String dropdownBedType;
  String wardNo;
  Mysql db = Mysql();
  bool progress = true;
  bool internet = true;

  @override
  void initState() {
    super.initState();
    getData(widget.index);
    textControllerIndex.text = widget.index;
    textControllerIndex2.text = widget.index2;
    textControllerPossible.text = widget.possible;
    textControllerPresenting.text = widget.presenting;
    dropdownWard = widget.wardNo + " Ward";

    dropdownStatusValue = widget.status;
    textControllerBedNo.text = widget.bedNo;
    widget.history != 'null'
        ? dropdownHistoryValue = widget.history
        : dropdownHistoryValue = "Not Done";
    widget.examination != 'null'
        ? dropdownExamValue = widget.examination
        : dropdownExamValue = "Not Done";
    if (widget.consultant != 'null')
      dropdownConsultantValue = widget.consultant;
    if (widget.bedType != 'null') dropdownBedType = widget.bedType;

    wardNo = widget.wardNo;
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Edit"), centerTitle: true, actions: [
        AlertButton(
            index: widget.index,
            consultant: consultant,
            group: widget.group,
            associatedGroup: widget.associatedGroup)
      ]),
      body: internet
          ? (progress
              ? Center(child: CircularProgressIndicator())
              : buildForm())
          : InternetError(
              onPress: () {
                setState(() {
                  internet = true;
                });

                getData(widget.index);
              },
            ),
    );
  }

  Container buildForm() {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              // Ward No
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownWard,
                  onChanged: (newValue) {
                    dropdownWard = newValue;
                    int end = newValue.toString().indexOf(" W");
                    wardNo = newValue.toString().substring(0, end);
                  },
                  items: ward,
                  decoration: CustomDecoration.decoration('Ward No'),
                ),
              ),

              // Bed
              TextContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //Bed
                  children: [
                    //Bed No
                    Container(
                      alignment: Alignment.topCenter,
                      height: 90,
                      width: screenWidth / 2 - 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextFormField(
                        controller: textControllerBedNo,
                        validator: (text) {
                          if (text.isEmpty) {
                            return 'Enter Bed No';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: CustomDecoration.decoration('Bed No'),
                        maxLines: 1,
                      ),
                    ),

                    //Bed Type
                    Container(
                      alignment: Alignment.topCenter,
                      height: 90,
                      width: screenWidth / 2 - 30,
                      child: DropdownButtonFormField(
                        value: dropdownBedType,
                        validator: (text) {
                          if (dropdownBedType == null) {
                            return 'Select Bed Type';
                          }
                          return null;
                        },
                        onChanged: (newValue) => dropdownBedType = newValue,
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
                        decoration: CustomDecoration.decoration('Bed Type'),
                      ),
                    )
                  ],
                ),
              ),

              // Status
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownStatusValue,
                  onChanged: (newValue) => dropdownStatusValue = newValue,
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

              // Consultant
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownConsultantValue,
                  hint: Text('Select Consultant'),
                  onChanged: (newValue) {
                    setState(() {
                      dropdownConsultantValue = newValue;
                    });
                  },
                  items:
                      consultant.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'Consultant', dropdownConsultantValue),
                ),
              ),

              // Member Index
              TextContainer(
                child: TextFormField(
                  controller: textControllerIndex,
                  validator: (text) {
                    RegExp regex = new RegExp("[']");
                    if (text.isEmpty)
                      return 'Enter Index Number';
                    else if (text.length < 6 || regex.hasMatch(text))
                      return 'Invalid Index Number !';
                    return null;
                  },
                  decoration: CustomDecoration.decoration('Member Index'),
                  maxLines: 1,
                ),
              ),

              // Member Index(Optional)
              TextContainer(
                child: TextFormField(
                  controller: textControllerIndex2,
                  validator: (text) {
                    if (text.isNotEmpty) {
                      RegExp regex = new RegExp("[']");
                      if (text.length < 6 || regex.hasMatch(text))
                        return 'Invalid Index Number !';
                      return null;
                    }
                    return null;
                  },
                  decoration:
                      CustomDecoration.decoration('Member Index(Optional)'),
                  maxLength: 6,
                  maxLines: 1,
                ),
              ),

              // History
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownHistoryValue,
                  hint: Text('Select History'),
                  onChanged: (newValue) => dropdownHistoryValue = newValue,
                  items: <String>['Done', 'Not Done']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'History', dropdownHistoryValue),
                ),
              ),

              // Examination
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownExamValue,
                  hint: Text('Select Examination'),
                  onChanged: (newValue) => dropdownExamValue = newValue,
                  items: <String>['Done', 'Not Done']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'Examination', dropdownExamValue),
                ),
              ),

              // Presenting Complaint
              Container(
                alignment: Alignment.topCenter,
                height: 190,
                child: TextFormField(
                  controller: textControllerPresenting,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: CustomDecoration.decorationTextAria(
                      'Presenting Complaint & DD'), //Presenting Complaint --> Presenting Complaint & DD
                  maxLines: 5,
                ),
              ),

              // Possible DD
              Container(
                alignment: Alignment.topCenter,
                height: 190,
                child: TextFormField(
                  controller: textControllerPossible,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: CustomDecoration.decorationTextAria(
                      'Management & What I Learnt'), // Possible DD --> Management & What I Learnt
                  maxLines: 5,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              // Button
              Container(
                width: MediaQuery.of(context).size.width - 100,
                decoration: CustomDecoration.decorationButton(),
                // ignore: deprecated_member_use
                child: FlatButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        insertDetails();
                      } else {
                        return;
                      }
                    },
                    child: Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getData(String index) async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        String sql =
            "SELECT `consultant_name` FROM  `user_consultant` WHERE `member_index` = '${widget.index}'";
        consultant = new List();
        await conn.query(sql).then((results) {
          bool check = dropdownConsultantValue == null ? false : true;
          for (var row in results) {
            if (row[0].toString() == dropdownConsultantValue) check = false;
            consultant.add(row[0].toString());
          }
          if (check) consultant.add(dropdownConsultantValue);
        });

        sql =
            "SELECT CONCAT(`ward_no`,' -  ' ,`gender`, ' Ward') AS 'ward' FROM `user_ward` WHERE `member_index` = '$index'";

        ward = new List();
        await conn.query(sql).then((results) {
          bool check = true;
          for (var row in results) {
            if (row[0].toString() == dropdownWard) check = false;
            ward.add(new DropdownMenuItem(
                value: row[0].toString(), child: new Text(row[0].toString())));
          }
          if (check)
            ward.add(new DropdownMenuItem(
                value: dropdownWard, child: new Text(dropdownWard)));
        });

        sql = "SELECT * FROM `bed_type`";

        bedType = new List();
        await conn.query(sql).then((results) {
          bool check = dropdownBedType == null ? false : true;
          for (var row in results) {
            if (row[0].toString() == dropdownBedType) check = false;
            bedType.add(row[0].toString());
          }
          if (check) bedType.add(dropdownBedType);
        });

        setState(() => progress = false);
        conn.close();
      });
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

  void insertDetails() {
    db.getConnection().then((conn) async {
      String sql =
          "UPDATE `details` SET `ward_no` = ?, `bed_no` = ?, `bed_type` = ?, `status` = ?, `consultant_name` = ?, `member_index1` = ?, `member_index2` = ?, `history` = ?, `exmination` = ?, `presenting_complaint` = ?, `possible_dd` = ? WHERE `ward_no` = ? AND `bed_no` = ? AND `bed_type` = ?";

      try {
        await InternetAddress.lookup('google.com');
        await conn.query(sql, [
          wardNo,
          textControllerBedNo.text,
          dropdownBedType,
          dropdownStatusValue,
          dropdownConsultantValue,
          textControllerIndex.text,
          textControllerIndex2.text,
          dropdownHistoryValue,
          dropdownExamValue,
          textControllerPresenting.text,
          textControllerPossible.text,
          widget.wardNo,
          widget.bedNo,
          widget.bedType
        ]);
        await Flushbar(
          message: "Update Success!",
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
}
