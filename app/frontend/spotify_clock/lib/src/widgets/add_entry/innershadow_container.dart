import 'package:flutter/material.dart';

class InnerShadowContainer extends StatelessWidget {
  const InnerShadowContainer({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black),
            BoxShadow(
                color: Color(0xFF842B26), spreadRadius: -0.01, blurRadius: 5)
          ],
        ),
        child: child,
      ),
    );
  }
}
