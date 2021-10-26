import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wayamba_medicine/models/mysql.dart';
import 'package:wayamba_medicine/pages/signupComplete.dart';
import 'package:wayamba_medicine/util/decoration.dart';
import 'package:wayamba_medicine/util/textContainer.dart';
import 'package:wayamba_medicine/util/internetNot.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Mysql db = Mysql();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> group = [];
  List<String> consultant = [];
  List<String> ward = [];
  List<String> appointment = [];
  TextEditingController textEditingControllerPassword =
      new TextEditingController();

  String dropdownGroup;
  String dropdownAppointment;
  String dropdownWard1;
  String dropdownWard2;
  String dropdownAssociatedGroup;
  String dropdownConsultant1;
  String dropdownConsultant2;
  String dropdownConsultant3;
  String wardGender1;
  String wardGender2;
  int wardNo1;
  int wardNo2;
  String index;
  String name;
  String comfirmPassword;
  bool progress = true;
  bool internet = true;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: internet
          ? (progress
              ? Center(child: CircularProgressIndicator())
              : buildForm())
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
                child: Column(
                  children: [
                    Image.asset('images/wayaclinics.png',
                        fit: BoxFit.scaleDown),
                    InternetError(
                      onPress: () {
                        setState(() {
                          internet = true;
                        });

                        getData();
                      },
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.white,
    );
  }

  Widget buildForm() {
    double height = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: height > 800
              ? const EdgeInsets.fromLTRB(24, 50, 24, 10)
              : const EdgeInsets.fromLTRB(24, 36, 24, 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset('images/wayaclinics.png', fit: BoxFit.scaleDown),
                SizedBox(
                  height: 50,
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create your account',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 20,
                ),
                // Index No
                TextContainer(
                  child: TextFormField(
                      maxLength: 6,
                      decoration: CustomDecoration.decoration('Index Number'),
                      validator: (text) {
                        RegExp regex = new RegExp("[']");
                        if (text.isEmpty) {
                          return 'Enter Index Number';
                        } else if (text.length < 6 || regex.hasMatch(text))
                          return 'Invalid Index Number !';

                        return null;
                      },
                      onSaved: (value) {
                        index = value;
                      }),
                ),

                // Name
                TextContainer(
                  child: TextFormField(
                      maxLength: 50,
                      inputFormatters: [
                        // ignore: deprecated_member_use
                        new WhitelistingTextInputFormatter(
                            RegExp("[a-zA-Z- ]")),
                      ],
                      decoration: CustomDecoration.decoration('Name'),
                      validator: (text) {
                        if (text.isEmpty) {
                          return 'Enter Name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        name = value;
                      }),
                ),

                // Password
                TextContainer(
                  child: TextFormField(
                    maxLength: 8,
                    controller: textEditingControllerPassword,
                    obscureText: passwordVisible ? false : true,
                    decoration: buildInputDecPswd(context, 'Password'),
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
                  ),
                ),

                // Comfirm Password
                TextContainer(
                  child: TextFormField(
                      maxLength: 8,
                      obscureText: passwordVisible ? false : true,
                      decoration: buildInputDecPswd(
                        context,
                        'Comfirm Password',
                      ),
                      validator: (text) {
                        if (text.isEmpty) {
                          return 'Re-Enter Password';
                        } else if (text != textEditingControllerPassword.text)
                          return "Doesn't Match Password";
                        return null;
                      },
                      onSaved: (value) {
                        comfirmPassword = value;
                      }),
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
                      items:
                          group.map<DropdownMenuItem<String>>((String value) {
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
                      items: appointment
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
                          'Appointment', dropdownAppointment)),
                ),

                // Ward No 1
                TextContainer(
                  child: DropdownButtonFormField(
                    value: dropdownWard1,
                    hint: Text('Select Ward No 1'),
                    onChanged: (newValue) => setState(() {
                      var ward = newValue.toString().split(" -  ");
                      var gender = ward[1].split(" ");
                      wardNo1 = int.parse(ward[0]);
                      wardGender1 = gender[0];
                      dropdownWard1 = newValue;
                    }),
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
                        ? (newValue) => setState(() {
                              var ward = newValue.toString().split(" -  ");
                              var gender = ward[1].split(" ");
                              wardNo2 = int.parse(ward[0]);
                              wardGender2 = gender[0];
                              dropdownWard2 = newValue;
                            })
                        : null,
                    validator: (text) {
                      if (dropdownWard2 != null &&
                          dropdownWard1 == dropdownWard2)
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
                    items: consultant
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
                      if (text != null && text == dropdownConsultant1)
                        return 'Select Another Consultant';

                      return null;
                    },
                    items: consultant
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
                      if (text != null &&
                          (text == dropdownConsultant1 ||
                              text == dropdownConsultant2))
                        return 'Select Another Consultant';

                      return null;
                    },
                    items: consultant
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
                        'Consultant 3', dropdownConsultant3),
                  ),
                ),

                SizedBox(height: 40),

                // SignUp Button
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  decoration: CustomDecoration.decorationButton(),
                  child: FlatButton(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        createPofile();
                      } else {
                        await Flushbar(
                          message: 'Again check your details !',
                          messageColor: Colors.red[500],
                          icon: Icon(
                            Icons.warning_rounded,
                            color: Colors.red[500],
                          ),
                          duration: Duration(seconds: 3),
                        ).show(context);
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Already a member?'),
                    SizedBox(width: 10),
                    GestureDetector(
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 6,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecPswd(BuildContext context, String label) {
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

  Future<void> getData() async {
    try {
      await InternetAddress.lookup('google.com');
      db.getConnection().then((conn) async {
        String sql = 'SELECT `consultant_name` FROM `consultant`';
        consultant = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            consultant.add(row[0]);
          }
        });

        sql = "SELECT `group_name` FROM `group`";
        group = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            group.add(row[0]);
          }
        });

        sql = "SELECT * FROM `appointment`";
        appointment = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            appointment.add(row[0]);
          }
        });

        sql =
            "SELECT CONCAT(`ward_no`,' -  ' ,`gender`, ' Ward') AS 'ward' FROM `ward`";
        ward = new List();
        await conn.query(sql).then((results) {
          for (var row in results) {
            ward.add(row[0]);
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

  void createPofile() async {
    await InternetAddress.lookup('google.com');
    try {
      db.getConnection().then((conn) async {
        String sql =
            "SELECT `isUse` FROM `member` WHERE `member_index` = '$index' AND isUse = 0";
        var result = await conn.query(sql);

        if (result.toString() != '()') {
          String sqlMember =
              "UPDATE `member` SET `isUse`= 1 WHERE `member_index` = '$index'";
          String sqlUser =
              "INSERT INTO `user`(`member_index`, `name`, `password`, `appointment`, `group`, `associated_group`) VALUES ('$index','$name', '${textEditingControllerPassword.text}', '$dropdownAppointment','$dropdownGroup', '$dropdownAssociatedGroup')";
          String sqlWard =
              "INSERT INTO `user_ward`(`member_index`, `ward_no`, `gender`) VALUES (?,?,?)";
          String sqlConsultant =
              "INSERT INTO `user_consultant`(`member_index`, `consultant_name`) VALUES (?,?)";

          await conn.query(sqlMember);
          await conn.query(sqlUser);
          await conn.queryMulti(sqlWard, [
            [index, wardNo1, wardGender1],
            if (wardNo2 != null) [index, wardNo2, wardGender2]
          ]);
          await conn.queryMulti(sqlConsultant, [
            [index, dropdownConsultant1],
            if (dropdownConsultant2 != null) [index, dropdownConsultant2],
            if (dropdownConsultant3 != null) [index, dropdownConsultant3]
          ]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Complete(
                        name: name,
                        index: index,
                        password: textEditingControllerPassword.text,
                        appointment: dropdownAppointment,
                        associateGroup: dropdownAssociatedGroup,
                        group: dropdownGroup,
                      )));
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
