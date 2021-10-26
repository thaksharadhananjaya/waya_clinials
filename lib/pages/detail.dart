import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/util/alertButton.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/textContainer.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class Detail extends StatefulWidget {
  final String index;
  final String group;
  final String associatedGroup;
  final List<String> consultant;

  Detail(
      {Key key,
      @required this.index,
      @required this.group,
      @required this.associatedGroup,
      @required this.consultant})
      : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController textControllerIndex = TextEditingController();
  TextEditingController textControllerIndex2 = TextEditingController();
  TextEditingController textControllerPresenting = TextEditingController();
  TextEditingController textControllerPossible = TextEditingController();
  TextEditingController textControllerBedNo = TextEditingController();

  List<String> ward = [];
  List<DropdownMenuItem<String>> bedType = new List();
  String dropdownWard;
  String dropdownConsultant;
  String dropdownStatus = "New Admission";
  String dropdownHistoryValue = "Not Done";
  String dropdownExamValue = "Not Done";
  String dropdownBedType = "Normal";
  String wardNo;
  bool progress = true;
  bool internet = true;
  Mysql db = Mysql();

  @override
  void initState() {
    super.initState();
    textControllerIndex.text = widget.index;
    if (widget.consultant.length == 1)
      dropdownConsultant = widget.consultant[0];
    getData(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Add New"), centerTitle: true, actions: [
        AlertButton(
            index: widget.index,
            consultant: widget.consultant,
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
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Form(
          autovalidate: true,
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 5),
              // Ward No
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownWard,
                  validator: (text) {
                    if (dropdownWard == null) {
                      return 'Select Ward No';
                    }
                    return null;
                  },
                  hint: Text('Select Ward No'),
                  onChanged: (newValue) {
                    dropdownWard = newValue;
                    int end = newValue.toString().indexOf(" W");
                    wardNo = newValue.toString().substring(0, end);
                  },
                  items: ward.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'Ward No', dropdownWard),
                ),
              ),

              // Bed
              TextContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //Bed No
                  children: [
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
                        items: bedType,
                        decoration: CustomDecoration.decoration('Bed Type'),
                      ),
                    )
                  ],
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

              // Consultant
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownConsultant,
                  hint: Text('Select Consultant'),
                  onChanged: (newValue) {
                    dropdownConsultant = newValue;
                    FocusScope.of(context).unfocus();
                  },
                  items: widget.consultant
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
                      'Consultant', dropdownConsultant),
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
                  onChanged: (newValue) {
                    dropdownHistoryValue = newValue;
                    FocusScope.of(context).unfocus();
                  },
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
                  onChanged: (newValue) {
                    dropdownExamValue = newValue;
                    FocusScope.of(context).unfocus();
                  },
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
                  maxLength: 250,
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
                  decoration:
                      CustomDecoration.decorationTextAria('Management & What I Learnt'), // Possible DD --> Management & What I Learnt
                  maxLines: 5,
                  maxLength: 250,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Clear Button
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                        color: Colors.red[300],
                        borderRadius: new BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.red[200],
                              blurRadius: 12.0,
                              spreadRadius: 0.2)
                        ]),
                    // ignore: deprecated_member_use
                    child: FlatButton.icon(
                        onPressed: () => setState(() {
                              textControllerPossible.clear();
                              textControllerPresenting.clear();
                              textControllerBedNo.clear();
                              textControllerIndex2.clear();
                              if (ward.length > 1) dropdownWard = null;
                              if (widget.consultant.length > 1)
                                dropdownConsultant = null;
                              dropdownExamValue = null;
                              if (dropdownStatus != 'New Admission')
                                dropdownStatus = 'New Admission';
                              dropdownHistoryValue = null;
                              if (dropdownBedType != 'Normal')
                                dropdownBedType = 'Normal';
                              textControllerIndex.text = widget.index;
                            }),
                        icon: Icon(Icons.clear, color: Colors.white),
                        label: Text(
                          'Clear',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),

                  // Add Button
                  Container(
                    width: 120,
                    decoration: CustomDecoration.decorationButton(),
                    // ignore: deprecated_member_use
                    child: FlatButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            insertDetails(context);
                          } else {
                            await Flushbar(
                                    message: "Again check details !",
                                    messageColor: Colors.red[500],
                                    icon: Icon(
                                      Icons.warning_rounded,
                                      color: Colors.red[500],
                                    ),
                                    duration: Duration(seconds: 3))
                                .show(context);
                            return;
                          }
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ],
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

  void getData(String index) async {
    try {
      await InternetAddress.lookup('google.com');

      db.getConnection().then((conn) async {
        String sql =
            "SELECT CONCAT(`ward_no`,' -  ' ,`gender`, ' Ward') AS 'ward' FROM `user_ward` WHERE `member_index` = '$index'";
        ward = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            ward.add(row[0].toString());
          }
        });
        if (ward.length == 1) {
          dropdownWard = ward[0];
          int end = dropdownWard.toString().indexOf(" W");
          wardNo = dropdownWard.substring(0, end);
        }

        sql = "SELECT * FROM `bed_type`";
        bedType = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            bedType
              ..add(new DropdownMenuItem(
                  value: row[0].toString(),
                  child: new Text(row[0].toString())));
          }
        });

        setState(() => progress = false);
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

  void insertDetails(BuildContext context) {
    db.getConnection().then((conn) async {


     String date = new DateTime.now().toString();
      print(date);
      String sql =
          "INSERT INTO `details`(`ward_no`, `bed_no`, bed_type, `status`, `consultant_name`, `member_index1`, `member_index2`, `history`, `exmination`, `presenting_complaint`, `possible_dd`, `group`, `date`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

      try {
        await InternetAddress.lookup('google.com');
        await conn.query(sql, [
          wardNo,
          textControllerBedNo.text,
          dropdownBedType,
          dropdownStatus,
          dropdownConsultant,
          textControllerIndex.text,
          textControllerIndex2.text,
          dropdownHistoryValue,
          dropdownExamValue,
          textControllerPresenting.text,
          textControllerPossible.text,
          widget.group,
          date
        ]);

        setState(() {
          textControllerPossible.clear();
          textControllerPresenting.clear();
          dropdownConsultant = null;
          dropdownExamValue = null;
          textControllerBedNo.clear();
          if (ward.length > 1) dropdownWard = null;
          if (widget.consultant.length > 1) dropdownConsultant = null;
          dropdownExamValue = null;
          if (dropdownStatus != 'New Admission')
            dropdownStatus = 'New Admission';
          dropdownHistoryValue = null;
          if (dropdownBedType != 'Normal') dropdownBedType = 'Normal';
          dropdownHistoryValue = null;
        });
        await Flushbar(
          message: "Success!",
          messageColor: Colors.green,
          icon: Icon(
            Icons.info,
            color: Colors.green,
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

      conn.close();
    });
  }
}
