import 'package:flutter/material.dart';

class EmptyScreen {
  Widget emptyScreen(BuildContext context, int turns, String text1,
      double size1, String text2, double size2, String text3, double size3,
      {bool useWhite = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  text2,
                  style: TextStyle(
                    fontSize: size2,
                    color: useWhite
                        ? Colors.white
                        : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  text3,
                  style: TextStyle(
                    fontSize: size3,
                    fontWeight: FontWeight.w600,
                    color: useWhite ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
