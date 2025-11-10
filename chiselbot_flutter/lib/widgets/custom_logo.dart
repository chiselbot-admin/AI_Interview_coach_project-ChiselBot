import 'package:flutter/material.dart';

import '../core/constants.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          Constants.logoAddress,
          height: 160,
        ),
        SizedBox(height: 16),
        const Text(
          "ChiselBot",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32),
        ),
      ],
    );
  }
}
