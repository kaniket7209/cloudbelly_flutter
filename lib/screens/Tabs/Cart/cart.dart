import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 8, right: 8),
        child: ListView(
          children: <Widget>[
            Text(
              "Notificaion & Order",
              style: TextStyle(fontSize: 24),
            ),
            ListTile(
              leading:
                  CircleAvatar(backgroundImage: AssetImage('path/to/image')),
              title: Text(
                'Bernadete, Ramesh & 7 others started following you',
                style: TextStyle(
                  color: Color(0xFF0A4C61),
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  fontWeight: FontWeight.w700,
                  height: 0,
                  letterSpacing: 0.12,
                ),
              ),
              trailing: Container(
                width: 80,
                height: 27,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff7CC1BF),
                ),

                alignment: Alignment.center,
                child: Text('Follow',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Product Sans')),
                // color: Colors.purple,
                // onPressed: () {},
              ),
            ),
            // ListTile(
            //   leading: CircleAvatar(backgroundImage: AssetImage('path/to/image')),
            //   title: Text('Bernadete commented on your post',),
            //   subtitle: Text('Best food ever had in a long time...'),
            //   trailing: Icon(Icons.more_horiz),
            // ),
            // ListTile(
            //   leading: CircleAvatar(backgroundImage: AssetImage('path/to/image')),
            //   title: Text('Geeta Kitchen have accepted your order.'),
            //   trailing: TextButton(
            //     child: Text('Track', style: TextStyle(color: Colors.white)),
            //     // color: Colors.purple,
            //     onPressed: () {},
            //   ),
            // ),
            // ListTile(
            //   leading: Icon(Icons.restaurant),
            //   title: Text('Chicken Biryani x 3'),
            //   subtitle: Text('7:45 PM'),
            // ),
          ],
        ),
      ),
    );
  }
}
