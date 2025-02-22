import 'package:flutter/material.dart';

class ExploreCard extends StatelessWidget {
  const ExploreCard({
    required this.image,
    required this.title,
    required this.height,
  });

  final double height;
  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 4,
              offset: Offset(0, 10),
              blurRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: height * .23 * .7,
            child: Image.asset(image),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
