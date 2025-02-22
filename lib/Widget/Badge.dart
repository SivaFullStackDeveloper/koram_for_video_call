import 'package:flutter/material.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    required this.child,
    required this.value,
//  required this.color,
  });

  final child;
  final int value;
  //  final Color color;

  @override
  Widget build(BuildContext context) {
    print(value);
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        value!=0?
        Positioned(
          right: 1,
          top: 10,
          child: Container(
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(10.0),
              color: RuntimeStorage.instance.PrimaryOrange,
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ):SizedBox()
      ],
    );
  }
}
