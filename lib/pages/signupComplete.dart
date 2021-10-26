import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wayamba_medicine/pages/home.dart';
import 'package:wayamba_medicine/util/decoration.dart';

class Complete extends StatefulWidget {
  final String index;
  final String password;
  final String name;
  final String group;
  final String associateGroup;
  final String appointment;
  Complete(
      {Key key,
      @required this.index,
      @required this.password,
      @required this.name,
      @required this.group,
      @required this.associateGroup,
      @required this.appointment})
      : super(key: key);

  @override
  _CompleteState createState() => _CompleteState();
}

class _CompleteState extends State<Complete> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => exitNow(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Image.asset('images/welcome.jpg', width: 450,height: 400,),

              Container(
                width: screenWidth,
                margin: EdgeInsets.symmetric(horizontal: 24),
                height: 50,
                decoration: CustomDecoration.decorationButton(),
                // ignore: deprecated_member_use
                child: FlatButton(
                    onPressed: () => Navigator.push(
                  context,MaterialPageRoute(
                      builder: (context) => Home(
                            index: widget.index,
                            appointment: widget.appointment,
                            associateGroup:widget.associateGroup,
                            group: widget.group,
                            name: widget.name,
                            password: widget.name
                          ))),
                    child: Text(
                      "Let's Start",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  exitNow() {
    SystemChannels.platform.invokeListMethod('SystemNavigator.pop');
  }
}
