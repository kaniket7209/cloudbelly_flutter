import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Feature Coming Soon',
          style: TextStyle(
            color: Color(0xFF094B60),
            fontSize: 20,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            // height: 0.05,
            letterSpacing: 0.60,
          ),
        ),
      ),
    );
  }
}
