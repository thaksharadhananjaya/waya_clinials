import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black38,
                  ),
                  onPressed: () => Navigator.of(context).pop()),
            ),
            Expanded(child: buildBody(height, width)),
          ],
        ),
      ),
    );
  }

  Container buildBody(double height, double width) {
    return Container(
      width: double.infinity,
      height: 700,
      padding: height > 1184
          ? EdgeInsets.symmetric(vertical: 20, horizontal: 40)
          : EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'images/wyaclinicssplash.png',
                  fit: BoxFit.scaleDown,
                  width: width - 190,
                ),
                Text('V 1.0.1')
              ],
            ),
            SizedBox(
              height: 36,
            ),
            RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(children: [
                  new TextSpan(
                      text: ' This app is specially designed for Students in ',
                      style: TextStyle(color: Colors.black45, fontSize: 17)),
                  new TextSpan(
                      text:
                          'Faculty of Medicine,Wayamba University of Sri Lanka ',
                      style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  new TextSpan(
                      text:
                          'to avoid possible shortcomings of history taking in hospital wards. In addition to that ',
                      style: TextStyle(color: Colors.black45, fontSize: 17)),
                  new TextSpan(
                      text: '"Waya Clinicals" ',
                      style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  new TextSpan(
                    text:
                        'app will be helpful to have some idea about each an every patient in the ward and efficient team work could be achieved during the ward round. Every students will be equally benefited by the app. Make the most of it.Huge thanks to ',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 17,
                    ),
                  ),
                  new TextSpan(
                      text: 'Widdev ',
                      style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  new TextSpan(
                      text:
                          'software company for developing this great application. Thank you in advance.',
                      style: TextStyle(color: Colors.black45, fontSize: 17)),
                ])),
            SizedBox(
              height: 10,
            ),
            Text(
              "MFSU - WUSL",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 36,
            ),
            Text(
              'Developed By',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 21),
            ),
            SizedBox(
              height: 10,
            ),
            Image.asset(
              'images/widdev_logo.png',
              fit: BoxFit.scaleDown,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Widdev (PVT) LTD',
              style: TextStyle(
                  color: Color(0xff6e6262),
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
            GestureDetector(
                onTap: () async {
                  await launch('https://www.widdev.com',
                      forceSafariVC: false, forceWebView: false);
                },
                child: Text(
                  'www.widdev.com',
                  style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.underline),
                )),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
