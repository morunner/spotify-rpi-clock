import 'package:flutter/material.dart';

class InnerShadowContainer extends StatelessWidget {
  InnerShadowContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black),
          BoxShadow(
              color: Color(0xFF842B26), spreadRadius: -0.01, blurRadius: 5)
        ],
      ),
      child: child,
    );
  }
}
