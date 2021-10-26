import 'package:flutter/material.dart';

class TextContainer extends StatelessWidget {
  final Widget child;
  final Icon suffixIcon;
  const TextContainer({Key key, this.child, this.suffixIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
        var shortestSide = MediaQuery.of(context).size.shortestSide;
    return Container(
      height:shortestSide < 600? (height > 800 ?  90:70): 100,
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.only(top: 7),
        width: 300, child: child),
    );
  }
}
