import 'package:flutter/material.dart';

class InternetError extends StatelessWidget {
  final Function onPress;
  const InternetError({Key key, @required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            Image.asset(
              'images/nonetwork.png',
              fit: BoxFit.scaleDown,
            ),
            Text(
              'No internet connection !',
              style: TextStyle(
                  color: Colors.red[200],
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            SizedBox(
              height: 30,
            ),
            // ignore: deprecated_member_use
            RaisedButton(
              onPressed: onPress,
              child: Text('Refresh'),
            )
          ],
        ));
  }
}
