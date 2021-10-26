import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/pages/home.dart';
import 'package:wayamba_medicine/util/alertButton.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/textContainer.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class ProfileUpdate extends StatefulWidget {
  String index;
  final String password;
  String name;
  String group;
  String associateGroup;
  String appointment;
  String consultant1;
  String consultant2;
  String consultant3;
  ProfileUpdate(
      {Key key,
      @required this.index,
      @required this.password,
      @required this.name,
      @required this.group,
      @required this.associateGroup,
      @required this.appointment,
      @required this.consultant1,
      this.consultant2,
      this.consultant3})
      : super(key: key);

  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  Mysql db = Mysql();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> group = [];
  List<String> consultant1, consultant2, consultant3 = [];
  List<String> appointment = [];
  List<String> ward = [];
  TextEditingController textEditingControllerIndex =
      new TextEditingController();
  TextEditingController textEditingControllerName = new TextEditingController();

  String dropdownGroup;
  String dropdownAppointment;
  String dropdownAssociatedGroup;
  String dropdownConsultant1;
  String dropdownConsultant2;
  String dropdownConsultant3;
  String dropdownWard1;
  String dropdownWard2;
  String wardGender1;
  String wardGender2;
  int oldWard1;
  int oldWard2;
  int wardNo1;
  int wardNo2;
  bool progress = true;
  bool internet = true;

  @override
  void initState() {
    super.initState();
    getData();
    print(widget.associateGroup);
    print(widget.appointment);
    print(widget.group);
    textEditingControllerIndex.text = widget.index;

    textEditingControllerName.text = widget.name;
    dropdownAppointment = widget.appointment;
    dropdownGroup = widget.group;
    dropdownAssociatedGroup =
        widget.associateGroup != 'null' ? widget.associateGroup : null;
    dropdownConsultant1 = widget.consultant1;
    dropdownConsultant2 = widget.consultant2;
    dropdownConsultant3 = widget.consultant3;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                  index: widget.index,
                  appointment: widget.appointment,
                  associateGroup: widget.associateGroup,
                  group: widget.group,
                  name: widget.name,
                  password: widget.password))),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Edit Profile'),
          centerTitle: true,
          actions: [
            AlertButton(
                consultant: [
                  dropdownConsultant1,
                  if (dropdownConsultant2 != null) dropdownConsultant2,
                  if (dropdownConsultant3 != null) dropdownConsultant3
                ],
                group: widget.group,
                associatedGroup: widget.associateGroup,
                index: widget.index)
          ],
        ),
        body: internet
            ? (progress
                ? Center(child: CircularProgressIndicator())
                : buildForm())
            : InternetError(
                onPress: () {
                  setState(() {
                    internet = true;
                  });

                  getData();
                },
              ),
      ),
    );
  }

  SingleChildScrollView buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Container(
          padding:
              const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 40),
          child: Column(
            children: <Widget>[
              // Index No
             TextContainer(
                child: TextFormField(
                  controller: textEditingControllerIndex,
                  maxLength: 6,
                  decoration: CustomDecoration.decoration('Index Number'),
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'Enter Index Number';
                    } else if (text.length < 6)
                      return 'Enter Valid Index Number';
                    return null;
                  },
                ),
              ),

              // Name
              TextContainer(
                child: TextFormField(
                  maxLength: 50,
                  controller: textEditingControllerName,
                  inputFormatters: [
                    new WhitelistingTextInputFormatter(RegExp("[a-zA-Z- ]")),
                  ],
                  decoration: CustomDecoration.decoration('Name'),
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'Enter Name';
                    }
                    return null;
                  },
                ),
              ),

              // Group
              TextContainer(
                child: DropdownButtonFormField(
                    value: dropdownGroup,
                    hint: Text('Select Group'),
                    onChanged: (newValue) {
                      setState(() => dropdownGroup = newValue);
                    },
                    validator: (text) {
                      if (dropdownGroup == null) {
                        return 'Select Group';
                      }
                      return null;
                    },
                    items: group.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    decoration: CustomDecoration.decorationDropDown(
                        'Group', dropdownGroup)),
              ),

              // Associated Group
             TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownAssociatedGroup,
                  hint: Text('Select Associated Group (Optional)'),
                  onChanged: (newValue) {
                    setState(() => dropdownAssociatedGroup = newValue);
                  },
                  validator: (text) {
                    if (text == dropdownGroup) {
                      return 'Select Another Group';
                    }
                    return null;
                  },
                  items: group.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'Associated Group', dropdownAssociatedGroup),
                ),
              ),

              // Appointment
              TextContainer(
                child: DropdownButtonFormField(
                    value: dropdownAppointment,
                    hint: Text('Select Appointment'),
                    onChanged: (newValue) {
                      setState(() => dropdownAppointment = newValue);
                    },
                    validator: (text) {
                      if (dropdownGroup == null) {
                        return 'Select Appointment';
                      }
                      return null;
                    },
                    items:
                        appointment.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    decoration: CustomDecoration.decorationDropDown(
                        'Appointment', dropdownAppointment)),
              ),

              // Ward No 1
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownWard1,
                  hint: Text('Select Ward No 1'),
                  onChanged: (newValue) {
                    setState(() {
                      var ward = newValue.toString().split(" -  ");
                      var gender = ward[1].split(" ");
                      wardNo1 = int.parse(ward[0]);
                      wardGender1 = gender[0];
                      dropdownWard1 = newValue;
                    });
                  },
                  validator: (text) {
                    if (dropdownWard1 == null) return 'Select Ward No 1';

                    return null;
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
                      'Ward No 1', dropdownWard1),
                ),
              ),

              // Ward No 2
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownWard2,
                  hint: Text('Select Ward No 2 (Optional)'),
                  onChanged: dropdownWard1 != null
                      ? (newValue) {
                          setState(() {
                            var ward = newValue.toString().split(" -  ");
                            var gender = ward[1].split(" ");
                            wardNo2 = int.parse(ward[0]);
                            wardGender2 = gender[0];
                            dropdownWard2 = newValue;
                          });
                        }
                      : null,
                  validator: (text) {
                    if (dropdownWard2 != null && dropdownWard1 == dropdownWard2)
                      return 'Select Another Ward No';

                    return null;
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
                      'Ward No 2', dropdownWard2),
                ),
              ),

              // Consultant 1
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownConsultant1,
                  hint: Text('Select Consultant 1'),
                  onChanged: (newValue) {
                    setState(() => dropdownConsultant1 = newValue);
                  },
                  validator: (text) {
                    if (dropdownConsultant1 == null) {
                      return 'Select Consultant 1';
                    }
                    return null;
                  },
                  items:
                      consultant1.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'Consultant 1', dropdownConsultant1),
                ),
              ),

              // Consultant 2
              TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownConsultant2,
                  hint: Text('Select Consultant 2 (Optional)'),
                  onChanged: dropdownConsultant1 != null
                      ? (newValue) {
                          setState(() => dropdownConsultant2 = newValue);
                        }
                      : null,
                  validator: (text) {
                    if (text != null && text == dropdownConsultant1) {
                      return 'Select Another Consultant';
                    }
                    return null;
                  },
                  items:
                      consultant2.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'Consultant 2', dropdownConsultant2),
                ),
              ),

              // Consultant 3
             TextContainer(
                child: DropdownButtonFormField(
                  value: dropdownConsultant3,
                  hint: Text('Select Consultant 3 (Optional)'),
                  onChanged: dropdownConsultant2 != null
                      ? (newValue) {
                          setState(() => dropdownConsultant3 = newValue);
                        }
                      : null,
                  validator: (text) {
                    if (text != null && text == dropdownConsultant1)
                      return 'Select Another Consultant';

                    return null;
                  },
                  items:
                      consultant3.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  decoration: CustomDecoration.decorationDropDown(
                      'Consultant 3', dropdownConsultant3),
                ),
              ),

              SizedBox(height: 50),

              // SignUp Button
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    decoration: CustomDecoration.decorationButton(),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          updatePofile();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getData() async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        String sql = 'SELECT `consultant_name` FROM `consultant`';

        await conn.query(sql).then((results) {
          bool check1 = true;
          bool check2 = dropdownConsultant2 == null ? false : true;
          bool check3 = dropdownConsultant3 == null ? false : true;
          consultant1= new List();
          consultant2= new List();
          consultant3= new List();
          for (var row in results) {
            if (dropdownConsultant1 == row[0]) check1 = false;
            if (dropdownConsultant2 == row[0]) check2 = false;
            if (dropdownConsultant3 == row[0]) check3 = false;
            consultant1.add(row[0]);
            consultant2.add(row[0]);
            consultant3.add(row[0]);
          }
          if (check1) consultant1.add(dropdownConsultant1);
          if (check2) consultant2.add(dropdownConsultant2);
          if (check3) consultant3.add(dropdownConsultant3);
        });

        //Get user Ward
        sql =
            "SELECT `ward_no`, `gender` FROM `user_ward` WHERE `member_index` = '${widget.index}'";
        await conn.query(sql).then((results) {
          var result = results.toList();
          wardNo1 = result[0]['ward_no'];
          wardGender1 = result[0]['gender'];
          oldWard1 = wardNo1;
          dropdownWard1 =
              "${result[0]['ward_no'].toString()} -  ${result[0]['gender']} Ward";
          if (result.length > 1) {
            wardNo2 = result[1]['ward_no'];
            wardGender2 = result[1]['gender'];
            oldWard2 = wardNo2;
            dropdownWard2 =
                "${result[1]['ward_no'].toString()} -  ${result[1]['gender']} Ward";
          }
        });

        sql = "SELECT `group_name` FROM `group`";
        group = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            group.add(row[0]);
          }
        });

        // Get All wards
        sql =
            "SELECT CONCAT(`ward_no`,' -  ' ,`gender`, ' Ward') AS 'ward' FROM `ward`";
        ward = new List();

        await conn.query(sql).then((results) {
          for (var row in results) {
            ward.add(row[0]);
          }
        });

        sql = "SELECT * FROM `appointment`";
        appointment = new List();

        await conn.query(sql).then((results) {
          bool check = dropdownAppointment == null ? false : true;
          for (var row in results) {
            if (row[0].toString() == dropdownAppointment) check = false;
            appointment.add(row[0]);
          }
          if (check) appointment.add(dropdownAppointment);
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

  void updatePofile() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        // Check index is change
        if (widget.index != textEditingControllerIndex.text) {
          // Change Index
          var result = await conn.query(
              "SELECT `isUse` FROM `member` WHERE `member_index` = '${textEditingControllerIndex.text}' AND isUse = 0");
          // Check index is availble
          if (result.toString() != '()') {
            await conn.query(
                "UPDATE `user` SET `member_index`= '${textEditingControllerIndex.text}', `name` = '${textEditingControllerName.text}', `appointment` = '$dropdownAppointment', `group` = '$dropdownGroup', `associated_group`= '$dropdownAssociatedGroup' WHERE `user`.`member_index` = '${widget.index}'");
            await conn.query(
                "UPDATE `member` SET `isUse`=0 WHERE `member_index` = '${widget.index}'");
            await conn.query(
                "UPDATE `member` SET `isUse`= 1 WHERE `member_index` = '${textEditingControllerIndex.text}'");

            // Ward 1
            if (oldWard1 != wardNo1)
              await conn.query(
                  "UPDATE `user_ward` SET `member_index` = '${textEditingControllerIndex.text}', `ward_no`= '$wardNo1' ,`gender`= '$wardGender1' WHERE `member_index` = '${widget.index}' AND `ward_no` = $wardNo1");

            // Ward 2
            if (oldWard2 != null && oldWard2 != wardNo2) {
              await conn.query(
                  "UPDATE `user_ward` SET `member_index` = '${textEditingControllerIndex.text}', `ward_no`= '$wardNo2' ,`gender`= '$wardGender2' WHERE `member_index` = '${widget.index}' AND `ward_no` = $wardNo2");
            } else if (oldWard2 == null && wardNo2 != null) {
              //Insert New
              await conn.query(
                  "INSERT INTO `user_ward`(`member_index`, `ward_no`, `gender`) VALUES ('${textEditingControllerIndex.text}', '$wardNo2', '$wardGender2')");
            }

            // Counsultant 1
            await conn.query(
                "UPDATE `user_consultant` SET `member_index`= '${textEditingControllerIndex.text}', `consultant_name` = '$dropdownConsultant1' WHERE `member_index` = '${widget.index}' AND `consultant_name` = '${widget.consultant1}'");

            // Counsultant 2
            if (widget.consultant2.isNotEmpty) {
              await conn.query(
                  "UPDATE `user_consultant` SET `member_index`= '${textEditingControllerIndex.text}', `consultant_name` = '$dropdownConsultant2' WHERE `member_index` = '${widget.index}' AND `consultant_name` = '${widget.consultant2}'");
            } else {
              //Insert New
              if (dropdownConsultant2 != null)
                await conn.query(
                    "INSERT INTO `user_consultant`(`member_index`, `consultant_name`) VALUES ('${textEditingControllerIndex.text}', '$dropdownConsultant2')");
            }

            // Counsultant 3
            if (widget.consultant3 != null) {
              await conn.query(
                  "UPDATE `user_consultant` SET `member_index`= '${textEditingControllerIndex.text}', `consultant_name`= '$dropdownConsultant3' WHERE `member_index` = '${widget.index}' AND `consultant_name` = '${widget.consultant3}'");
            } else {
              //Insert New
              if (dropdownConsultant3 != null)
                await conn.query(
                    "INSERT INTO `user_consultant`(`member_index`, `consultant_name`) VALUES ('${textEditingControllerIndex.text}', '$dropdownConsultant3')");
            }

            widget.index = textEditingControllerIndex.text;
            widget.name = textEditingControllerName.text;
            widget.appointment = dropdownAppointment;
            widget.group = dropdownGroup;
            widget.associateGroup = dropdownAssociatedGroup;
            widget.consultant1 = dropdownConsultant1;
            widget.consultant2 = dropdownConsultant2;
            widget.consultant3 = dropdownConsultant3;

            await Flushbar(
              message: "Success!",
              messageColor: Colors.green[500],
              icon: Icon(
                Icons.info,
                color: Colors.green[500],
              ),
              duration: Duration(seconds: 3),
            ).show(context);
          } else {
            await Flushbar(
              message: 'Index Number Not Valid !',
              messageColor: Colors.red[500],
              icon: Icon(
                Icons.warning_rounded,
                color: Colors.red[500],
              ),
              duration: Duration(seconds: 3),
            ).show(context);
          }
        } else {
          // Not Change Index

          String sqlUser =
              "UPDATE `user` SET  `name` = '${textEditingControllerName.text}', `appointment` = '$dropdownAppointment', `group` = '$dropdownGroup', `associated_group` = '$dropdownAssociatedGroup' WHERE  `user`.`member_index` = '${widget.index}'";

          await conn.query(sqlUser);

          // Ward 1
          if (oldWard1 != wardNo1)
            await conn.query(
                "UPDATE `user_ward` SET `ward_no`= '$wardNo1' ,`gender`= '$wardGender1' WHERE `member_index` = '${widget.index}' AND `ward_no` = $oldWard1");

          // Ward 2
          if (oldWard2 != null && oldWard2 != wardNo2) {
            await conn.query(
                "UPDATE `user_ward` SET `ward_no`= '$wardNo2' ,`gender`= '$wardGender2' WHERE `member_index` = '${widget.index}' AND `ward_no` = $oldWard2");
          } else if (oldWard2 == null && wardNo2 != null) {
            //Insert New

            await conn.query(
                "INSERT INTO `user_ward`(`member_index`, `ward_no`, `gender`) VALUES ('${widget.index}', '$wardNo2', '$wardGender2')");
          }

          // Counsultant 1
          await conn.query(
              "UPDATE `user_consultant` SET `consultant_name` = '$dropdownConsultant1' WHERE `member_index` = '${widget.index}' AND `consultant_name` = '${widget.consultant1}'");

          // Counsultant 2
          if (widget.consultant2 != null) {
            await conn.query(
                "UPDATE `user_consultant` SET  `consultant_name` = '$dropdownConsultant2' WHERE `member_index` = '${widget.index}' AND `consultant_name` = '${widget.consultant2}'");
          } else {
            //Insert New
            if (dropdownConsultant2 != null)
              await conn.query(
                  "INSERT INTO `user_consultant`(`member_index`, `consultant_name`) VALUES ('${widget.index}', '$dropdownConsultant2')");
          }

          // Counsultant 3
          if (widget.consultant3 != null) {
            await conn.query(
                "UPDATE `user_consultant` SET `consultant_name`= '$dropdownConsultant3' WHERE `member_index` = '${widget.index}' AND `consultant_name` = '${widget.consultant3}'");
          } else {
            //Insert New
            if (dropdownConsultant3 != null)
              await conn.query(
                  "INSERT INTO `user_consultant`(`member_index`, `consultant_name`) VALUES ('${widget.index}', '$dropdownConsultant3')");
          }

          widget.index = textEditingControllerIndex.text;
          widget.name = textEditingControllerName.text;
          widget.appointment = dropdownAppointment;
          widget.group = dropdownGroup;
          widget.associateGroup = dropdownAssociatedGroup;
          widget.consultant1 = dropdownConsultant1;
          widget.consultant2 = dropdownConsultant2;
          widget.consultant3 = dropdownConsultant3;

          await Flushbar(
            message: "Success!",
            messageColor: Colors.green[500],
            icon: Icon(
              Icons.info,
              color: Colors.green[500],
            ),
            duration: Duration(seconds: 3),
          ).show(context);
        }
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
}
